import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:network_file_cached/src/io.dart';
import 'package:network_file_cached/src/record.dart';
import 'package:path_provider/path_provider.dart';

/// Download file from network with caching functionality
class NetworkFileCached {
  NetworkFileCached._internal(this._expired);

  /// TAG for logging
  static const String tag = 'NetworkFileCached';

  /// The duration of the file to be cached before being updated
  final Duration _expired;

  /// Provide the [_url] for the file to cache
  static late String _url;

  /// Model helper for cached files
  static CacheRecord? _record;

  /// Boxes contain all of cache data
  static Box? _box;

  /// The [NetworkFileCached] for this current instance.
  static NetworkFileCached? _instance;

  /// Returns an instance using the default [NetworkFileCached].
  static NetworkFileCached get instance {
    if (_instance == null) {
      throw Exception('NetworkFileCached must be initialized first. \nNetworkFileCached.init()');
    }
    return _instance!;
  }

  static late String _urlKey;

  /// Initialize [NetworkFileCached] by giving it a expired duration.
  static Future<NetworkFileCached> init({Duration expired = const Duration(hours: 12)}) async {
    assert(!expired.isNegative);

    WidgetsFlutterBinding.ensureInitialized();

    var cacheDir = await getTemporaryDirectory();
    debugPrint("cache dir : $cacheDir");
    Hive.init(cacheDir.path);
    Hive.initFlutter(cacheDir.path);
    Hive.registerAdapter(CacheRecordAdapter());
    _box = await Hive.openBox('NetworkFileCached');
    _instance = NetworkFileCached._internal(expired);
    return _instance!;
  }

  /// Download the file with default http method is "GET",
  /// [url] is the file url.
  /// [onReceiveProgress] is the callback to listen downloading progress.
  static Future<File> downloadFile(String url,
      {void Function(int, int)? onReceiveProgress, Map<String, String>? headers}) async {
    if (_instance == null) {
      throw Exception('NetworkFileCached must be initialized first. \nNetworkFileCached.init()');
    }

    _url = url;
    _urlKey = sha256.convert(utf8.encode(_url)).toString();
    _record = _box?.get(_urlKey);

    if (_record == null) {
      debugPrint('$tag = Downloading... Create a new cache');
      await instance._downloadAndPut(onReceiveProgress, headers: headers);
      debugPrint('$tag = New cache has been created');
    } else if (_record != null && _record!.createdAt.add(instance._expired).isBefore(DateTime.now())) {
      await instance._deleteCache(onReceiveProgress);
    }

    if (!await File(_record!.path).exists()) {
      await instance._downloadAndPut(onReceiveProgress, headers: headers);
    }

    debugPrint('$tag = Cache loaded');

    return File(_record!.path);
  }

  /// Download the file and save it in local.
  /// Put meta data to box.
  Future<void> _downloadAndPut(void Function(int, int)? onReceiveProgress, {Map<String, String>? headers}) async {
    String path = await IO.downloadFile(_url, onReceiveProgress: onReceiveProgress, headers: headers);
    _record = CacheRecord(_urlKey, path, DateTime.now());
    await _box?.put(_urlKey, _record);
  }

  /// Delete the local file and meta data record from box.
  Future<void> _deleteCache(void Function(int, int)? onReceiveProgress, {Map<String, String>? headers}) async {
    debugPrint('$tag = Some cache has expired, update cache');
    CacheRecord oldValue = _box?.get(_urlKey);
    await _box?.delete(_urlKey);
    await _downloadAndPut(onReceiveProgress, headers: headers);
    try {
      await File(oldValue.path).delete();
      debugPrint('$tag = Cache has been updated, old cache deleted');
    } catch (e) {
      debugPrint('$tag = ${e.toString()}');
    }
  }

  /// Closes the box.
  static Future<void> close() async {
    await Hive.close();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:network_file_cacher/src/io.dart';
import 'package:network_file_cacher/src/record.dart';
import 'package:path_provider/path_provider.dart';

/// Download file from network with caching functionality
class NetworkFileCacher {
  NetworkFileCacher._internal(this._expired);

  /// TAG for logging
  static const String tag = 'NetworkFileCacher';

  /// The duration of the file to be cached before being updated
  final Duration _expired;

  /// Boxes contain all of cache data
  static Box? _box;

  /// The [NetworkFileCacher] for this current instance.
  static NetworkFileCacher? _instance;

  /// Returns an instance using the default [NetworkFileCacher].
  static NetworkFileCacher get instance {
    if (_instance == null) {
      throw Exception(
          'NetworkFileCacher must be initialized first. \nNetworkFileCacher.init()');
    }
    return _instance!;
  }

  /// Initialize [NetworkFileCacher] by giving it an expired duration.
  static Future<NetworkFileCacher> init(
      {Duration expired = const Duration(hours: 12)}) async {
    assert(!expired.isNegative);

    WidgetsFlutterBinding.ensureInitialized();

    var cacheDir = await getTemporaryDirectory();
    debugPrint("cache dir : $cacheDir");
    Hive.init(cacheDir.path);
    Hive.initFlutter(cacheDir.path);
    Hive.registerAdapter(CacheRecordAdapter());
    _box = await Hive.openBox('NetworkFileCacher');
    _instance = NetworkFileCacher._internal(expired);
    return _instance!;
  }

  /// Download the file with default http method is "GET",
  /// [url] is the file url.
  /// [onReceiveProgress] is the callback to listen downloading progress.
  static Future<File> downloadFile(String url,
      {void Function(int, int)? onReceiveProgress,
      Map<String, String>? headers}) async {
    if (_instance == null) {
      throw Exception(
          'NetworkFileCacher must be initialized first. \nNetworkFileCacher.init()');
    }

    if (headers != null) debugPrint(jsonEncode(headers));

    final String urlKey = sha256.convert(utf8.encode(url)).toString();
    CacheRecord? record = _box?.get(urlKey) as CacheRecord?;

    if (record == null) {
      debugPrint('$tag = Downloading... Create a new cache');
      record = await instance._downloadAndPut(url, urlKey, onReceiveProgress,
          headers: headers);
      debugPrint('$tag = New cache has been created');
    } else if (record.createdAt.add(instance._expired).isBefore(DateTime.now())) {
      record = await instance._deleteCache(url, urlKey, record, onReceiveProgress,
          headers: headers);
    }

    if (!await File(record.path).exists()) {
      record = await instance._downloadAndPut(url, urlKey, onReceiveProgress,
          headers: headers);
    }

    debugPrint('$tag = Cache loaded');

    return File(record.path);
  }

  /// Download the file and save it in local.
  /// Put meta data to box.
  Future<CacheRecord> _downloadAndPut(
      String url, String urlKey, void Function(int, int)? onReceiveProgress,
      {Map<String, String>? headers}) async {
    String path = await IO.downloadFile(url,
        onReceiveProgress: onReceiveProgress, headers: headers);
    final record = CacheRecord(urlKey, path, DateTime.now());
    await _box?.put(urlKey, record);
    return record;
  }

  /// Delete the local file and meta data record from box.
  Future<CacheRecord> _deleteCache(
      String url,
      String urlKey,
      CacheRecord oldValue,
      void Function(int, int)? onReceiveProgress,
      {Map<String, String>? headers}) async {
    debugPrint('$tag = Some cache has expired, update cache');
    await _box?.delete(urlKey);
    final newRecord = await _downloadAndPut(url, urlKey, onReceiveProgress,
        headers: headers);
    try {
      final oldFile = File(oldValue.path);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
      debugPrint('$tag = Cache has been updated, old cache deleted');
    } catch (e) {
      debugPrint('$tag = ${e.toString()}');
    }
    return newRecord;
  }

  /// Closes the box.
  static Future<void> close() async {
    await Hive.close();
  }
}

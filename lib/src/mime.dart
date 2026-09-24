import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import 'db.dart';

class Mime {
  /// Change extension from temp to original extension
  /// Extract the extension from [path] and use that for MIME-type lookup, using
  /// the default extension map.
  static Future<String> changeExtensionFile(String tmpPathFile) async {
    File data = File(tmpPathFile);

    // Read only first 1024 bytes to inspect header without loading whole file into memory
    List<int> headerBytes = [];
    try {
      final stream = data.openRead(0, 1024);
      await for (var chunk in stream) {
        headerBytes.addAll(chunk);
        if (headerBytes.length >= 1024) {
          headerBytes = headerBytes.sublist(0, 1024);
          break;
        }
      }
    } catch (_) {}

    final mime = lookupMimeType('temp', headerBytes: headerBytes.isNotEmpty ? headerBytes : null);
    final ext = _getExtensionsFromType(mime);
    if (ext != null) {
      String dir = path.dirname(data.path);
      String newPath =
          path.join(dir, path.basenameWithoutExtension(data.path) + ext);
      await data.rename(newPath);
      return newPath;
    }
    return tmpPathFile;
  }

  /// Read extension map
  static String? _getExtensionsFromType(String? type) {
    if (type == null || type.isEmpty) return null;

    if (database.containsKey(type)) {
      return database[type];
    }

    return null;
  }
}

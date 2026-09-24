import 'dart:math';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'mime.dart';

class IO {
  /// Download the file and save it in local as temp file. The default http method is "GET",
  /// [urlPath] is the file url.
  /// [onReceiveProgress] is the callback to listen downloading progress.
  static Future<String> downloadFile(String urlPath,
      {void Function(int, int)? onReceiveProgress, Map<String, String>? headers}) async {
    Dio dio = Dio();

    try {
      String savePath = await getFilePath('${getRandomString()}.tmp');

      await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: true,
        options: Options(headers: headers),
      );

      return await Mime.changeExtensionFile(savePath);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Dio error occurred');
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  static Future<String> getFilePath(String uniqueFileName) async {
    final directory = await getTemporaryDirectory();

    return '${directory.path}/$uniqueFileName';
  }

  /// Creates random string for downloaded file name.
  static String getRandomString() {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    return String.fromCharCodes(Iterable.generate(25, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }
}

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class WebpConverter {
  static Future<File> toWebp({
    required File inputFile,
    int quality = 85,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        '${dir.path}/webp_${DateTime.now().millisecondsSinceEpoch}.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      inputFile.path,
      outPath,
      format: CompressFormat.webp,
      quality: quality,
    );
    if (result == null) throw Exception('WebP conversion failed');
    return File(result.path);
  }

  static Future<File> fromWebp({
    required File webpFile,
    String outputFormat = 'jpg',
    int quality = 90,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = outputFormat == 'png' ? 'png' : 'jpg';
    final outPath = '${dir.path}/from_webp_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final result = await FlutterImageCompress.compressAndGetFile(
      webpFile.path, outPath,
      format: ext == 'png' ? CompressFormat.png : CompressFormat.jpeg,
      quality: quality,
    );
    if (result == null) throw Exception('WebP decode failed');
    return File(result.path);
  }
}

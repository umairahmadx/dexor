import 'dart:io';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class HeicConverter {
  static Future<File> toJpg({
    required File heicFile,
    int quality = 90,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        '${dir.path}/heic_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final jpgPath = await HeicToJpg.convert(heicFile.path, jpgPath: outPath);
    if (jpgPath == null) throw Exception('HEIC conversion failed');
    return File(jpgPath);
  }

  static Future<File> toPng({required File heicFile}) async {
    final jpg = await toJpg(heicFile: heicFile);
    final result = await FlutterImageCompress.compressAndGetFile(
      jpg.path,
      jpg.path.replaceAll('.jpg', '.png'),
      format: CompressFormat.png,
    );
    if (result == null) throw Exception('PNG encode failed');
    await jpg.delete();
    return File(result.path);
  }

  static Future<List<File>> batchConvert({
    required List<File> heicFiles,
    String outputFormat = 'jpg',
    void Function(int done, int total)? onProgress,
  }) async {
    final results = <File>[];
    for (int i = 0; i < heicFiles.length; i++) {
      final converted = outputFormat == 'png'
          ? await toPng(heicFile: heicFiles[i])
          : await toJpg(heicFile: heicFiles[i]);
      results.add(converted);
      onProgress?.call(i + 1, heicFiles.length);
    }
    return results;
  }
}

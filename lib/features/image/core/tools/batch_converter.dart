import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'image_converter.dart';

class BatchConverter {
  static Future<List<File>> convertAll({
    required List<File> files,
    required ImageFormat toFormat,
    int quality = 85,
    void Function(int done, int total)? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final outDir = Directory('${dir.path}/converted_${DateTime.now().millisecondsSinceEpoch}');
    await outDir.create();

    final results = <File>[];
    for (int i = 0; i < files.length; i++) {
      final bytes = await files[i].readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) continue;

      final encoded = toFormat.encode(decoded, quality: quality);
      final stem = files[i].path.split('/').last.split('.').first;
      final out = File('${outDir.path}/$stem.${toFormat.ext}');
      await out.writeAsBytes(encoded);
      results.add(out);
      onProgress?.call(i + 1, files.length);
    }
    return results;
  }
}

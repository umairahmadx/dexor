import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CompressConfig {
  final int quality;
  final int? targetSizeKB;
  final int maxInputSizeKB;
  final int minQuality;

  const CompressConfig({
    this.quality = 85,
    this.targetSizeKB,
    this.maxInputSizeKB = 0,
    this.minQuality = 20,
  });
}

class ImageCompressor {
  static Future<File> compress({
    required File inputFile,
    required CompressConfig config,
    String outputFormat = 'jpg',
  }) async {
    final inputBytes = await inputFile.readAsBytes();
    final inputKB = inputBytes.length ~/ 1024;

    if (config.maxInputSizeKB > 0 && inputKB > config.maxInputSizeKB) {
      throw Exception(
        'Input file ($inputKB KB) exceeds the limit of ${config.maxInputSizeKB} KB.',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = outputFormat == 'webp' ? 'webp' : (outputFormat == 'png' ? 'png' : 'jpg');
    final outPath = '${dir.path}/compressed_$ts.$ext';
    final format = outputFormat == 'webp'
        ? CompressFormat.webp
        : (outputFormat == 'png' ? CompressFormat.png : CompressFormat.jpeg);

    if (config.targetSizeKB == null) {
      final result = await FlutterImageCompress.compressAndGetFile(
        inputFile.path,
        outPath,
        quality: config.quality,
        format: format,
      );
      if (result == null) throw Exception('Compression failed');
      return File(result.path);
    }

    int lo = config.minQuality;
    int hi = 100;
    XFile? best;

    while (lo <= hi) {
      final mid = (lo + hi) ~/ 2;
      final tmpPath = '${dir.path}/tmp_q${mid}_$ts.$ext';

      final result = await FlutterImageCompress.compressAndGetFile(
        inputFile.path,
        tmpPath,
        quality: mid,
        format: format,
      );

      if (result == null) break;
      final sizeKB = await result.length() ~/ 1024;

      if (sizeKB <= config.targetSizeKB!) {
        best = result;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    if (best == null) {
      final fallback = await FlutterImageCompress.compressAndGetFile(
        inputFile.path, outPath,
        quality: config.minQuality, format: format,
      );
      if (fallback == null) throw Exception('Compression failed');
      return File(fallback.path);
    }

    final finalFile = File(outPath);
    await finalFile.writeAsBytes(await best.readAsBytes());
    return finalFile;
  }

  static Future<Map<String, int>> previewSizes(File inputFile) async {
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final result = <String, int>{};

    for (final q in [30, 60, 90]) {
      final tmp = await FlutterImageCompress.compressAndGetFile(
        inputFile.path,
        '${dir.path}/preview_q${q}_$ts.jpg',
        quality: q,
      );
      if (tmp != null) {
        result['q$q'] = await tmp.length() ~/ 1024;
      }
    }
    return result;
  }
}

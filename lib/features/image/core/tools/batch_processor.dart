import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class BatchConfig {
  final int? resizeWidth;
  final int? resizeHeight;
  final int maxDimension;
  final int? targetSizeKB;
  final int quality;
  final String outputFormat;
  final int maxFileSizeKB;

  const BatchConfig({
    this.resizeWidth,
    this.resizeHeight,
    this.maxDimension = 4096,
    this.targetSizeKB,
    this.quality = 85,
    this.outputFormat = 'jpg',
    this.maxFileSizeKB = 0,
  });
}

class BatchResult {
  final File? outputFile;
  final File sourceFile;
  final String? error;
  bool get success => outputFile != null;
  BatchResult.ok(this.sourceFile, this.outputFile) : error = null;
  BatchResult.fail(this.sourceFile, this.error) : outputFile = null;
}

class BatchProcessor {
  static Future<List<BatchResult>> process({
    required List<File> files,
    required BatchConfig config,
    void Function(int done, int total, BatchResult last)? onProgress,
  }) async {
    final results = <BatchResult>[];
    final dir = await getApplicationDocumentsDirectory();
    final outDir = Directory('${dir.path}/batch_${DateTime.now().millisecondsSinceEpoch}');
    await outDir.create(recursive: true);

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      try {
        if (config.maxFileSizeKB > 0) {
          final kb = await file.length() ~/ 1024;
          if (kb > config.maxFileSizeKB) {
            final r = BatchResult.fail(file, 'Exceeds input size limit');
            results.add(r);
            onProgress?.call(i + 1, files.length, r);
            continue;
          }
        }

        final bytes = await file.readAsBytes();
        var image = img.decodeImage(bytes);
        if (image == null) throw Exception('Decode failed');

        if (config.resizeWidth != null || config.resizeHeight != null) {
          int w = config.resizeWidth ?? image.width;
          int h = config.resizeHeight ?? image.height;
          if (config.resizeWidth != null && config.resizeHeight == null) {
            h = (w * image.height / image.width).round();
          }
          if (config.resizeHeight != null && config.resizeWidth == null) {
            w = (h * image.width / image.height).round();
          }
          w = w.clamp(1, config.maxDimension);
          h = h.clamp(1, config.maxDimension);
          image = img.copyResize(image, width: w, height: h);
        }

        final ext = config.outputFormat;
        final encoded = switch (ext) {
          'png'  => img.encodePng(image),
          'webp' => img.encodeJpg(image, quality: config.quality),
          _      => img.encodeJpg(image, quality: config.quality),
        };

        final name = '${_stem(file.path)}_processed.$ext';
        final outFile = File('${outDir.path}/$name');
        await outFile.writeAsBytes(encoded);

        final r = BatchResult.ok(file, outFile);
        results.add(r);
        onProgress?.call(i + 1, files.length, r);
      } catch (e) {
        final r = BatchResult.fail(file, e.toString());
        results.add(r);
        onProgress?.call(i + 1, files.length, r);
      }
    }
    return results;
  }

  static String _stem(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot == -1 ? name : name.substring(0, dot);
  }
}

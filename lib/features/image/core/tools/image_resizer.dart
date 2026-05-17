import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ResizeConfig {
  final int? targetWidth;
  final int? targetHeight;
  final int maxDimension;
  final int maxFileSizeKB;
  final bool maintainAspect;

  const ResizeConfig({
    this.targetWidth,
    this.targetHeight,
    this.maxDimension = 8000,
    this.maxFileSizeKB = 0,
    this.maintainAspect = true,
  }) : assert(targetWidth != null || targetHeight != null,
         'Provide at least one of targetWidth or targetHeight');
}

class ImageResizer {
  static Future<File> resize({
    required File inputFile,
    required ResizeConfig config,
    String outputFormat = 'jpg',
    int jpgQuality = 90,
  }) async {
    final bytes = await inputFile.readAsBytes();
    final src = img.decodeImage(bytes);
    if (src == null) throw Exception('Could not decode image');

    int rawW;
    int rawH;

    if (config.targetWidth != null && config.targetHeight != null) {
      rawW = config.targetWidth!;
      rawH = config.targetHeight!;
    } else if (config.targetWidth != null) {
      rawW = config.targetWidth!;
      rawH = (rawW * src.height / src.width).round();
    } else {
      rawH = config.targetHeight!;
      rawW = (rawH * src.width / src.height).round();
    }

    if (rawW > config.maxDimension || rawH > config.maxDimension) {
      final scale = config.maxDimension / rawW.clamp(rawH, rawW).toDouble();
      rawW = (rawW * scale).round();
      rawH = (rawH * scale).round();
    }

    rawW = rawW.clamp(1, src.width);
    rawH = rawH.clamp(1, src.height);

    final resized = img.copyResize(
      src,
      width: rawW,
      height: rawH,
    );

    Uint8List output;
    String ext;
    switch (outputFormat.toLowerCase()) {
      case 'png':
        output = Uint8List.fromList(img.encodePng(resized));
        ext = 'png';
      case 'webp':
        output = Uint8List.fromList(img.encodeJpg(resized, quality: jpgQuality));
        ext = 'webp';
      default:
        output = Uint8List.fromList(img.encodeJpg(resized, quality: jpgQuality));
        ext = 'jpg';
    }

    if (config.maxFileSizeKB > 0 && ext == 'jpg') {
      int quality = jpgQuality;
      while (output.length > config.maxFileSizeKB * 1024 && quality > 10) {
        quality -= 5;
        output = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final outFile = File(
      '${dir.path}/resized_${rawW}x${rawH}_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await outFile.writeAsBytes(output);
    return outFile;
  }
}

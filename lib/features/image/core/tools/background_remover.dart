import 'dart:io';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class BackgroundRemover {
  static final _segmenter = SelfieSegmenter(
    enableRawSizeMask: false,
  );

  static Future<File> removeBackground({
    required File inputFile,
    double threshold = 0.5,
  }) async {
    final inputImage = InputImage.fromFile(inputFile);
    final mask = await _segmenter.processImage(inputImage);
    if (mask == null) throw Exception('Segmentation failed');

    final bytes = await inputFile.readAsBytes();
    final src = img.decodeImage(bytes);
    if (src == null) throw Exception('Could not decode image');

    final maskValues = mask.confidences;
    final output = img.Image(
      width: src.width,
      height: src.height,
      numChannels: 4,
    );

    final mW = mask.width;
    final mH = mask.height;

    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);

        final mX = (x * mW / src.width).floor().clamp(0, mW - 1);
        final mY = (y * mH / src.height).floor().clamp(0, mH - 1);
        final confidence = maskValues[mY * mW + mX];

        final alpha = confidence > threshold
            ? 255
            : (confidence / threshold * 255).round().clamp(0, 255);

        output.setPixel(
          x, y,
          img.ColorRgba8(
            pixel.r.toInt(), pixel.g.toInt(),
            pixel.b.toInt(), alpha,
          ),
        );
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final out = File(
      '${dir.path}/nobg_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await out.writeAsBytes(img.encodePng(output));
    return out;
  }

  static Future<File> replaceBackground({
    required File inputFile,
    required img.Color bgColor,
    double threshold = 0.5,
  }) async {
    final noBackground = await removeBackground(
      inputFile: inputFile,
      threshold: threshold,
    );
    final src = img.decodeImage(await noBackground.readAsBytes())!;
    final result = img.Image(width: src.width, height: src.height);

    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        final a = p.a / 255;
        result.setPixel(x, y, img.ColorRgba8(
          (p.r * a + bgColor.r * (1 - a)).round(),
          (p.g * a + bgColor.g * (1 - a)).round(),
          (p.b * a + bgColor.b * (1 - a)).round(),
          255,
        ));
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final out = File('${dir.path}/bg_replaced_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await out.writeAsBytes(img.encodeJpg(result));
    return out;
  }

  static void dispose() => _segmenter.close();
}

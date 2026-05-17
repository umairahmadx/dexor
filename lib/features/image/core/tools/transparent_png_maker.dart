import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class TransparentPngMaker {
  static Future<File> removeColorBackground({
    required File inputFile,
    required img.Color targetColor,
    int tolerance = 30,
    bool feather = true,
  }) async {
    final src = img.decodeImage(await inputFile.readAsBytes());
    if (src == null) throw Exception('Could not decode image');

    final out = img.Image(
      width: src.width, height: src.height, numChannels: 4,
    );

    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        final diff = _colorDiff(p, targetColor);

        int alpha;
        if (diff <= tolerance) {
          alpha = 0;
        } else if (feather && diff <= tolerance + 20) {
          alpha = ((diff - tolerance) / 20 * 255).round().clamp(0, 255);
        } else {
          alpha = 255;
        }

        out.setPixel(x, y,
          img.ColorRgba8(p.r.toInt(), p.g.toInt(), p.b.toInt(), alpha));
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/transparent_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(img.encodePng(out));
    return file;
  }

  static int _colorDiff(img.Pixel p, img.Color c) {
    final dr = (p.r - c.r).abs();
    final dg = (p.g - c.g).abs();
    final db = (p.b - c.b).abs();
    return ((dr + dg + db) / 3).round();
  }
}

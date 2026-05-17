import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageRotator {
  static Future<File> rotate({
    required File inputFile,
    required double degrees,
    bool expandCanvas = true,
  }) async {
    final decoded = img.decodeImage(await inputFile.readAsBytes());
    if (decoded == null) throw Exception('Could not decode image');

    final rotated = img.copyRotate(
      decoded,
      angle: degrees,
    );

    final dir = await getApplicationDocumentsDirectory();
    final out = File(
      '${dir.path}/rotated_${degrees.toInt()}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(img.encodeJpg(rotated));
    return out;
  }

  static Future<File> rotate90CW(File f)  => rotate(inputFile: f, degrees: 90);
  static Future<File> rotate90CCW(File f) => rotate(inputFile: f, degrees: -90);
  static Future<File> rotate180(File f)   => rotate(inputFile: f, degrees: 180);

  static Future<File> flipHorizontal(File inputFile) async {
    final src = img.decodeImage(await inputFile.readAsBytes())!;
    final flipped = img.flipHorizontal(src);
    final dir = await getApplicationDocumentsDirectory();
    final out = File('${dir.path}/flipped_h_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await out.writeAsBytes(img.encodeJpg(flipped));
    return out;
  }

  static Future<File> flipVertical(File inputFile) async {
    final src = img.decodeImage(await inputFile.readAsBytes())!;
    final flipped = img.flipVertical(src);
    final dir = await getApplicationDocumentsDirectory();
    final out = File('${dir.path}/flipped_v_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await out.writeAsBytes(img.encodeJpg(flipped));
    return out;
  }
}

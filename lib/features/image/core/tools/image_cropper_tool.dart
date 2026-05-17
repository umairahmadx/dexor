import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CropPreset {
  final String name;
  final double ratio;
  const CropPreset(this.name, this.ratio);

  static const square       = CropPreset('Square 1:1', 1);
  static const landscape16x9 = CropPreset('Landscape 16:9', 16 / 9);
  static const portrait9x16  = CropPreset('Portrait 9:16', 9 / 16);
  static const classic4x3   = CropPreset('Classic 4:3', 4 / 3);
  static const portrait4x5  = CropPreset('Portrait 4:5', 4 / 5);
}

class ImageCropperTool {
  static Future<File?> cropInteractive({
    required File inputFile,
    CropPreset? lockRatio,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: inputFile.path,
      aspectRatio: lockRatio == null
          ? null
          : CropAspectRatio(ratioX: lockRatio.ratio, ratioY: 1),
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: lockRatio != null,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: lockRatio != null,
        ),
      ],
    );
    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  static Future<File> cropProgrammatic({
    required File inputFile,
    required ui.Rect rect,
  }) async {
    final decoded = img.decodeImage(await inputFile.readAsBytes());
    if (decoded == null) throw Exception('Could not decode image');

    final cropped = img.copyCrop(
      decoded,
      x: rect.left.toInt().clamp(0, decoded.width - 1),
      y: rect.top.toInt().clamp(0, decoded.height - 1),
      width: rect.width.toInt().clamp(1, decoded.width),
      height: rect.height.toInt().clamp(1, decoded.height),
    );

    final dir = await getApplicationDocumentsDirectory();
    final out = File(
      '${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(img.encodeJpg(cropped));
    return out;
  }
}

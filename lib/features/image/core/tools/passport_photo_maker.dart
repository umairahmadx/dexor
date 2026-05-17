import 'dart:io';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PassportStandard {
  final String country;
  final String name;
  final double widthMm;
  final double heightMm;

  int get widthPx  => (widthMm  / 25.4 * 300).round();
  int get heightPx => (heightMm / 25.4 * 300).round();

  const PassportStandard({
    required this.country,
    required this.name,
    required this.widthMm,
    required this.heightMm,
  });

  static const standards = [
    PassportStandard(country: 'India',       name: 'Passport / Visa', widthMm: 35, heightMm: 45),
    PassportStandard(country: 'USA',         name: 'US Passport',     widthMm: 50.8, heightMm: 50.8),
    PassportStandard(country: 'UK',          name: 'UK Passport',     widthMm: 35, heightMm: 45),
    PassportStandard(country: 'Schengen EU', name: 'EU Visa',         widthMm: 35, heightMm: 45),
    PassportStandard(country: 'China',       name: 'China Passport',  widthMm: 33, heightMm: 48),
    PassportStandard(country: 'Canada',      name: 'Canada Passport', widthMm: 50, heightMm: 70),
    PassportStandard(country: 'Australia',   name: 'AU Passport',     widthMm: 35, heightMm: 45),
  ];
}

class PassportPhotoMaker {
  static Future<File> makePhoto({
    required File inputFile,
    required PassportStandard standard,
    ui.Rect? faceRegion,
    img.Color? backgroundColor,
  }) async {
    final src = img.decodeImage(await inputFile.readAsBytes());
    if (src == null) throw Exception('Could not decode image');

    final tW = standard.widthPx;
    final tH = standard.heightPx;

    img.Image cropped;
    if (faceRegion != null) {
      final fx = (faceRegion.left * src.width).toInt();
      final fy = (faceRegion.top * src.height).toInt();
      final fw = (faceRegion.width * src.width).toInt();
      final fh = (faceRegion.height * src.height).toInt();

      final padT = (fh * 0.3).toInt();
      final padB = (fh * 0.2).toInt();
      final padX = ((fw * (tW / tH) - fw) / 2).toInt();

      cropped = img.copyCrop(
        src,
        x: (fx - padX).clamp(0, src.width),
        y: (fy - padT).clamp(0, src.height),
        width: (fw + padX * 2).clamp(1, src.width),
        height: (fh + padT + padB).clamp(1, src.height),
      );
    } else {
      final srcRatio = src.width / src.height;
      final tgtRatio = tW / tH;
      int cropW, cropH;
      if (srcRatio > tgtRatio) {
        cropH = src.height;
        cropW = (cropH * tgtRatio).round();
      } else {
        cropW = src.width;
        cropH = (cropW / tgtRatio).round();
      }
      final ox = ((src.width - cropW) / 2).round();
      final oy = ((src.height - cropH) / 2).round();
      cropped = img.copyCrop(src, x: ox, y: oy, width: cropW, height: cropH);
    }

    final photo = img.copyResize(cropped, width: tW, height: tH);

    const sheetW = 1200;
    const sheetH = 1800;
    final sheet = img.Image(width: sheetW, height: sheetH);

    final bgColor = backgroundColor ?? img.ColorRgb8(255, 255, 255);
    for (int y = 0; y < sheetH; y++) {
      for (int x = 0; x < sheetW; x++) {
        sheet.setPixel(x, y, bgColor);
      }
    }

    const cols = 2;
    final rows = (sheetH / tH).floor().clamp(1, 4);
    final paddingX = ((sheetW - cols * tW) / (cols + 1)).round();
    final paddingY = ((sheetH - rows * tH) / (rows + 1)).round();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        img.compositeImage(
          sheet, photo,
          dstX: paddingX + col * (tW + paddingX),
          dstY: paddingY + row * (tH + paddingY),
        );
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final out = File(
      '${dir.path}/passport_${standard.country.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(img.encodeJpg(sheet, quality: 95));
    return out;
  }
}

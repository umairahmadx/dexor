import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';

class ColorPickerTool {
  static Future<Color> pickFromPixel({
    required File imageFile,
    required Offset normalizedPosition,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Could not decode image');

    final x = (normalizedPosition.dx * decoded.width).toInt().clamp(0, decoded.width - 1);
    final y = (normalizedPosition.dy * decoded.height).toInt().clamp(0, decoded.height - 1);
    final pixel = decoded.getPixel(x, y);

    return Color.fromARGB(
      pixel.a.toInt(),
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    );
  }

  static Future<List<Color>> dominantColors(
    File imageFile, {
    int count = 6,
  }) async {
    final provider = FileImage(imageFile);
    final palette = await PaletteGenerator.fromImageProvider(
      provider,
      maximumColorCount: count,
    );
    return palette.colors.toList();
  }

  static String toHex(Color c) {
    final argb = c.toARGB32();
    final r = ((argb >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
    final g = ((argb >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
    final b = (argb & 0xFF).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  static String toRgb(Color c) {
    final argb = c.toARGB32();
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return 'rgb($r, $g, $b)';
  }
}

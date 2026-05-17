import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class SocialPreset {
  final String platform;
  final String label;
  final int width;
  final int height;
  const SocialPreset(this.platform, this.label, this.width, this.height);
}

class SocialMediaResizer {
  static const presets = [
    SocialPreset('Instagram', 'Feed Square',        1080, 1080),
    SocialPreset('Instagram', 'Feed Portrait 4:5',  1080, 1350),
    SocialPreset('Instagram', 'Feed Landscape',     1080, 566),
    SocialPreset('Instagram', 'Story / Reel',       1080, 1920),
    SocialPreset('Facebook',  'Feed Post',          1200, 630),
    SocialPreset('Facebook',  'Cover Photo',        851,  315),
    SocialPreset('Facebook',  'Story',              1080, 1920),
    SocialPreset('Facebook',  'Profile Picture',    180,  180),
    SocialPreset('Twitter/X', 'Post Image',         1600, 900),
    SocialPreset('Twitter/X', 'Header',             1500, 500),
    SocialPreset('Twitter/X', 'Profile Picture',    400,  400),
    SocialPreset('YouTube',   'Thumbnail',          1280, 720),
    SocialPreset('YouTube',   'Channel Art',        2560, 1440),
    SocialPreset('YouTube',   'Channel Icon',       800,  800),
    SocialPreset('LinkedIn',  'Post Image',         1200, 627),
    SocialPreset('LinkedIn',  'Cover Photo',        1584, 396),
    SocialPreset('LinkedIn',  'Profile Picture',    400,  400),
    SocialPreset('WhatsApp',  'Profile Picture',    500,  500),
    SocialPreset('WhatsApp',  'Status',             1080, 1920),
    SocialPreset('Pinterest', 'Pin',                1000, 1500),
    SocialPreset('Pinterest', 'Square Pin',         1000, 1000),
    SocialPreset('TikTok',    'Video Cover',        1080, 1920),
    SocialPreset('TikTok',    'Profile Picture',    200,  200),
  ];

  static Future<File> resizeToPreset({
    required File inputFile,
    required SocialPreset preset,
    int quality = 90,
  }) async {
    final bytes = await inputFile.readAsBytes();
    final src = img.decodeImage(bytes);
    if (src == null) throw Exception('Could not decode image');

    final targetW = preset.width;
    final targetH = preset.height;

    final scaleX = targetW / src.width;
    final scaleY = targetH / src.height;
    final scale = scaleX > scaleY ? scaleX : scaleY;

    final scaledW = (src.width * scale).round();
    final scaledH = (src.height * scale).round();
    final scaled = img.copyResize(src, width: scaledW, height: scaledH);

    final cropX = ((scaledW - targetW) / 2).round();
    final cropY = ((scaledH - targetH) / 2).round();
    final cropped = img.copyCrop(
      scaled,
      x: cropX, y: cropY,
      width: targetW, height: targetH,
    );

    final dir = await getApplicationDocumentsDirectory();
    final label = preset.label.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final out = File(
      '${dir.path}/${preset.platform}_${label}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(img.encodeJpg(cropped, quality: quality));
    return out;
  }
}

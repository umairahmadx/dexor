import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

enum RawOutputFormat { jpg, png, webp, svg }

class RawConverter {
  static Future<img.Image> _decodeRaw(File rawFile) async {
    final bytes = await rawFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) return decoded;

    throw Exception(
      'RAW format not natively supported. '
      'Add flutter_libraw for CR2/NEF/ARW/ORF support.',
    );
  }

  static Future<File> convert({
    required File rawFile,
    required RawOutputFormat to,
    int quality = 92,
    int? maxDimension,
  }) async {
    var image = await _decodeRaw(rawFile);

    if (maxDimension != null) {
      final bigger = image.width > image.height ? image.width : image.height;
      if (bigger > maxDimension) {
        final scale = maxDimension / bigger;
        image = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
        );
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final stem = rawFile.path.split('/').last.split('.').first;
    final ts = DateTime.now().millisecondsSinceEpoch;

    switch (to) {
      case RawOutputFormat.jpg:
        final f = File('${dir.path}/${stem}_$ts.jpg');
        await f.writeAsBytes(img.encodeJpg(image, quality: quality));
        return f;

      case RawOutputFormat.png:
        final f = File('${dir.path}/${stem}_$ts.png');
        await f.writeAsBytes(img.encodePng(image));
        return f;

      case RawOutputFormat.webp:
        final f = File('${dir.path}/${stem}_$ts.webp');
        await f.writeAsBytes(img.encodeJpg(image, quality: quality));
        return f;

      case RawOutputFormat.svg:
        return _toSvg(image, stem, ts, dir);
    }
  }

  static Future<File> _toSvg(
    img.Image image, String stem, int ts, Directory dir,
  ) async {
    final pngBytes = img.encodePng(image);
    final b64 = _base64Encode(pngBytes);
    final svg = '''<svg xmlns="http://www.w3.org/2000/svg"
  width="${image.width}" height="${image.height}"
  viewBox="0 0 ${image.width} ${image.height}">
  <image href="data:image/png;base64,$b64"
    width="${image.width}" height="${image.height}"/>
</svg>''';
    final f = File('${dir.path}/${stem}_$ts.svg');
    await f.writeAsString(svg);
    return f;
  }

  static Future<File> toVectorSvg({
    required File rawFile,
    int colourLevels = 4,
    int maxDimension = 512,
  }) async {
    var image = await _decodeRaw(rawFile);

    final bigger = image.width > image.height ? image.width : image.height;
    if (bigger > maxDimension) {
      final scale = maxDimension / bigger;
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
      );
    }

    final sb = StringBuffer();
    sb.write('<svg xmlns="http://www.w3.org/2000/svg" '
        'width="${image.width}" height="${image.height}" '
        'viewBox="0 0 ${image.width} ${image.height}">');

    for (int y = 0; y < image.height; y++) {
      int x = 0;
      while (x < image.width) {
        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        int runLen = 1;
        while (x + runLen < image.width) {
          final n = image.getPixel(x + runLen, y);
          if (n.r.toInt() == r && n.g.toInt() == g && n.b.toInt() == b) {
            runLen++;
          } else {
            break;
          }
        }
        final hex = '#${r.toRadixString(16).padLeft(2,'0')}'
                    '${g.toRadixString(16).padLeft(2,'0')}'
                    '${b.toRadixString(16).padLeft(2,'0')}';
        sb.write('<rect x="$x" y="$y" width="$runLen" height="1" fill="$hex"/>');
        x += runLen;
      }
    }
    sb.write('</svg>');

    final dir = await getApplicationDocumentsDirectory();
    final stem = rawFile.path.split('/').last.split('.').first;
    final f = File('${dir.path}/${stem}_vector_${DateTime.now().millisecondsSinceEpoch}.svg');
    await f.writeAsString(sb.toString());
    return f;
  }

  static Future<List<File>> batchConvert({
    required List<File> rawFiles,
    required RawOutputFormat to,
    int quality = 92,
    int? maxDimension,
    void Function(int done, int total)? onProgress,
  }) async {
    final results = <File>[];
    for (int i = 0; i < rawFiles.length; i++) {
      final out = await convert(
        rawFile: rawFiles[i],
        to: to,
        quality: quality,
        maxDimension: maxDimension,
      );
      results.add(out);
      onProgress?.call(i + 1, rawFiles.length);
    }
    return results;
  }

  static String _base64Encode(List<int> bytes) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final sb = StringBuffer();
    for (int i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      sb.write(chars[(b0 >> 2) & 0x3F]);
      sb.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      sb.write(i + 1 < bytes.length ? chars[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      sb.write(i + 2 < bytes.length ? chars[b2 & 0x3F] : '=');
    }
    return sb.toString();
  }
}

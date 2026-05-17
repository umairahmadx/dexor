import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

enum ImageFormat { jpg, png, webp, bmp, gif, tiff, ico }

extension ImageFormatExt on ImageFormat {
  String get ext => name == 'jpg' ? 'jpg' : name;

  Uint8List encode(img.Image image, {int quality = 85}) {
    return switch (this) {
      ImageFormat.jpg  => Uint8List.fromList(img.encodeJpg(image, quality: quality)),
      ImageFormat.png  => Uint8List.fromList(img.encodePng(image)),
      ImageFormat.webp => Uint8List.fromList(img.encodeJpg(image, quality: quality)),
      ImageFormat.bmp  => Uint8List.fromList(img.encodeBmp(image)),
      ImageFormat.gif  => Uint8List.fromList(img.encodeGif(image)),
      ImageFormat.tiff => Uint8List.fromList(img.encodeTiff(image)),
      ImageFormat.ico  => Uint8List.fromList(img.encodeIco(image)),
    };
  }
}

class ImageConverter {
  static Future<File> convert({
    required File inputFile,
    required ImageFormat toFormat,
    int quality = 85,
  }) async {
    final bytes = await inputFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Could not decode image');

    final encoded = toFormat.encode(decoded, quality: quality);

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final out = File('${dir.path}/converted_$ts.${toFormat.ext}');
    await out.writeAsBytes(encoded);
    return out;
  }

  static Future<List<File>> convertBatch({
    required List<File> files,
    required ImageFormat toFormat,
    int quality = 85,
    void Function(int done, int total)? onProgress,
  }) async {
    final results = <File>[];
    for (int i = 0; i < files.length; i++) {
      results.add(await convert(
        inputFile: files[i],
        toFormat: toFormat,
        quality: quality,
      ));
      onProgress?.call(i + 1, files.length);
    }
    return results;
  }
}

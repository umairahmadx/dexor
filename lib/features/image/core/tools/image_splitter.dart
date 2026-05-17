import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class SplitResult {
  final List<File> tiles;
  final int cols;
  final int rows;
  SplitResult({required this.tiles, required this.cols, required this.rows});
}

class ImageSplitter {
  static Future<SplitResult> splitGrid({
    required File inputFile,
    required int cols,
    required int rows,
    String outputFormat = 'jpg',
    bool addGutter = false,
  }) async {
    final src = img.decodeImage(await inputFile.readAsBytes());
    if (src == null) throw Exception('Could not decode image');

    final tileW = (src.width / cols).floor();
    final tileH = (src.height / rows).floor();
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final tiles = <File>[];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final tile = img.copyCrop(
          src,
          x: col * tileW,
          y: row * tileH,
          width: tileW,
          height: tileH,
        );

        final ext = outputFormat == 'png' ? 'png' : 'jpg';
        final tileFile = File('${dir.path}/tile_r${row}_c${col}_$ts.$ext');
        final encoded = ext == 'png'
            ? img.encodePng(tile)
            : img.encodeJpg(tile, quality: 90);
        await tileFile.writeAsBytes(encoded);
        tiles.add(tileFile);
      }
    }

    return SplitResult(tiles: tiles, cols: cols, rows: rows);
  }

  static Future<SplitResult> splitInstagramGrid(File inputFile) async {
    final src = img.decodeImage(await inputFile.readAsBytes());
    if (src == null) throw Exception('Could not decode image');

    final side = src.width < src.height ? src.width : src.height;
    final square = img.copyCrop(
      src,
      x: ((src.width - side) / 2).round(),
      y: ((src.height - side) / 2).round(),
      width: side, height: side,
    );

    final dir = await getApplicationDocumentsDirectory();
    final tmpFile = File('${dir.path}/ig_sq_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tmpFile.writeAsBytes(img.encodeJpg(square));

    return splitGrid(inputFile: tmpFile, cols: 3, rows: 3);
  }

  static Future<List<File>> splitCustom({
    required File inputFile,
    List<int> xCuts = const [],
    List<int> yCuts = const [],
  }) async {
    final src = img.decodeImage(await inputFile.readAsBytes());
    if (src == null) throw Exception('Could not decode image');

    final xs = [0, ...xCuts, src.width];
    final ys = [0, ...yCuts, src.height];
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final results = <File>[];

    for (int row = 0; row < ys.length - 1; row++) {
      for (int col = 0; col < xs.length - 1; col++) {
        final tile = img.copyCrop(
          src,
          x: xs[col], y: ys[row],
          width: xs[col + 1] - xs[col],
          height: ys[row + 1] - ys[row],
        );
        final f = File('${dir.path}/custom_r${row}_c${col}_$ts.jpg');
        await f.writeAsBytes(img.encodeJpg(tile));
        results.add(f);
      }
    }
    return results;
  }
}

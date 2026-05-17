import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

class QrGeneratorWidget extends StatefulWidget {
  final String data;
  final double size;
  final Color foreground;
  final Color background;
  final GlobalKey _repaintKey = GlobalKey();

  QrGeneratorWidget({
    super.key,
    required this.data,
    this.size = 300,
    this.foreground = Colors.black,
    this.background = Colors.white,
  });

  Future<File> saveToFile() async {
    final boundary = _repaintKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  State<QrGeneratorWidget> createState() => _QrGeneratorWidgetState();
}

class _QrGeneratorWidgetState extends State<QrGeneratorWidget> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget._repaintKey,
      child: QrImageView(
        data: widget.data,
        version: QrVersions.auto,
        size: widget.size,
        backgroundColor: widget.background,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: widget.foreground,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: widget.foreground,
        ),
      ),
    );
  }
}

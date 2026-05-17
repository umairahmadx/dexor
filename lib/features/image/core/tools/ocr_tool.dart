import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String fullText;
  final List<OcrBlock> blocks;
  OcrResult({required this.fullText, required this.blocks});
}

class OcrBlock {
  final String text;
  final ui.Rect boundingBox;
  OcrBlock({required this.text, required this.boundingBox});
}

class OcrTool {
  static final _recogniser = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<OcrResult> recognise(File imageFile) async {
    final input = InputImage.fromFile(imageFile);
    final result = await _recogniser.processImage(input);

    final blocks = result.blocks.map((block) => OcrBlock(
      text: block.text,
      boundingBox: ui.Rect.fromLTRB(
        block.boundingBox.left.toDouble(),
        block.boundingBox.top.toDouble(),
        block.boundingBox.right.toDouble(),
        block.boundingBox.bottom.toDouble(),
      ),
    )).toList();

    return OcrResult(fullText: result.text, blocks: blocks);
  }

  static Future<File> toTextFile(File imageFile) async {
    final result = await recognise(imageFile);
    final dir = await Directory.systemTemp.createTemp();
    final out = File(
      '${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.txt',
    );
    await out.writeAsString(result.fullText);
    return out;
  }

  static void dispose() => _recogniser.close();
}

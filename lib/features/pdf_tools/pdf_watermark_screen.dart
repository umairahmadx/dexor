import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfWatermarkScreen extends StatefulWidget {
  const PdfWatermarkScreen({super.key});

  @override
  State<PdfWatermarkScreen> createState() => _PdfWatermarkScreenState();
}

class _PdfWatermarkScreenState extends State<PdfWatermarkScreen> {
  PlatformFile? _file;
  bool _isProcessing = false;
  final TextEditingController _watermarkCtrl = TextEditingController(
    text: 'CONFIDENTIAL',
  );

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _file = result.files.single;
      });
    }
  }

  Future<void> _addWatermark() async {
    if (_file == null || _file!.bytes == null) return;

    final text = _watermarkCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter watermark text.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final document = PdfDocument(inputBytes: _file!.bytes!);
      final font = PdfStandardFont(PdfFontFamily.helvetica, 40);

      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final graphics = page.graphics;

        final size = font.measureString(text);
        final state = graphics.save();

        graphics.setTransparency(0.3);
        graphics.translateTransform(
          page.getClientSize().width / 2,
          page.getClientSize().height / 2,
        );
        graphics.rotateTransform(-45);

        graphics.drawString(
          text,
          font,
          brush: PdfBrushes.red,
          bounds: Rect.fromLTWH(
            -size.width / 2,
            -size.height / 2,
            size.width,
            size.height,
          ),
        );

        graphics.restore(state);
      }

      final List<int> bytes = document.saveSync();
      document.dispose();

      await FileSaver.instance.saveFile(
        name: 'watermarked_${_file!.name}',
        bytes: Uint8List.fromList(bytes),

        mimeType: MimeType.pdf,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Watermark added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding watermark: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _watermarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Watermark')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickFile,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Select PDF File'),
            ),
            const SizedBox(height: 16),
            if (_file != null) ...[
              Card(
                child: ListTile(
                  title: Text(_file!.name),
                  subtitle: Text(
                    '${(_file!.size / 1024).toStringAsFixed(2)} KB',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _file = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _watermarkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Watermark Text',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: _addWatermark,
                  icon: const Icon(Icons.water_drop_outlined),
                  label: const Text('Add Watermark & Save'),
                ),
            ] else
              Center(
                child: Text(
                  'No file selected',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

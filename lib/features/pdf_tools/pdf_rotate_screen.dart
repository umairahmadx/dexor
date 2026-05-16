import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfRotateScreen extends StatefulWidget {
  const PdfRotateScreen({super.key});

  @override
  State<PdfRotateScreen> createState() => _PdfRotateScreenState();
}

class _PdfRotateScreenState extends State<PdfRotateScreen> {
  PlatformFile? _file;
  bool _isProcessing = false;
  PdfPageRotateAngle _angle = PdfPageRotateAngle.rotateAngle90;

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

  Future<void> _rotatePdf() async {
    if (_file == null || _file!.bytes == null) return;

    setState(() => _isProcessing = true);

    try {
      final document = PdfDocument(inputBytes: _file!.bytes!);

      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        // Accumulate rotation
        int current = page.rotation.index;
        int target = (current + _angle.index) % 4;
        page.rotation = PdfPageRotateAngle.values[target];
      }

      final List<int> bytes = document.saveSync();
      document.dispose();

      await FileSaver.instance.saveFile(
        name: 'rotated_${_file!.name}',
        bytes: Uint8List.fromList(bytes),

        mimeType: MimeType.pdf,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF rotated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rotating PDF: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rotate PDF')),
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
              DropdownButtonFormField<PdfPageRotateAngle>(
                initialValue: _angle,
                decoration: const InputDecoration(
                  labelText: 'Rotation Angle (Clockwise)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PdfPageRotateAngle.rotateAngle90,
                    child: Text('90 Degrees'),
                  ),
                  DropdownMenuItem(
                    value: PdfPageRotateAngle.rotateAngle180,
                    child: Text('180 Degrees'),
                  ),
                  DropdownMenuItem(
                    value: PdfPageRotateAngle.rotateAngle270,
                    child: Text('270 Degrees'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _angle = val);
                },
              ),
              const SizedBox(height: 16),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: _rotatePdf,
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Rotate & Save'),
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

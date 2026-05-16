import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfCompressScreen extends StatefulWidget {
  const PdfCompressScreen({super.key});

  @override
  State<PdfCompressScreen> createState() => _PdfCompressScreenState();
}

class _PdfCompressScreenState extends State<PdfCompressScreen> {
  PlatformFile? _file;
  bool _isProcessing = false;
  PdfCompressionLevel _compressionLevel = PdfCompressionLevel.best;

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

  Future<void> _compressPdf() async {
    if (_file == null || _file!.bytes == null) return;

    setState(() => _isProcessing = true);

    try {
      final document = PdfDocument(inputBytes: _file!.bytes!);
      document.compressionLevel = _compressionLevel;

      final List<int> bytes = document.saveSync();
      document.dispose();

      await FileSaver.instance.saveFile(
        name: 'compressed_${_file!.name}',
        bytes: Uint8List.fromList(bytes),

        mimeType: MimeType.pdf,
      );

      if (mounted) {
        final originalKb = _file!.size / 1024;
        final newKb = bytes.length / 1024;
        final saved = originalKb > newKb ? originalKb - newKb : 0;
        final savedPct = originalKb > 0
            ? (saved / originalKb * 100).toStringAsFixed(1)
            : '0';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved $savedPct% (${newKb.toStringAsFixed(1)} KB)'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error compressing PDF: $e')));
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
      appBar: AppBar(title: const Text('Compress PDF')),
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
              DropdownButtonFormField<PdfCompressionLevel>(
                initialValue: _compressionLevel,
                decoration: const InputDecoration(
                  labelText: 'Compression Level',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PdfCompressionLevel.best,
                    child: Text('Best (Maximum Compression)'),
                  ),
                  DropdownMenuItem(
                    value: PdfCompressionLevel.normal,
                    child: Text('Normal'),
                  ),
                  DropdownMenuItem(
                    value: PdfCompressionLevel.bestSpeed,
                    child: Text('Fastest (Least Compression)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _compressionLevel = val);
                },
              ),
              const SizedBox(height: 16),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: _compressPdf,
                  icon: const Icon(Icons.compress),
                  label: const Text('Compress & Save'),
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

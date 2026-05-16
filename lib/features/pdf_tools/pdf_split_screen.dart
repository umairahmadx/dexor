import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfSplitScreen extends StatefulWidget {
  const PdfSplitScreen({super.key});

  @override
  State<PdfSplitScreen> createState() => _PdfSplitScreenState();
}

class _PdfSplitScreenState extends State<PdfSplitScreen> {
  PlatformFile? _file;
  int _totalPages = 0;
  bool _isProcessing = false;
  final TextEditingController _startPageCtrl = TextEditingController(text: '1');
  final TextEditingController _endPageCtrl = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final doc = PdfDocument(inputBytes: result.files.single.bytes!);
      setState(() {
        _file = result.files.single;
        _totalPages = doc.pages.count;
        _startPageCtrl.text = '1';
        _endPageCtrl.text = _totalPages.toString();
      });
      doc.dispose();
    }
  }

  Future<void> _splitPdf() async {
    if (_file == null || _file!.bytes == null) return;

    final start = int.tryParse(_startPageCtrl.text);
    final end = int.tryParse(_endPageCtrl.text);

    if (start == null ||
        end == null ||
        start < 1 ||
        end > _totalPages ||
        start > end) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid page range.')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final sourceDoc = PdfDocument(inputBytes: _file!.bytes!);
      final newDoc = PdfDocument();

      for (int i = start - 1; i < end; i++) {
        final template = sourceDoc.pages[i].createTemplate();
        newDoc.pages.add().graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
        );
      }
      sourceDoc.dispose();

      final List<int> bytes = newDoc.saveSync();
      newDoc.dispose();

      await FileSaver.instance.saveFile(
        name: 'extracted_pages_$start-$end.pdf',
        bytes: Uint8List.fromList(bytes),

        mimeType: MimeType.pdf,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF extracted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error splitting PDF: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _startPageCtrl.dispose();
    _endPageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Split / Extract PDF')),
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
                  subtitle: Text('Total Pages: $_totalPages'),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _file = null;
                        _totalPages = 0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startPageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Start Page',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _endPageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'End Page',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: _splitPdf,
                  icon: const Icon(Icons.content_cut),
                  label: const Text('Extract Pages'),
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

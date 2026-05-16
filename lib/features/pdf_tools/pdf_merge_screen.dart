import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfMergeScreen extends StatefulWidget {
  const PdfMergeScreen({super.key});

  @override
  State<PdfMergeScreen> createState() => _PdfMergeScreenState();
}

class _PdfMergeScreenState extends State<PdfMergeScreen> {
  final List<PlatformFile> _files = [];
  bool _isProcessing = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _files.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  void _moveUp(int index) {
    if (index > 0) {
      setState(() {
        final item = _files.removeAt(index);
        _files.insert(index - 1, item);
      });
    }
  }

  void _moveDown(int index) {
    if (index < _files.length - 1) {
      setState(() {
        final item = _files.removeAt(index);
        _files.insert(index + 1, item);
      });
    }
  }

  Future<void> _mergePdfs() async {
    if (_files.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 PDF files to merge.'),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final document = PdfDocument();

      for (final file in _files) {
        if (file.bytes != null) {
          final sourceDoc = PdfDocument(inputBytes: file.bytes!);
          for (int i = 0; i < sourceDoc.pages.count; i++) {
            final template = sourceDoc.pages[i].createTemplate();
            document.pages.add().graphics.drawPdfTemplate(
              template,
              const Offset(0, 0),
            );
          }
          sourceDoc.dispose();
        }
      }

      final List<int> bytes = document.saveSync();
      document.dispose();

      await FileSaver.instance.saveFile(
        name: 'merged_document.pdf',
        bytes: Uint8List.fromList(bytes),

        mimeType: MimeType.pdf,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF merged and saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error merging PDF: $e')));
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
      appBar: AppBar(title: const Text('Merge PDFs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickFiles,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Select PDF Files'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _files.isEmpty
                  ? Center(
                      child: Text(
                        'No files selected',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(file.name),
                            subtitle: Text(
                              '${(file.size / 1024).toStringAsFixed(2)} KB',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_upward),
                                  onPressed: index > 0 && !_isProcessing
                                      ? () => _moveUp(index)
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_downward),
                                  onPressed:
                                      index < _files.length - 1 &&
                                          !_isProcessing
                                      ? () => _moveDown(index)
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: !_isProcessing
                                      ? () => _removeFile(index)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                onPressed: _files.length >= 2 ? _mergePdfs : null,
                icon: const Icon(Icons.merge_type),
                label: const Text('Merge PDFs'),
              ),
          ],
        ),
      ),
    );
  }
}

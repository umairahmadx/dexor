import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/widgets/shared_widgets.dart';

class PdfExtractScreen extends StatefulWidget {
  const PdfExtractScreen({super.key});

  @override
  State<PdfExtractScreen> createState() => _PdfExtractScreenState();
}

class _PdfExtractScreenState extends State<PdfExtractScreen> {
  PlatformFile? _file;
  bool _isProcessing = false;
  String _extractedText = '';

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _file = result.files.single;
        _extractedText = '';
      });
      _extractText();
    }
  }

  Future<void> _extractText() async {
    if (_file == null || _file!.bytes == null) return;

    setState(() => _isProcessing = true);

    try {
      final document = PdfDocument(inputBytes: _file!.bytes!);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();

      setState(() {
        _extractedText = text;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error extracting text: $e')));
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
      appBar: AppBar(
        title: const Text('Extract Text from PDF'),
        actions: [
          if (_extractedText.isNotEmpty)
            CopyButton(text: _extractedText, label: 'Copy All'),
        ],
      ),
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
            if (_file != null)
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
                        _extractedText = '';
                      });
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_extractedText.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: SelectableText(
                    _extractedText,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else if (_file != null)
              const Center(child: Text('No text found in PDF.')),
          ],
        ),
      ),
    );
  }
}

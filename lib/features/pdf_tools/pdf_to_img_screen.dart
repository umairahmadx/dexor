import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PdfToImgScreen extends StatefulWidget {
  const PdfToImgScreen({super.key});

  @override
  State<PdfToImgScreen> createState() => _PdfToImgScreenState();
}

class _PdfToImgScreenState extends State<PdfToImgScreen> {
  PlatformFile? _file;
  bool _isProcessing = false;

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

  Future<void> _extractImages() async {
    if (_file == null || _file!.bytes == null) return;

    setState(() => _isProcessing = true);

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Extracting embedded images is currently not supported by the underlying PDF library.',
            ),
          ),
        );
      }
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error extracting images: $e')));
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
      appBar: AppBar(title: const Text('Extract Images from PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This tool extracts embedded images from the PDF document. It does not convert entire pages to images.',
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: _extractImages,
                  icon: const Icon(Icons.image_search),
                  label: const Text('Extract Images as ZIP'),
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

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<PlatformFile> _files = [];
  bool _isProcessing = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
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

  Future<void> _convertToPdf() async {
    if (_files.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final document = PdfDocument();
      document.pageSettings.margins.all = 0;

      for (final file in _files) {
        if (file.bytes != null) {
          final image = PdfBitmap(file.bytes!);
          final page = document.pages.add();

          // Fit image to page while preserving aspect ratio
          final double pageWidth = page.getClientSize().width;
          final double pageHeight = page.getClientSize().height;

          final double widthRatio = pageWidth / image.width;
          final double heightRatio = pageHeight / image.height;
          final double ratio = widthRatio < heightRatio
              ? widthRatio
              : heightRatio;

          final double newWidth = image.width * ratio;
          final double newHeight = image.height * ratio;

          final double x = (pageWidth - newWidth) / 2;
          final double y = (pageHeight - newHeight) / 2;

          page.graphics.drawImage(
            image,
            Rect.fromLTWH(x, y, newWidth, newHeight),
          );
        }
      }

      final List<int> bytes = document.saveSync();
      document.dispose();

      await FileSaver.instance.saveFile(
        name: 'images_converted.pdf',
        bytes: Uint8List.fromList(bytes),

        mimeType: MimeType.pdf,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating PDF: $e')));
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
      appBar: AppBar(title: const Text('Images to PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickFiles,
              icon: const Icon(Icons.image),
              label: const Text('Select Images'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _files.isEmpty
                  ? Center(
                      child: Text(
                        'No images selected',
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
                            leading: file.bytes != null
                                ? Image.memory(
                                    file.bytes!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image),
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
                onPressed: _files.isNotEmpty ? _convertToPdf : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Convert to PDF'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/ocr_tool.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  String _recognizedText = '';

  Future<void> _pickFile() async {
    final file = await FileService.pickImage();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _recognize() async {
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final result = await OcrTool.recognise(_selectedFile!);
      setState(() => _recognizedText = result.fullText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('OCR - Text Recognition')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_selectedFile != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected File', style: theme.textTheme.labelMedium),
                    Text(_selectedFile!.path.split('/').last),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.image),
            label: const Text('Pick Image'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isProcessing || _selectedFile == null ? null : _recognize,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Recognize Text'),
          ),
          if (_recognizedText.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Recognized Text', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(_recognizedText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

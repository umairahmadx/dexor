import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/background_remover.dart';

class BackgroundRemoverScreen extends StatefulWidget {
  const BackgroundRemoverScreen({super.key});

  @override
  State<BackgroundRemoverScreen> createState() => _BackgroundRemoverScreenState();
}

class _BackgroundRemoverScreenState extends State<BackgroundRemoverScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  double _threshold = 0.5;

  Future<void> _pickFile() async {
    final file = await FileService.pickImage();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _removeBackground() async {
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final result = await BackgroundRemover.removeBackground(
        inputFile: _selectedFile!,
        threshold: _threshold,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Background removed: ${result.path}')),
        );
      }
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
      appBar: AppBar(title: const Text('Background Remover')),
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
          Text('Segmentation Threshold', style: theme.textTheme.titleMedium),
          Slider(
            value: _threshold,
            min: 0.1,
            max: 1.0,
            divisions: 18,
            label: _threshold.toStringAsFixed(2),
            onChanged: (v) => setState(() => _threshold = v),
          ),
          const SizedBox(height: 8),
          Text(
            'Lower = tighter around subject, Higher = more background preserved',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed:
                _isProcessing || _selectedFile == null ? null : _removeBackground,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Remove Background'),
          ),
        ],
      ),
    );
  }
}

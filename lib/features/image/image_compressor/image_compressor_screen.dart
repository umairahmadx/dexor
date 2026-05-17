import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/image_compressor.dart';

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  State<ImageCompressorScreen> createState() => _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  int _quality = 85;
  int? _targetSizeKB;
  String _outputFormat = 'jpg';

  Future<void> _pickFile() async {
    final file = await FileService.pickImage();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _compress() async {
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final config = CompressConfig(
        quality: _quality,
        targetSizeKB: _targetSizeKB,
      );
      final result = await ImageCompressor.compress(
        inputFile: _selectedFile!,
        config: config,
        outputFormat: _outputFormat,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compressed: ${result.path}')),
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
      appBar: AppBar(title: const Text('Image Compressor')),
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
          Text('Quality', style: theme.textTheme.titleMedium),
          Slider(
            value: _quality.toDouble(),
            min: 10,
            max: 100,
            divisions: 90,
            label: '$_quality%',
            onChanged: (v) => setState(() => _quality = v.toInt()),
          ),
          const SizedBox(height: 16),
          Text('Target Size (KB)', style: theme.textTheme.titleMedium),
          TextField(
            decoration: InputDecoration(
              labelText: 'Leave empty for no target',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (v) => setState(() => _targetSizeKB = int.tryParse(v)),
          ),
          const SizedBox(height: 16),
          Text('Output Format', style: theme.textTheme.titleMedium),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'jpg', label: Text('JPG')),
              ButtonSegment(value: 'png', label: Text('PNG')),
              ButtonSegment(value: 'webp', label: Text('WebP')),
            ],
            selected: {_outputFormat},
            onSelectionChanged: (v) => setState(() => _outputFormat = v.first),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isProcessing || _selectedFile == null ? null : _compress,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Compress'),
          ),
        ],
      ),
    );
  }
}

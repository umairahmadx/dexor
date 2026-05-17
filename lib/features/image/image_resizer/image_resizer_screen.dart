import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/image_resizer.dart';

class ImageResizerScreen extends StatefulWidget {
  const ImageResizerScreen({super.key});

  @override
  State<ImageResizerScreen> createState() => _ImageResizerScreenState();
}

class _ImageResizerScreenState extends State<ImageResizerScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  int? _width;
  int? _height;
  int _maxDimension = 8000;
  String _outputFormat = 'jpg';

  Future<void> _pickFile() async {
    final file = await FileService.pickImage();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _resize() async {
    if (_selectedFile == null || (_width == null && _height == null)) return;
    setState(() => _isProcessing = true);

    try {
      final config = ResizeConfig(
        targetWidth: _width,
        targetHeight: _height,
        maxDimension: _maxDimension,
      );
      final result = await ImageResizer.resize(
        inputFile: _selectedFile!,
        config: config,
        outputFormat: _outputFormat,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resized: ${result.path}')),
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
      appBar: AppBar(title: const Text('Image Resizer')),
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
          Text('Target Dimensions', style: theme.textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Width (px)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => setState(() => _width = int.tryParse(v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Height (px)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => setState(() => _height = int.tryParse(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Max Dimension', style: theme.textTheme.titleMedium),
          Slider(
            value: _maxDimension.toDouble(),
            min: 512,
            max: 8000,
            divisions: 15,
            label: '$_maxDimension px',
            onChanged: (v) => setState(() => _maxDimension = v.toInt()),
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
            onPressed: _isProcessing || _selectedFile == null
                ? null
                : _resize,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Resize'),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/image_rotator.dart';

class ImageRotatorScreen extends StatefulWidget {
  const ImageRotatorScreen({super.key});

  @override
  State<ImageRotatorScreen> createState() => _ImageRotatorScreenState();
}

class _ImageRotatorScreenState extends State<ImageRotatorScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  double _degrees = 0;

  Future<void> _pickFile() async {
    final file = await FileService.pickImage();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _rotate() async {
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final result = await ImageRotator.rotate(
        inputFile: _selectedFile!,
        degrees: _degrees,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rotated: ${result.path}')),
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
      appBar: AppBar(title: const Text('Image Rotator')),
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
          Text('Quick Actions', style: theme.textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _degrees = 90),
                icon: const Icon(Icons.rotate_right),
                label: const Text('90° CW'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _degrees = -90),
                icon: const Icon(Icons.rotate_left),
                label: const Text('90° CCW'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _degrees = 180),
                icon: const Icon(Icons.flip),
                label: const Text('180°'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Custom Angle', style: theme.textTheme.titleMedium),
          Slider(
            value: _degrees,
            min: -360,
            max: 360,
            divisions: 72,
            label: '${_degrees.toInt()}°',
            onChanged: (v) => setState(() => _degrees = v),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isProcessing || _selectedFile == null ? null : _rotate,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Rotate'),
          ),
        ],
      ),
    );
  }
}

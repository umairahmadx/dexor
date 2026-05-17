import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/image_converter.dart';

class ImageConverterScreen extends StatefulWidget {
  const ImageConverterScreen({super.key});

  @override
  State<ImageConverterScreen> createState() => _ImageConverterScreenState();
}

class _ImageConverterScreenState extends State<ImageConverterScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  ImageFormat _selectedFormat = ImageFormat.jpg;
  int _quality = 85;

  Future<void> _pickFile() async {
    final file = await FileService.pickImage();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _convert() async {
    if (_selectedFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final result = await ImageConverter.convert(
        inputFile: _selectedFile!,
        toFormat: _selectedFormat,
        quality: _quality,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Converted: ${result.path}')),
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
      appBar: AppBar(title: const Text('Image Converter')),
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
          Text('Output Format', style: theme.textTheme.titleMedium),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ImageFormat.values.map((format) {
              return ChoiceChip(
                selected: _selectedFormat == format,
                onSelected: (v) {
                  if (v) setState(() => _selectedFormat = format);
                },
                label: Text(format.name.toUpperCase()),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (_selectedFormat == ImageFormat.jpg ||
              _selectedFormat == ImageFormat.webp) ...[
            Text('Quality', style: theme.textTheme.titleMedium),
            Slider(
              value: _quality.toDouble(),
              min: 10,
              max: 100,
              divisions: 90,
              label: '$_quality%',
              onChanged: (v) => setState(() => _quality = v.toInt()),
            ),
            const SizedBox(height: 24),
          ],
          FilledButton(
            onPressed: _isProcessing || _selectedFile == null ? null : _convert,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Convert'),
          ),
        ],
      ),
    );
  }
}

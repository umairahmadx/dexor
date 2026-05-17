import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/social_media_resizer.dart';

class SocialMediaResizerScreen extends StatefulWidget {
  const SocialMediaResizerScreen({super.key});

  @override
  State<SocialMediaResizerScreen> createState() =>
      _SocialMediaResizerScreenState();
}

class _SocialMediaResizerScreenState extends State<SocialMediaResizerScreen> {
  File? _selectedFile;
  bool _isProcessing = false;
  SocialPreset? _selectedPreset;

  Future<void> _pickFile() async {
    final file = await FileService.pickImage();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _resize() async {
    if (_selectedFile == null || _selectedPreset == null) return;
    setState(() => _isProcessing = true);

    try {
      final result = await SocialMediaResizer.resizeToPreset(
        inputFile: _selectedFile!,
        preset: _selectedPreset!,
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
    final presetsByPlatform = <String, List<SocialPreset>>{};
    for (final preset in SocialMediaResizer.presets) {
      presetsByPlatform.putIfAbsent(preset.platform, () => []).add(preset);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Social Media Resizer')),
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
          Text('Select Platform', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final entry in presetsByPlatform.entries)
            ExpansionTile(
              title: Text(entry.key),
              children: [
                for (final preset in entry.value)
                  ListTile(
                    title: Text(preset.label),
                    subtitle: Text(
                      '${preset.width} × ${preset.height}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: _selectedPreset == preset
                        ? Icon(Icons.check,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () =>
                        setState(() => _selectedPreset = preset),
                  ),
              ],
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

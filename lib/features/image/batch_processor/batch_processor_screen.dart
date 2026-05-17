import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/file_service.dart';
import '../core/tools/batch_processor.dart';

class BatchProcessorScreen extends StatefulWidget {
  const BatchProcessorScreen({super.key});

  @override
  State<BatchProcessorScreen> createState() => _BatchProcessorScreenState();
}

class _BatchProcessorScreenState extends State<BatchProcessorScreen> {
  List<File> _selectedFiles = [];
  bool _isProcessing = false;
  int? _resizeWidth;
  int? _resizeHeight;
  int _quality = 85;
  String _outputFormat = 'jpg';
  List<BatchResult> _results = [];

  Future<void> _pickFiles() async {
    final files = await FileService.pickImages();
    if (files.isNotEmpty) {
      setState(() => _selectedFiles = files);
    }
  }

  Future<void> _process() async {
    if (_selectedFiles.isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      final config = BatchConfig(
        resizeWidth: _resizeWidth,
        resizeHeight: _resizeHeight,
        quality: _quality,
        outputFormat: _outputFormat,
      );
      final results = await BatchProcessor.process(
        files: _selectedFiles,
        config: config,
        onProgress: (done, total, last) {
          setState(() => _results = [..._results, last]);
        },
      );
      setState(() => _results = results);
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
      appBar: AppBar(title: const Text('Batch Processor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Selected Files: ${_selectedFiles.length}',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.image),
            label: const Text('Pick Multiple Images'),
          ),
          const SizedBox(height: 24),
          Text('Resize Options', style: theme.textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Width (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => setState(() => _resizeWidth = int.tryParse(v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Height (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (v) => setState(() => _resizeHeight = int.tryParse(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Quality', style: theme.textTheme.bodySmall),
          Slider(
            value: _quality.toDouble(),
            min: 10,
            max: 100,
            divisions: 90,
            label: '$_quality%',
            onChanged: (v) => setState(() => _quality = v.toInt()),
          ),
          const SizedBox(height: 16),
          Text('Output Format', style: theme.textTheme.bodySmall),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'jpg', label: Text('JPG')),
              ButtonSegment(value: 'png', label: Text('PNG')),
            ],
            selected: {_outputFormat},
            onSelectionChanged: (v) => setState(() => _outputFormat = v.first),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isProcessing || _selectedFiles.isEmpty ? null : _process,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Process All'),
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Results', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  title: Text(_results[i].sourceFile.path.split('/').last),
                  trailing: Icon(
                    r.success ? Icons.check_circle : Icons.error,
                    color: r.success ? Colors.green : Colors.red,
                  ),
                  subtitle: r.error != null ? Text(r.error!) : null,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

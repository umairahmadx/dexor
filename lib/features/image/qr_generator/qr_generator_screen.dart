import 'package:flutter/material.dart';
import '../core/tools/qr_generator.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  late QrGeneratorWidget _qrWidget;
  final _dataController = TextEditingController(text: 'https://example.com');

  @override
  void initState() {
    super.initState();
    _qrWidget = QrGeneratorWidget(data: _dataController.text);
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final file = await _qrWidget.saveToFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR saved: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('QR Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('QR Code Data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _dataController,
            decoration: InputDecoration(
              hintText: 'Enter text or URL',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (v) {
              setState(() {
                _qrWidget = QrGeneratorWidget(data: v);
              });
            },
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _qrWidget,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.download),
            label: const Text('Save QR Code'),
          ),
        ],
      ),
    );
  }
}

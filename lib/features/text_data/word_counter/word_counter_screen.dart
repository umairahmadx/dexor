import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class WordCounterScreen extends StatefulWidget {
  const WordCounterScreen({super.key});

  @override
  State<WordCounterScreen> createState() => _WordCounterScreenState();
}

class _WordCounterScreenState extends State<WordCounterScreen> {
  String _text = '';

  Map<String, int> _count() {
    final chars = _text.length;
    final words = _text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final lines = _text.split('\n').length;
    final sentences = _text.split(RegExp(r'[.!?]+')).where((s) => s.isNotEmpty).length;
    final paragraphs = _text.split(RegExp(r'\n\s*\n')).where((p) => p.isNotEmpty).length;

    return {'Characters': chars, 'Words': words, 'Lines': lines, 'Sentences': sentences, 'Paragraphs': paragraphs};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _count();

    return Scaffold(
      appBar: AppBar(title: const Text('Word Counter')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ThemedCodeEditor(
                initialValue: _text,
                onChanged: (value) => setState(() => _text = value),
                hint: 'Paste text here...',
                minLines: 10,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Wrap(
              spacing: 16,
              children: stats.entries.map((e) => _StatBit(label: e.key, value: e.value)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBit extends StatelessWidget {
  const _StatBit({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value.toString(), style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}


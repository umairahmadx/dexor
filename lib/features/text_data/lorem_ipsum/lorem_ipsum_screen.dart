import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class LoremIpsumScreen extends StatefulWidget {
  const LoremIpsumScreen({super.key});

  @override
  State<LoremIpsumScreen> createState() => _LoremIpsumScreenState();
}

class _LoremIpsumScreenState extends State<LoremIpsumScreen> {
  int _paragraphs = 3;
  String _generated = '';

  static const _loremText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
      'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';

  void _generate() {
    final paragraphs = <String>[];
    for (var i = 0; i < _paragraphs; i++) {
      const sentences = 5;
      final para = List.generate(sentences, (_) => _loremText).join(' ');
      paragraphs.add(para);
    }
    setState(() => _generated = paragraphs.join('\n\n'));
  }

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lorem Ipsum'),
        actions: [CopyButton(text: _generated, label: 'Copy')],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paragraphs', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _paragraphs.toDouble(),
                        min: 1,
                        max: 50,
                        divisions: 49,
                        label: '$_paragraphs',
                        onChanged: (value) => setState(() {
                          _paragraphs = value.toInt();
                          _generate();
                        }),
                      ),
                    ),
                    Text('$_paragraphs'),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _generate, child: const Text('Generate')),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ThemedCodeEditor(
                initialValue: _generated,
                onChanged: (_) {},
                readOnly: true,
                minLines: 10,
              ),
            ),
          ),
          ToolStatusBar(info: ['$_paragraphs paragraphs', '${_generated.split(RegExp(r'\\s+')).length} words']),
        ],
      ),
    );
  }
}


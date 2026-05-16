import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class UuidGeneratorScreen extends StatefulWidget {
  const UuidGeneratorScreen({super.key});

  @override
  State<UuidGeneratorScreen> createState() => _UuidGeneratorScreenState();
}

class _UuidGeneratorScreenState extends State<UuidGeneratorScreen> {
  String _selected = '';
  List<String> _generated = [];
  int _count = 1;
  bool _uppercase = false;
  bool _nohyphens = false;

  String _generateUuid() {
    // Simple UUID v4 implementation
    final random = List<int>.generate(16, (i) {
      final value = (DateTime.now().millisecondsSinceEpoch * (i + 1)) % 256;
      return value;
    });
    random[6] = (random[6] & 0x0f) | 0x40;
    random[8] = (random[8] & 0x3f) | 0x80;

    final parts = [
      random.sublist(0, 4).map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      random.sublist(4, 6).map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      random.sublist(6, 8).map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      random.sublist(8, 10).map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      random.sublist(10, 16).map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
    ];

    var uuid = parts.join('-');
    if (_nohyphens) uuid = uuid.replaceAll('-', '');
    if (_uppercase) uuid = uuid.toUpperCase();
    return uuid;
  }

  void _generate() {
    final count = _count.clamp(1, 1000);
    final list = [for (var i = 0; i < count; i++) _generateUuid()];
    setState(() {
      _generated = list;
      _selected = list.isNotEmpty ? list.join('\n') : '';
    });
  }

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UUID Generator'),
        actions: [
          CopyButton(text: _selected, label: 'Copy All'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Count', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _count.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: '$_count',
                        onChanged: (value) => setState(() => _count = value.toInt()),
                      ),
                    ),
                    Text('$_count'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Uppercase'),
                        value: _uppercase,
                        onChanged: (value) => setState(() {
                          _uppercase = value!;
                          _generate();
                        }),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('No hyphens'),
                        value: _nohyphens,
                        onChanged: (value) => setState(() {
                          _nohyphens = value!;
                          _generate();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _generate,
                  child: const Text('Generate'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ThemedCodeEditor(
                initialValue: _selected,
                onChanged: (_) {},
                readOnly: true,
                hint: 'Generated UUIDs will appear here',
                minLines: 10,
              ),
            ),
          ),
          ToolStatusBar(info: ['${_generated.length} UUIDs generated']),
        ],
      ),
    );
  }
}


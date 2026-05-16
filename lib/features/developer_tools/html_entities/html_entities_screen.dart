import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class HtmlEntitiesScreen extends StatefulWidget {
  const HtmlEntitiesScreen({super.key});

  @override
  State<HtmlEntitiesScreen> createState() => _HtmlEntitiesScreenState();
}

class _HtmlEntitiesScreenState extends State<HtmlEntitiesScreen> {
  String _input = '';
  String _output = '';
  bool _isEscaping = true;

  static const _entities = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  };

  void _transform() {
    if (_isEscaping) {
      _output = _input;
      _entities.forEach((key, value) {
        _output = _output.replaceAll(key, value);
      });
    } else {
      _output = _input;
      _entities.forEach((key, value) {
        _output = _output.replaceAll(value, key);
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML Entities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => setState(() {
              _isEscaping = !_isEscaping;
              _transform();
            }),
          ),
          CopyButton(text: _output, label: 'Copy'),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SplitPane(
              left: Padding(
                padding: const EdgeInsets.all(12),
                child: ThemedCodeEditor(
                  initialValue: _input,
                  onChanged: (value) {
                    _input = value;
                    _transform();
                  },
                  hint: _isEscaping ? 'Raw HTML...' : 'HTML Entities...',
                  minLines: 5,
                ),
              ),
              right: Padding(
                padding: const EdgeInsets.all(12),
                child: ThemedCodeEditor(
                  initialValue: _output,
                  onChanged: (_) {},
                  readOnly: true,
                  hint: _isEscaping ? 'Entities' : 'Raw HTML',
                  minLines: 5,
                ),
              ),
            ),
          ),
          ToolStatusBar(info: ['${_input.length} → ${_output.length}']),
        ],
      ),
    );
  }
}


import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class JsonFormatterScreen extends StatefulWidget {
  const JsonFormatterScreen({super.key});

  @override
  State<JsonFormatterScreen> createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends State<JsonFormatterScreen> {
  String _input = '';
  String _output = '';
  bool _isValid = false;
  int _indent = 2;

  void _format() {
    try {
      final json = jsonDecode(_input);
      final formatted = JsonEncoder.withIndent(' ' * _indent).convert(json);
      setState(() {
        _output = formatted;
        _isValid = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON: $e')),
      );
      setState(() => _isValid = false);
    }
  }

  void _minify() {
    try {
      final json = jsonDecode(_input);
      final minified = jsonEncode(json);
      setState(() {
        _output = minified;
        _isValid = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON: $e')),
      );
      setState(() => _isValid = false);
    }
  }

  void _clear() {
    setState(() {
      _input = '';
      _output = '';
      _isValid = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _isValid ? ['✓ Valid JSON', '${_input.length} bytes', '${_output.split('\n').length} lines'] : ['✗ Invalid JSON'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Formatter'),
        actions: [
          IconButton(
            tooltip: 'Format',
            onPressed: _format,
            icon: const Icon(Icons.format_shapes),
          ),
          IconButton(
            tooltip: 'Minify',
            onPressed: _minify,
            icon: const Icon(Icons.compress),
          ),
          CopyButton(text: _output, label: 'Copy'),
          IconButton(
            tooltip: 'Clear',
            onPressed: _clear,
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SplitPane(
              left: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Input', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ThemedCodeEditor(
                        initialValue: _input,
                        onChanged: (value) => setState(() => _input = value),
                        hint: 'Paste JSON here...',
                        minLines: 5,
                      ),
                    ),
                  ),
                ],
              ),
              right: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Output', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        DropdownButton<int>(
                          value: _indent,
                          onChanged: (value) => setState(() => _indent = value!),
                          items: const [
                            DropdownMenuItem(value: 2, child: Text('2 spaces')),
                            DropdownMenuItem(value: 4, child: Text('4 spaces')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ThemedCodeEditor(
                        initialValue: _output,
                        onChanged: (_) {},
                        readOnly: true,
                        hint: 'Formatted JSON will appear here',
                        minLines: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ToolStatusBar(info: statusInfo),
        ],
      ),
    );
  }
}


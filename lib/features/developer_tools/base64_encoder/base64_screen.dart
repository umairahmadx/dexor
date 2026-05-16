import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class Base64Screen extends StatefulWidget {
  const Base64Screen({super.key});

  @override
  State<Base64Screen> createState() => _Base64ScreenState();
}

class _Base64ScreenState extends State<Base64Screen> {
  String _input = '';
  String _output = '';
  bool _isEncoding = true;
  bool _urlSafe = false;

  void _transform() {
    try {
      setState(() {
        if (_isEncoding) {
          _output = base64Encode(utf8.encode(_input));
          if (_urlSafe) {
            _output = _output.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
          }
        } else {
          final decoded = _urlSafe ? _input.replaceAll('-', '+').replaceAll('_', '/') : _input;
          _output = utf8.decode(base64Decode(decoded));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Base64 Encoder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => setState(() => _isEncoding = !_isEncoding),
          ),
          CopyButton(text: _output, label: 'Copy'),
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
                    child: Text(_isEncoding ? 'Text' : 'Base64', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ThemedCodeEditor(
                        initialValue: _input,
                        onChanged: (value) {
                          setState(() => _input = value);
                          _transform();
                        },
                        hint: _isEncoding ? 'Paste text...' : 'Paste base64...',
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
                        Text(_isEncoding ? 'Base64' : 'Text', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('URL-safe'),
                          value: _urlSafe,
                          onChanged: (value) {
                            setState(() => _urlSafe = value);
                            _transform();
                          },
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
                        minLines: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ToolStatusBar(info: ['${_input.length} → ${_output.length} bytes']),
        ],
      ),
    );
  }
}

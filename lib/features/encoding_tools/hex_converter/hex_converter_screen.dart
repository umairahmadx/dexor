import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class HexConverterScreen extends StatefulWidget {
  const HexConverterScreen({super.key});

  @override
  State<HexConverterScreen> createState() => _HexConverterScreenState();
}

class _HexConverterScreenState extends State<HexConverterScreen> {
  String _input = '';
  String _output = '';
  bool _toHex = true;

  void _convert() {
    try {
      if (_toHex) {
        _output = _input.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join(' ');
      } else {
        final hex = _input.replaceAll(' ', '');
        final bytes = <int>[];
        for (var i = 0; i < hex.length; i += 2) {
          bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
        }
        _output = String.fromCharCodes(bytes);
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hex Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => setState(() => _toHex = !_toHex),
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
                    _convert();
                  },
                  hint: _toHex ? 'Text...' : 'Hex...',
                  minLines: 5,
                ),
              ),
              right: Padding(
                padding: const EdgeInsets.all(12),
                child: ThemedCodeEditor(
                  initialValue: _output,
                  onChanged: (_) {},
                  readOnly: true,
                  hint: _toHex ? 'Hex output' : 'Text output',
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


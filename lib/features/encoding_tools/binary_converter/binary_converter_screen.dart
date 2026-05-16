import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class BinaryConverterScreen extends StatefulWidget {
  const BinaryConverterScreen({super.key});

  @override
  State<BinaryConverterScreen> createState() => _BinaryConverterScreenState();
}

class _BinaryConverterScreenState extends State<BinaryConverterScreen> {
  String _input = '';
  String _output = '';
  bool _toBinary = true;

  void _convert() {
    try {
      if (_toBinary) {
        _output = _input.codeUnits.map((c) => c.toRadixString(2).padLeft(8, '0')).join(' ');
      } else {
        final binary = _input.replaceAll(' ', '');
        final bytes = <int>[];
        for (var i = 0; i < binary.length; i += 8) {
          bytes.add(int.parse(binary.substring(i, i + 8), radix: 2));
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
        title: const Text('Binary Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => setState(() => _toBinary = !_toBinary),
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
                  hint: _toBinary ? 'Text...' : 'Binary...',
                  minLines: 5,
                ),
              ),
              right: Padding(
                padding: const EdgeInsets.all(12),
                child: ThemedCodeEditor(
                  initialValue: _output,
                  onChanged: (_) {},
                  readOnly: true,
                  hint: _toBinary ? 'Binary output' : 'Text output',
                  minLines: 5,
                ),
              ),
            ),
          ),
          ToolStatusBar(info: ['${_input.length} bytes']),
        ],
      ),
    );
  }
}


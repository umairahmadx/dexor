import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class StringHasherScreen extends StatefulWidget {
  const StringHasherScreen({super.key});

  @override
  State<StringHasherScreen> createState() => _StringHasherScreenState();
}

class _StringHasherScreenState extends State<StringHasherScreen> {
  String _input = '';
  String _selected = 'SHA-256';

  String _hash() {
    switch (_selected) {
      case 'MD5':
        return md5.convert(_input.codeUnits).toString();
      case 'SHA-1':
        return sha1.convert(_input.codeUnits).toString();
      case 'SHA-256':
        return sha256.convert(_input.codeUnits).toString();
      case 'SHA-512':
        return sha512.convert(_input.codeUnits).toString();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hash = _hash();

    return Scaffold(
      appBar: AppBar(
        title: const Text('String Hasher'),
        actions: [
          if (hash.isNotEmpty) CopyButton(text: hash, label: 'Copy Hash'),
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
                    child: Text('Text', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ThemedCodeEditor(
                        initialValue: _input,
                        onChanged: (value) => setState(() => _input = value),
                        hint: 'Enter text to hash...',
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
                    child: DropdownButton<String>(
                      value: _selected,
                      isExpanded: true,
                      onChanged: (value) => setState(() => _selected = value!),
                      items: const [
                        DropdownMenuItem(value: 'MD5', child: Text('MD5')),
                        DropdownMenuItem(value: 'SHA-1', child: Text('SHA-1')),
                        DropdownMenuItem(value: 'SHA-256', child: Text('SHA-256')),
                        DropdownMenuItem(value: 'SHA-512', child: Text('SHA-512')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ThemedCodeEditor(
                        initialValue: hash,
                        onChanged: (_) {},
                        readOnly: true,
                        hint: 'Hash output',
                        minLines: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
           ToolStatusBar(info: ['${_input.length} bytes', hash.isNotEmpty ? '${hash.substring(0, 16)}...' : '']),
        ],
      ),
    );
  }
}


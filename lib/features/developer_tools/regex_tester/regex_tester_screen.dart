import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class RegexTesterScreen extends StatefulWidget {
  const RegexTesterScreen({super.key});

  @override
  State<RegexTesterScreen> createState() => _RegexTesterScreenState();
}

class _RegexTesterScreenState extends State<RegexTesterScreen> {
  String _pattern = '';
  String _input = '';
  String _output = '';
  bool _caseInsensitive = false;
  bool _multiline = false;
  List<String> _matches = [];

  void _test() {
    try {
      final regexp = RegExp(_pattern, caseSensitive: !_caseInsensitive, multiLine: _multiline);
      final matches = regexp.allMatches(_input);

      setState(() {
        _matches = matches.map((m) => m.group(0) ?? '').toList();
        _output = 'Found ${matches.length} match${matches.length == 1 ? '' : 'es'}';
      });
    } catch (e) {
      setState(() => _output = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Regex Tester')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) {
                _pattern = v;
                _test();
              },
              decoration: InputDecoration(
                hintText: 'Enter regex pattern...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: CheckboxListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Case insensitive'),
                    value: _caseInsensitive,
                    onChanged: (v) => setState(() {
                      _caseInsensitive = v!;
                      _test();
                    }),
                  ),
                ),
                Expanded(
                  child: CheckboxListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Multiline'),
                    value: _multiline,
                    onChanged: (v) => setState(() {
                      _multiline = v!;
                      _test();
                    }),
                  ),
                ),
              ],
            ),
          ),
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
                        onChanged: (value) {
                          _input = value;
                          _test();
                        },
                        hint: 'Test string...',
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
                    child: Text('Matches', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                    child: _matches.isEmpty
                        ? Center(child: Text(_output))
                        : ListView.builder(
                            itemCount: _matches.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('[${i + 1}] ${_matches[i]}'),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          ToolStatusBar(info: [_output]),
        ],
      ),
    );
  }
}


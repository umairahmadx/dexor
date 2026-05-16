import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class YamlJsonScreen extends StatefulWidget {
  const YamlJsonScreen({super.key});

  @override
  State<YamlJsonScreen> createState() => _YamlJsonScreenState();
}

class _YamlJsonScreenState extends State<YamlJsonScreen> {
  String _yaml = '';
  String _json = '';
  bool _toJson = true;

  void _convert() {
    try {
      if (_toJson) {
        // Simple YAML-like to JSON converter (not a full YAML parser)
        final json = _simpleYamlToJson(_yaml);
        _json = JsonEncoder.withIndent('  ').convert(json);
      } else {
        final parsed = jsonDecode(_json);
        _yaml = _jsonToYaml(parsed, 0);
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  dynamic _simpleYamlToJson(String yaml) {
    // Very basic YAML-to-JSON conversion
    final lines = yaml.split('\n');
    final result = <String, dynamic>{};

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final content = line.trim();

      if (content.contains(':')) {
        final parts = content.split(':');
        final key = parts[0].trim();
        final value = parts.sublist(1).join(':').trim();
        result[key] = value.isEmpty ? null : _parseValue(value);
      }
    }

    return result.isEmpty ? yaml : result;
  }

  dynamic _parseValue(String value) {
    if (value == 'null') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (value.startsWith('"') && value.endsWith('"')) return value.substring(1, value.length - 1);
    if (int.tryParse(value) != null) return int.parse(value);
    if (double.tryParse(value) != null) return double.parse(value);
    return value;
  }

  String _jsonToYaml(dynamic data, int indent) {
    final prefix = ' ' * indent;

    if (data is Map) {
      return data.entries.map((e) => '$prefix${e.key}: ${_jsonToYaml(e.value, indent + 2)}').join('\n');
    } else if (data is List) {
      return data.map((item) => '$prefix- ${_jsonToYaml(item, indent + 2)}').join('\n');
    } else {
      return data.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YAML ↔ JSON'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => setState(() {
              _toJson = !_toJson;
              _convert();
            }),
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
                    child: Text(_toJson ? 'YAML' : 'JSON', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ThemedCodeEditor(
                        initialValue: _yaml,
                        onChanged: (value) {
                          _yaml = value;
                          _convert();
                        },
                        hint: _toJson ? 'Paste YAML...' : 'Paste JSON...',
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
                    child: Text(_toJson ? 'JSON' : 'YAML', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ThemedCodeEditor(
                        initialValue: _json,
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
          ToolStatusBar(info: ['Converted']),
        ],
      ),
    );
  }
}


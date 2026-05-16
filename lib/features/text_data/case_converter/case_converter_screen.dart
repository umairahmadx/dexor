import 'package:flutter/material.dart';


class CaseConverterScreen extends StatefulWidget {
  const CaseConverterScreen({super.key});

  @override
  State<CaseConverterScreen> createState() => _CaseConverterScreenState();
}

class _CaseConverterScreenState extends State<CaseConverterScreen> {
  String _input = '';

  Map<String, String> _convert() {
    return {
      'lowercase': _input.toLowerCase(),
      'UPPERCASE': _input.toUpperCase(),
      'Title Case': _input.split(' ').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' '),
      'camelCase': _toCamelCase(_input),
      'snake_case': _toSnakeCase(_input),
      'kebab-case': _toKebabCase(_input),
      'PascalCase': _toPascalCase(_input),
    };
  }

  String _toCamelCase(String str) {
    final words = str.split(RegExp(r'[\s_-]+'));
    return words.asMap().entries.map((e) => e.key == 0 ? e.value.toLowerCase() : (e.value.isEmpty ? '' : e.value[0].toUpperCase() + e.value.substring(1).toLowerCase())).join();
  }

  String _toSnakeCase(String str) {
    return str.replaceAllMapped(RegExp(r'[a-z][A-Z]'), (m) => '${m.group(0)![0]}_${m.group(0)![1]}').toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  }

  String _toKebabCase(String str) {
    return str.replaceAllMapped(RegExp(r'[a-z][A-Z]'), (m) => '${m.group(0)![0]}-${m.group(0)![1]}').toLowerCase().replaceAll(RegExp(r'[\s_]+'), '-');
  }

  String _toPascalCase(String str) {
    final words = str.split(RegExp(r'[\s_-]+'));
    return words.map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final conversions = _convert();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Converter'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (value) => setState(() => _input = value),
            decoration: InputDecoration(
              hintText: 'Enter text...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          ...conversions.entries.map((e) => _ConversionCard(label: e.key, value: e.value)),
        ],
      ),
    );
  }
}

class _ConversionCard extends StatelessWidget {
  const _ConversionCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


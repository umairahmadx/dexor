import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class UrlParserScreen extends StatefulWidget {
  const UrlParserScreen({super.key});

  @override
  State<UrlParserScreen> createState() => _UrlParserScreenState();
}

class _UrlParserScreenState extends State<UrlParserScreen> {
  String _url = '';
  Uri? _parsed;
  String? _error;

  void _parse() {
    if (_url.isEmpty) {
      setState(() {
        _parsed = null;
        _error = null;
      });
      return;
    }
    try {
      final uri = Uri.parse(_url);
      setState(() {
        _parsed = uri;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _parsed = null;
        _error = e.toString();
      });
    }
  }

  String _safeOrigin(Uri uri) {
    try {
      return uri.origin;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Parser'),
        actions: [
          if (_parsed != null) CopyButton(text: _url, label: 'Copy'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (value) {
              _url = value;
              _parse();
            },
            decoration: InputDecoration(
              hintText: 'Paste URL here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Center(
              child: Text('Invalid URL: $_error', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red)),
            )
          else if (_parsed != null && _parsed!.hasScheme) ...[
            _UrlBit(label: 'Scheme', value: _parsed!.scheme),
            _UrlBit(label: 'Host', value: _parsed!.host),
            _UrlBit(label: 'Port', value: _parsed!.hasPort ? _parsed!.port.toString() : ''),
            _UrlBit(label: 'Path', value: _parsed!.path),
            _UrlBit(label: 'Query', value: _parsed!.query),
            _UrlBit(label: 'Fragment', value: _parsed!.fragment),
            _UrlBit(label: 'Origin', value: _safeOrigin(_parsed!)),
            if (_parsed!.queryParameters.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Query Parameters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ..._parsed!.queryParameters.entries.map((e) => _QueryBit(param: e.key, value: e.value)),
            ],
          ] else
            Center(
              child: Text('Enter a URL to parse', style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _UrlBit extends StatelessWidget {
  const _UrlBit({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueryBit extends StatelessWidget {
  const _QueryBit({required this.param, required this.value});

  final String param;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(param, style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(
            flex: 2,
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

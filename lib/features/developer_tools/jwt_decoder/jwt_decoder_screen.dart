import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class JwtDecoderScreen extends StatefulWidget {
  const JwtDecoderScreen({super.key});

  @override
  State<JwtDecoderScreen> createState() => _JwtDecoderScreenState();
}

class _JwtDecoderScreenState extends State<JwtDecoderScreen> {
  String _token = '';
  String _header = '';
  String _payload = '';
  String _signature = '';
  bool _isValid = false;

  void _decode() {
    try {
      final parts = _token.split('.');
      if (parts.length != 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JWT must have 3 parts separated by dots')),
        );
        return;
      }

      _header = jsonEncode(jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[0])))));
      _payload = jsonEncode(jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))));
      _signature = parts[2];

      setState(() => _isValid = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isValid = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('JWT Decoder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (value) {
              _token = value;
              _decode();
            },
            decoration: InputDecoration(
              hintText: 'Paste JWT token...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          if (_isValid) ...[
            _JwtCard(title: 'Header', content: _header),
            _JwtCard(title: 'Payload', content: _payload),
            _JwtCard(title: 'Signature', content: _signature),
          ] else
            Center(
              child: Text('Enter a valid JWT token', style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _JwtCard extends StatelessWidget {
  const _JwtCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  CopyButton(text: content, label: 'Copy'),
                ],
              ),
              const SizedBox(height: 8),
              Text(content, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }
}


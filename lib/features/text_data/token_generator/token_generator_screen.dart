import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  int _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;
  String _generated = '';

  void _generate() {
    final chars = <String>[];
    if (_uppercase) chars.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
    if (_lowercase) chars.addAll('abcdefghijklmnopqrstuvwxyz'.split(''));
    if (_numbers) chars.addAll('0123456789'.split(''));
    if (_symbols) chars.addAll('!@#\$%^&*()_+-=[]{}|;:,.<>?'.split(''));

    final random = Random.secure();
    final password = List.generate(_length, (_) => chars[random.nextInt(chars.length)]).join();
    setState(() => _generated = password);
  }

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Generator'),
        actions: [CopyButton(text: _generated, label: 'Copy')],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            readOnly: true,
            controller: TextEditingController(text: _generated),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Length'),
                    Slider(
                      value: _length.toDouble(),
                      min: 4,
                      max: 64,
                      divisions: 60,
                      label: '$_length',
                      onChanged: (value) => setState(() {
                        _length = value.toInt();
                        _generate();
                      }),
                    ),
                  ],
                ),
              ),
              Text('$_length', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile.adaptive(
            title: const Text('Uppercase'),
            value: _uppercase,
            onChanged: (v) => setState(() {
              _uppercase = v!;
              _generate();
            }),
          ),
          CheckboxListTile.adaptive(
            title: const Text('Lowercase'),
            value: _lowercase,
            onChanged: (v) => setState(() {
              _lowercase = v!;
              _generate();
            }),
          ),
          CheckboxListTile.adaptive(
            title: const Text('Numbers'),
            value: _numbers,
            onChanged: (v) => setState(() {
              _numbers = v!;
              _generate();
            }),
          ),
          CheckboxListTile.adaptive(
            title: const Text('Symbols'),
            value: _symbols,
            onChanged: (v) => setState(() {
              _symbols = v!;
              _generate();
            }),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _generate, child: const Text('Generate')),
        ],
      ),
    );
  }
}

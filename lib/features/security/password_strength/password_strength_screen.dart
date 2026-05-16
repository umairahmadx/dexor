import 'dart:math' as math;

import 'package:flutter/material.dart';


class PasswordStrengthScreen extends StatefulWidget {
  const PasswordStrengthScreen({super.key});

  @override
  State<PasswordStrengthScreen> createState() => _PasswordStrengthScreenState();
}

class _PasswordStrengthScreenState extends State<PasswordStrengthScreen> {
  String _password = '';
  bool _showPassword = false;

  Map<String, bool> _getCharacteristics() {
    return {
      'Has lowercase (a-z)': RegExp(r'[a-z]').hasMatch(_password),
      'Has uppercase (A-Z)': RegExp(r'[A-Z]').hasMatch(_password),
      'Has digits (0-9)': RegExp(r'[0-9]').hasMatch(_password),
      'Has special chars': RegExp(r'[!@#$%^&*()_+=\[\]{};:,.<>?/~|\\]').hasMatch(_password),
      'Length >= 8': _password.length >= 8,
      'Length >= 12': _password.length >= 12,
      'Length >= 16': _password.length >= 16,
    };
  }

  double _calculateEntropy() {
    if (_password.isEmpty) return 0;

    int charsetSize = 0;
    if (RegExp(r'[a-z]').hasMatch(_password)) charsetSize += 26;
    if (RegExp(r'[A-Z]').hasMatch(_password)) charsetSize += 26;
    if (RegExp(r'[0-9]').hasMatch(_password)) charsetSize += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(_password)) charsetSize += 32;

    if (charsetSize == 0) return 0;

    // Log2(charset_size) * password_length
    return (math.log(charsetSize) / math.ln2) * _password.length;
  }

  String _getStrengthLabel(double entropy) {
    if (entropy < 30) return 'Very Weak';
    if (entropy < 50) return 'Weak';
    if (entropy < 70) return 'Fair';
    if (entropy < 90) return 'Good';
    if (entropy < 120) return 'Strong';
    return 'Very Strong';
  }

  Color _getStrengthColor(double entropy) {
    if (entropy < 30) return Colors.red;
    if (entropy < 50) return Colors.orange;
    if (entropy < 70) return Colors.yellow;
    if (entropy < 90) return Colors.lime;
    if (entropy < 120) return Colors.green;
    return Colors.lightGreen;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entropy = _calculateEntropy();
    final characteristics = _getCharacteristics();
    final meetsMinimum = characteristics.values.where((v) => v).length >= 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Strength'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Password input
          TextField(
            onChanged: (value) => setState(() => _password = value),
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter a password...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_password.isNotEmpty) ...[
            // Strength indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Strength', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (entropy / 120).clamp(0, 1).toDouble(),
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(_getStrengthColor(entropy)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getStrengthLabel(entropy),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStrengthColor(entropy),
                          ),
                        ),
                        Text('${entropy.toStringAsFixed(1)} bits'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistics', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    _StatisticRow(label: 'Length', value: '${_password.length} characters'),
                    _StatisticRow(
                      label: 'Unique Characters',
                      value: _password.split('').toSet().length.toString(),
                    ),
                    _StatisticRow(
                      label: 'Requirement Met',
                      value: '${characteristics.values.where((v) => v).length}/7',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Characteristics
            Text('Character Set Requirements', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...characteristics.entries.map((e) => _CharacteristicItem(
              label: e.key,
              met: e.value,
            )),

            const SizedBox(height: 16),
            Card(
              color: meetsMinimum ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      meetsMinimum ? Icons.check_circle : Icons.warning_rounded,
                      color: meetsMinimum ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meetsMinimum
                            ? 'Meets minimum security requirements'
                            : 'Does not meet minimum security requirements',
                        style: TextStyle(
                          color: meetsMinimum ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Center(
              child: Text('Enter a password to check its strength', style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _StatisticRow extends StatelessWidget {
  const _StatisticRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CharacteristicItem extends StatelessWidget {
  const _CharacteristicItem({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            color: met ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class ContrastCheckerScreen extends StatefulWidget {
  const ContrastCheckerScreen({super.key});

  @override
  State<ContrastCheckerScreen> createState() => _ContrastCheckerScreenState();
}

class _ContrastCheckerScreenState extends State<ContrastCheckerScreen> {
  String _foregroundHex = 'FFFFFF';
  String _backgroundHex = '000000';
  Color _fgColor = const Color(0xFFFFFFFF);
  Color _bgColor = const Color(0xFF000000);

  void _updateForeground(String hex) {
    try {
      final clean = hex.replaceAll('#', '').toUpperCase();
      if (clean.length == 6) {
        final color = Color(int.parse('FF$clean', radix: 16));
        setState(() {
          _fgColor = color;
          _foregroundHex = clean;
        });
      }
    } catch (e) {
      // Invalid input
    }
  }

  void _updateBackground(String hex) {
    try {
      final clean = hex.replaceAll('#', '').toUpperCase();
      if (clean.length == 6) {
        final color = Color(int.parse('FF$clean', radix: 16));
        setState(() {
          _bgColor = color;
          _backgroundHex = clean;
        });
      }
    } catch (e) {
      // Invalid input
    }
  }

  double _getRelativeLuminance(Color color) {
    final r = _linearize((color.r * 255.0).round().clamp(0, 255) / 255);
    final g = _linearize((color.g * 255.0).round().clamp(0, 255) / 255);
    final b = _linearize((color.b * 255.0).round().clamp(0, 255) / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double _linearize(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  double _getContrastRatio() {
    final l1 = _getRelativeLuminance(_fgColor);
    final l2 = _getRelativeLuminance(_bgColor);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  Map<String, bool> _getWcagCompliance(double ratio) {
    return {
      'WCAG AA (4.5:1)': ratio >= 4.5,
      'WCAG AAA (7:1)': ratio >= 7.0,
      'WCAG AA Large (3:1)': ratio >= 3.0,
    };
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = _getContrastRatio();
    final wcag = _getWcagCompliance(ratio);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrast Checker'),
        actions: [
          CopyButton(text: '${ratio.toStringAsFixed(2)}:1', label: 'Copy Ratio'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sample Text',
                  style: TextStyle(
                    color: _fgColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contrast ratio
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contrast Ratio', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    '${ratio.toStringAsFixed(2)}:1',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // WCAG compliance
          ...wcag.entries.map((e) => _ComplianceCard(
            label: e.key,
            compliant: e.value,
          )),

          const SizedBox(height: 16),

          // Color inputs
          Text('Colors', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          TextField(
            onChanged: _updateForeground,
            decoration: InputDecoration(
              labelText: 'Foreground Color',
              prefixText: '#',
              hintText: 'FFFFFF',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
            controller: TextEditingController(text: _foregroundHex),
          ),
          const SizedBox(height: 12),

          TextField(
            onChanged: _updateBackground,
            decoration: InputDecoration(
              labelText: 'Background Color',
              prefixText: '#',
              hintText: '000000',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
            controller: TextEditingController(text: _backgroundHex),
          ),
          const SizedBox(height: 16),

          // Quick presets
          Text('Quick Presets', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PresetButton(
                  label: 'Black on White',
                  onPressed: () {
                    _updateForeground('000000');
                    _updateBackground('FFFFFF');
                  },
                ),
                const SizedBox(width: 8),
                _PresetButton(
                  label: 'White on Black',
                  onPressed: () {
                    _updateForeground('FFFFFF');
                    _updateBackground('000000');
                  },
                ),
                const SizedBox(width: 8),
                _PresetButton(
                  label: 'Blue on White',
                  onPressed: () {
                    _updateForeground('0000FF');
                    _updateBackground('FFFFFF');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.label, required this.compliant});

  final String label;
  final bool compliant;

  @override
  Widget build(BuildContext context) {
    final color = compliant ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(compliant ? Icons.check_circle : Icons.cancel, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
              Text(
                compliant ? 'Pass' : 'Fail',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}


import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  String _hexInput = 'FF5733';
  Color _selectedColor = const Color(0xFFFF5733);

  void _parseHex(String input) {
    try {
      final clean = input.replaceAll('#', '').toUpperCase();
      if (clean.length != 6 && clean.length != 8) return;

      final hex = clean.length == 6 ? 'FF$clean' : clean;
      final color = Color(int.parse(hex, radix: 16));

      setState(() {
        _selectedColor = color;
        _hexInput = clean.length == 8 ? clean : clean;
      });
    } catch (e) {
      // Invalid input
    }
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255.0).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }

  String _colorToRgb(Color color) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    return 'rgb($r, $g, $b)';
  }

  String _colorToHsl(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);

    final l = (max + min) / 2;
    final d = max - min;

    if (d == 0) {
      return 'hsl(0, 0%, ${(l * 100).toStringAsFixed(1)}%)';
    }

    final s = d / (1 - (2 * l - 1).abs());
    final h = switch ((max)) {
      _ when max == r => (60 * (((g - b) / d) % 6) + 360) % 360,
      _ when max == g => (60 * (((b - r) / d) + 2)) % 360,
      _ => (60 * (((r - g) / d) + 4)) % 360,
    };

    return 'hsl(${h.toStringAsFixed(1)}, ${(s * 100).toStringAsFixed(1)}%, ${(l * 100).toStringAsFixed(1)}%)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Picker'),
        actions: [
          CopyButton(text: '#${_colorToHex(_selectedColor)}', label: 'Copy'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Color preview
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
          ),
          const SizedBox(height: 24),

          // Hex input
          TextField(
            onChanged: _parseHex,
            decoration: InputDecoration(
              labelText: 'Hex Color',
              prefixText: '#',
              hintText: 'FF5733',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
            controller: TextEditingController(text: _hexInput),
          ),
          const SizedBox(height: 16),

          // Color details
          _ColorInfoCard(label: 'HEX', value: '#${_colorToHex(_selectedColor)}'),
          _ColorInfoCard(label: 'RGB', value: _colorToRgb(_selectedColor)),
          _ColorInfoCard(label: 'HSL', value: _colorToHsl(_selectedColor)),
          _ColorInfoCard(
            label: 'Decimal',
            value: _selectedColor.toARGB32().toString(),
          ),

          const SizedBox(height: 16),

          // Color sliders
          Text('RGB Sliders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _ColorSlider(
            label: 'R',
            value: ((_selectedColor.r * 255.0).round().clamp(0, 255)),
            onChanged: (value) {
              setState(() {
                final g = (_selectedColor.g * 255.0).round().clamp(0, 255);
                final b = (_selectedColor.b * 255.0).round().clamp(0, 255);
                _selectedColor = Color.fromARGB(255, value.toInt(), g, b);
              });
            },
          ),
          _ColorSlider(
            label: 'G',
            value: ((_selectedColor.g * 255.0).round().clamp(0, 255)),
            onChanged: (value) {
              setState(() {
                final r = (_selectedColor.r * 255.0).round().clamp(0, 255);
                final b = (_selectedColor.b * 255.0).round().clamp(0, 255);
                _selectedColor = Color.fromARGB(255, r, value.toInt(), b);
              });
            },
          ),
          _ColorSlider(
            label: 'B',
            value: ((_selectedColor.b * 255.0).round().clamp(0, 255)),
            onChanged: (value) {
              setState(() {
                final r = (_selectedColor.r * 255.0).round().clamp(0, 255);
                final g = (_selectedColor.g * 255.0).round().clamp(0, 255);
                _selectedColor = Color.fromARGB(255, r, g, value.toInt());
              });
            },
          ),
        ],
      ),
    );
  }
}

class _ColorInfoCard extends StatelessWidget {
  const _ColorInfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({required this.label, required this.value, required this.onChanged});

  final String label;
  final int value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label)),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 50, child: Text(value.toString(), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}


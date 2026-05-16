import 'package:flutter/material.dart';

class PaletteGeneratorScreen extends StatefulWidget {
  const PaletteGeneratorScreen({super.key});

  @override
  State<PaletteGeneratorScreen> createState() => _PaletteGeneratorScreenState();
}

class _PaletteGeneratorScreenState extends State<PaletteGeneratorScreen> {
  String _baseColorHex = 'FF5733';
  String _paletteType = 'complementary';
  List<Color> _generatedPalette = [];

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '').toUpperCase();
    return Color(int.parse('FF$clean', radix: 16));
  }

  HSL _rgbToHsl(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);

    final l = (max + min) / 2;
    final d = max - min;

    double h = 0, s = 0;

    if (d != 0) {
      s = d / (1 - (2 * l - 1).abs());
      h = switch ((max)) {
        _ when max == r => (60 * (((g - b) / d) % 6) + 360) % 360,
        _ when max == g => (60 * (((b - r) / d) + 2)) % 360,
        _ => (60 * (((r - g) / d) + 4)) % 360,
      };
    }

    return HSL(h, s, l);
  }

  Color _hslToColor(HSL hsl) {
    final c = (1 - (2 * hsl.l - 1).abs()) * hsl.s;
    final x = c * (1 - (((hsl.h / 60) % 2) - 1).abs());
    final m = hsl.l - c / 2;

    late double r, g, b;

    if (hsl.h < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (hsl.h < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (hsl.h < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (hsl.h < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (hsl.h < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    return Color.fromARGB(
      255,
      ((r + m) * 255).toInt().clamp(0, 255),
      ((g + m) * 255).toInt().clamp(0, 255),
      ((b + m) * 255).toInt().clamp(0, 255),
    );
  }

  void _generatePalette() {
    final baseColor = _hexToColor(_baseColorHex);
    final baseHsl = _rgbToHsl(baseColor);

    final palette = <Color>[];

    switch (_paletteType) {
      case 'complementary':
        // Base + complementary (opposite hue)
        palette.add(baseColor);
        final comp = HSL((baseHsl.h + 180) % 360, baseHsl.s, baseHsl.l);
        palette.add(_hslToColor(comp));
        break;

      case 'analogous':
        // 3 colors 30° apart
        palette.add(_hslToColor(HSL((baseHsl.h + 330) % 360, baseHsl.s, baseHsl.l)));
        palette.add(_hslToColor(baseHsl));
        palette.add(_hslToColor(HSL((baseHsl.h + 30) % 360, baseHsl.s, baseHsl.l)));
        break;

      case 'triadic':
        // 3 colors 120° apart
        palette.add(_hslToColor(baseHsl));
        palette.add(_hslToColor(HSL((baseHsl.h + 120) % 360, baseHsl.s, baseHsl.l)));
        palette.add(_hslToColor(HSL((baseHsl.h + 240) % 360, baseHsl.s, baseHsl.l)));
        break;

      case 'shades':
        // Lightness gradient
        for (int i = 0; i < 5; i++) {
          final lightness = (i + 1) * 0.2;
          palette.add(_hslToColor(HSL(baseHsl.h, baseHsl.s, lightness)));
        }
        break;

      case 'tints':
        // From dark to light with fixed saturation
        for (int i = 0; i < 5; i++) {
          final lightness = 0.2 + (i * 0.15);
          palette.add(_hslToColor(HSL(baseHsl.h, baseHsl.s, lightness)));
        }
        break;

      default:
        palette.add(baseColor);
    }

    setState(() => _generatedPalette = palette);
  }

  void _updateBaseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '').toUpperCase();
      if (clean.length == 6) {
        setState(() => _baseColorHex = clean);
        _generatePalette();
      }
    } catch (e) {
      // Invalid input
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Palette Generator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Base color input
          TextField(
            onChanged: _updateBaseColor,
            decoration: InputDecoration(
              labelText: 'Base Color (Hex)',
              prefixText: '#',
              hintText: 'FF5733',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
            controller: TextEditingController(text: _baseColorHex),
          ),
          const SizedBox(height: 16),

          // Palette type selector
          Text('Palette Type', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PaletteTypeButton(
                  label: 'Complementary',
                  value: 'complementary',
                  selected: _paletteType == 'complementary',
                  onPressed: () {
                    setState(() => _paletteType = 'complementary');
                    _generatePalette();
                  },
                ),
                const SizedBox(width: 8),
                _PaletteTypeButton(
                  label: 'Analogous',
                  value: 'analogous',
                  selected: _paletteType == 'analogous',
                  onPressed: () {
                    setState(() => _paletteType = 'analogous');
                    _generatePalette();
                  },
                ),
                const SizedBox(width: 8),
                _PaletteTypeButton(
                  label: 'Triadic',
                  value: 'triadic',
                  selected: _paletteType == 'triadic',
                  onPressed: () {
                    setState(() => _paletteType = 'triadic');
                    _generatePalette();
                  },
                ),
                const SizedBox(width: 8),
                _PaletteTypeButton(
                  label: 'Shades',
                  value: 'shades',
                  selected: _paletteType == 'shades',
                  onPressed: () {
                    setState(() => _paletteType = 'shades');
                    _generatePalette();
                  },
                ),
                const SizedBox(width: 8),
                _PaletteTypeButton(
                  label: 'Tints',
                  value: 'tints',
                  selected: _paletteType == 'tints',
                  onPressed: () {
                    setState(() => _paletteType = 'tints');
                    _generatePalette();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Generated palette
          Text('Generated Palette', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._generatedPalette.map((color) => _PaletteColorCard(color: color)),
        ],
      ),
    );
  }
}

class _PaletteTypeButton extends StatelessWidget {
  const _PaletteTypeButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: selected ? null : Colors.grey[300],
        foregroundColor: selected ? null : Colors.black87,
      ),
      child: Text(label),
    );
  }
}

class _PaletteColorCard extends StatelessWidget {
  const _PaletteColorCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = (color.r * 255.0).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().toRadixString(16).padLeft(2, '0');
    final hex = '$r$g$b'.toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('#$hex copied!')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HEX', style: theme.textTheme.labelSmall),
                      Text('#$hex', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                    ],
                  ),
                ),
                Icon(Icons.copy, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HSL {
  final double h; // 0-360
  final double s; // 0-1
  final double l; // 0-1

  HSL(this.h, this.s, this.l);
}


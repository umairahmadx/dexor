import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const accentSwatches = <Color>[
    AppColors.cyan,
    AppColors.blue,
    AppColors.green,
    AppColors.amber,
    AppColors.pink,
  ];

  static const accentLabels = <String>[
    'Cyan',
    'Blue',
    'Green',
    'Amber',
    'Pink',
  ];

  ThemeMode _themeMode = ThemeMode.system;
  bool _compactMode = false;
  double _fontScale = 1.0;
  int _accentIndex = 0;

  ThemeMode get themeMode => _themeMode;
  bool get compactMode => _compactMode;
  double get fontScale => _fontScale;
  int get accentIndex => _accentIndex;
  Color get accentColor => accentSwatches[_accentIndex % accentSwatches.length];
  String get accentLabel => accentLabels[_accentIndex % accentLabels.length];

  void setThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  void toggleCompactMode(bool value) {
    if (_compactMode == value) return;
    _compactMode = value;
    notifyListeners();
  }

  void setFontScale(double value) {
    final next = value.clamp(0.9, 1.2);
    if (_fontScale == next) return;
    _fontScale = next;
    notifyListeners();
  }

  void setAccentIndex(int value) {
    if (_accentIndex == value) return;
    _accentIndex = value;
    notifyListeners();
  }

  void reset() {
    _themeMode = ThemeMode.system;
    _compactMode = false;
    _fontScale = 1.0;
    _accentIndex = 0;
    notifyListeners();
  }
}

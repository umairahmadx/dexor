import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light({required Color seedColor, required bool compactMode}) =>
      _buildTheme(Brightness.light, seedColor: seedColor, compactMode: compactMode);

  static ThemeData dark({required Color seedColor, required bool compactMode}) =>
      _buildTheme(Brightness.dark, seedColor: seedColor, compactMode: compactMode);

  static ThemeData _buildTheme(
    Brightness brightness, {
    required Color seedColor,
    required bool compactMode,
  }) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final radius = compactMode ? 12.0 : 16.0;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      surface: surface,
    ).copyWith(
      primary: seedColor,
      secondary: seedColor.withValues(alpha: 0.82),
      error: AppColors.red,
      surface: surface,
      onSurface: isDark ? Colors.white : const Color(0xFF101114),
      outline: border,
      outlineVariant: border,
      surfaceContainerHighest: card,
    );

    final textTheme = ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: isDark ? Colors.white : const Color(0xFF101114),
          displayColor: isDark ? Colors.white : const Color(0xFF101114),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: border,
      visualDensity: compactMode ? VisualDensity.compact : VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: isDark ? Colors.white : const Color(0xFF101114),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: seedColor.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(color: muted),
        ),
      ),
      textTheme: textTheme,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: textTheme.bodyMedium,
        actionTextColor: seedColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
      ),
      iconTheme: IconThemeData(color: muted),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: seedColor, width: 1.5),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}



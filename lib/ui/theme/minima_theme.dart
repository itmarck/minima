import 'package:flutter/material.dart';

/// Defines the color palette for a Minima theme.
/// Add new palettes as static constants to support multiple themes.
class MinimaColors {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;

  const MinimaColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
  });

  static const grayscale = MinimaColors(
    background: Colors.black,
    surface: Color(0xFF1A1A1A),
    surfaceLight: Color(0xFF2A2A2A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF9E9E9E),
    textMuted: Color(0xFF616161),
    accent: Color(0xFFBDBDBD),
  );
}

/// Builds a Flutter ThemeData from a [MinimaColors] palette.
class MinimaTheme {
  static MinimaColors colors = MinimaColors.grayscale;

  // Convenience getters for the active palette.
  static Color get background => colors.background;
  static Color get surface => colors.surface;
  static Color get surfaceLight => colors.surfaceLight;
  static Color get textPrimary => colors.textPrimary;
  static Color get textSecondary => colors.textSecondary;
  static Color get textMuted => colors.textMuted;
  static Color get accent => colors.accent;

  static ThemeData get data => _buildTheme(colors);

  static ThemeData _buildTheme(MinimaColors colors) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(
        surface: colors.surface,
        primary: colors.accent,
        onPrimary: colors.background,
        onSurface: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.textPrimary),
        bodyMedium: TextStyle(color: colors.textSecondary),
        labelLarge: TextStyle(color: colors.textSecondary),
      ),
      iconTheme: IconThemeData(color: colors.textSecondary),
    );
  }
}

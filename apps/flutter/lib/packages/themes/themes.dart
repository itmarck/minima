import 'package:flutter/material.dart';

export 'black.dart';
export 'pink.dart';
export 'white.dart';

class Themes {
  Brightness brightness;
  Color background;
  Color foreground;
  Color accent;
  double padding;

  Themes({
    required this.background,
    required this.foreground,
    this.brightness = Brightness.dark,
    this.padding = 32.0,
    accent,
  }) : accent = accent ?? foreground;
}

extension ToThemeData on Themes {
  ThemeData get themeData {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}

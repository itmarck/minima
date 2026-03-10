import 'package:flutter/material.dart';

/// Color tokens for a Minima theme, exposed as a [ThemeExtension].
///
/// Widgets access tokens via `Theme.of(context).extension<MinimaColors>()!`
/// or the shorthand `context.colors`.
class MinimaColors extends ThemeExtension<MinimaColors> {
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

  @override
  MinimaColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
  }) {
    return MinimaColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
    );
  }

  @override
  MinimaColors lerp(MinimaColors? other, double t) {
    if (other is! MinimaColors) return this;
    return MinimaColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

/// Shorthand to access [MinimaColors] from any widget.
extension MinimaThemeContext on BuildContext {
  MinimaColors get colors => Theme.of(this).extension<MinimaColors>()!;
}

/// Builds a fully configured [ThemeData] from a [MinimaColors] palette.
///
/// Typography roles (from DESIGN.md):
///   titleMedium  → AppBar titles
///   bodyLarge    → Text input
///   bodyMedium   → List item titles, tile labels
///   bodySmall    → Subtitles, metadata
///   labelSmall   → Actionable type labels, captions
///   labelMedium  → Pending count, info text, links
///   labelLarge   → Settings section headers (+ letterSpacing)
class MinimaTheme {
  static ThemeData build([MinimaColors colors = MinimaColors.grayscale]) {
    final textTheme = TextTheme(
      titleMedium: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: colors.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: colors.textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: colors.textMuted, fontSize: 12, fontWeight: FontWeight.w300),
      labelSmall: TextStyle(color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w300),
      labelMedium: TextStyle(color: colors.textMuted, fontSize: 13),
      labelLarge: TextStyle(
        color: colors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );

    return ThemeData.dark().copyWith(
      extensions: [colors],
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
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textSecondary),
        titleTextStyle: textTheme.titleMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.textMuted, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textMuted),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(color: colors.textPrimary, fontSize: 14),
        iconColor: colors.textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(color: colors.textPrimary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.surfaceLight,
          foregroundColor: colors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          minimumSize: const Size.fromHeight(44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.textMuted),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _MinimaPageTransitionsBuilder(),
          TargetPlatform.iOS: _MinimaPageTransitionsBuilder(),
          TargetPlatform.windows: _MinimaPageTransitionsBuilder(),
          TargetPlatform.macOS: _MinimaPageTransitionsBuilder(),
          TargetPlatform.linux: _MinimaPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Subtle slide-up + fade transition for all page navigations.
class _MinimaPageTransitionsBuilder extends PageTransitionsBuilder {
  const _MinimaPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _MinimaPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _MinimaPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _MinimaPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  static final _offsetTween = Tween<Offset>(
    begin: const Offset(0.0, 0.04),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  static final _fadeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.easeOut));

  static final _secondaryFadeTween = Tween<double>(
    begin: 1.0,
    end: 0.92,
  ).chain(CurveTween(curve: Curves.easeInOut));

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _secondaryFadeTween.animate(secondaryAnimation),
      child: SlideTransition(
        position: _offsetTween.animate(animation),
        child: FadeTransition(opacity: _fadeTween.animate(animation), child: child),
      ),
    );
  }
}

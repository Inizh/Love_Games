import 'package:material_ui/material_ui.dart';

/// Palette taken from the JavaFX stylesheet.
abstract final class LoveColors {
  static const primary = Color(0xFF6C5CE7);
  static const primaryPressed = Color(0xFF5A4BD1);
  static const ink = Color(0xFF2D3436);
  static const muted = Color(0xFF636E72);
  static const heart = Color(0xFFE84393);
  static const flame = Color(0xFFE17055);
  static const blush = Color(0xFFFCE4F0);
  static const cardBorder = Color(0xFFEFE9FF);
  static const fieldFill = Color(0xFFF8F9FA);
  static const fieldBorder = Color(0xFFE9ECEF);
  static const resultBorder = Color(0xFFDDD6FE);
  static const success = Color(0xFF00B894);
  static const warning = Color(0xFFFDCB6E);
  static const danger = Color(0xFFD63031);
  static const offline = Color(0xFFB2BEC3);
  static const shadow = Color(0x1F6C5CE7);

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDF2F8), Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
  );
}

ThemeData buildLoveTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: LoveColors.primary,
    brightness: Brightness.light,
  ).copyWith(primary: LoveColors.primary, surface: Colors.white);

  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    splashColor: LoveColors.primary.withValues(alpha: 0.08),
    textTheme: Typography.material2021().black.apply(
      bodyColor: LoveColors.ink,
      displayColor: LoveColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: LoveColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: LoveColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: LoveColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: LoveColors.primary.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: rounded,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LoveColors.primary,
        minimumSize: const Size(64, 48),
        side: const BorderSide(color: Color(0xFFC4B5FD)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: rounded,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LoveColors.fieldFill,
      hintStyle: const TextStyle(color: LoveColors.offline),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: LoveColors.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: LoveColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: LoveColors.primary, width: 1.6),
      ),
    ),
  );
}

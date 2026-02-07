import 'package:flutter/material.dart';

class NeonTheme {
  // Core neon colors (matching chess)
  static const Color neonGreen = Color(0xFF00FF41);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonBlue = Color(0xFF4466FF);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonOrange = Color(0xFFFF6600);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color neonRed = Color(0xFFFF0040);

  // ── Dark mode backgrounds ──────────────────────────────────────────
  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color darkerBg = Color(0xFF050508);
  static const Color cardBg = Color(0xFF12121A);
  static const Color surfaceBg = Color(0xFF1A1A25);

  // ── Light mode backgrounds ─────────────────────────────────────────
  static const Color lightBg = Color(0xFFF5F5FA);
  static const Color lighterBg = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFEEEEF4);
  static const Color lightSurfaceBg = Color(0xFFE8E8F0);

  // Board colors (dark)
  static const Color gridLine = Color(0xFF1E1E30);
  static const Color gridBg = Color(0xFF0F0F1A);

  // Board colors (light)
  static const Color lightGridLine = Color(0xFFCCCCD8);
  static const Color lightGridBg = Color(0xFFDDDDE8);

  // Text colors (dark)
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF808090);

  // Text colors (light) – deeper for contrast
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF606078);

  // Player colors (shared)
  static const Color player1Color = neonCyan;
  static const Color player1Glow = neonCyan;
  static const Color player2Color = Color(0xFFFF80FF);
  static const Color player2Glow = neonMagenta;

  // ── Darker neon variants for light mode visibility ─────────────────
  static const Color _darkCyan = Color(0xFF008899);
  static const Color _darkMagenta = Color(0xFFAA0088);
  static const Color _darkGreen = Color(0xFF009922);

  // ── Glow helpers ───────────────────────────────────────────────────

  static BoxShadow neonGlow(Color color, {double blur = 8, double spread = 1}) {
    return BoxShadow(
      color: color.withAlpha(100),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  static List<BoxShadow> neonGlowMultiple(Color color) {
    return [
      BoxShadow(color: color.withAlpha(60), blurRadius: 4, spreadRadius: 0),
      BoxShadow(color: color.withAlpha(40), blurRadius: 12, spreadRadius: 2),
      BoxShadow(color: color.withAlpha(20), blurRadius: 24, spreadRadius: 4),
    ];
  }

  // ── Dark theme ─────────────────────────────────────────────────────

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonMagenta,
        surface: cardBg,
        onPrimary: darkBg,
        onSecondary: darkBg,
        onSurface: textPrimary,
        error: Color(0xFFFF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkerBg,
        foregroundColor: neonCyan,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: neonCyan,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: neonCyan.withAlpha(40)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan.withAlpha(30),
          foregroundColor: neonCyan,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: neonCyan.withAlpha(120)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonMagenta,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: neonMagenta.withAlpha(120)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonGreen,
        ),
      ),
      iconTheme: const IconThemeData(color: neonCyan),
      dividerTheme: DividerThemeData(color: neonCyan.withAlpha(30)),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: neonCyan.withAlpha(60)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBg,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: neonGreen.withAlpha(100)),
        ),
      ),
    );
  }

  // ── Light theme ────────────────────────────────────────────────────

  static ThemeData get lightThemeData {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: _darkCyan,
      colorScheme: const ColorScheme.light(
        primary: _darkCyan,
        secondary: _darkMagenta,
        surface: lightCardBg,
        onPrimary: lighterBg,
        onSecondary: lighterBg,
        onSurface: lightTextPrimary,
        error: Color(0xFFCC0033),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lighterBg,
        foregroundColor: _darkCyan,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _darkCyan,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _darkCyan.withAlpha(40)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkCyan.withAlpha(25),
          foregroundColor: _darkCyan,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: _darkCyan.withAlpha(100)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkMagenta,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: _darkMagenta.withAlpha(100)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkGreen,
        ),
      ),
      iconTheme: const IconThemeData(color: _darkCyan),
      dividerTheme: DividerThemeData(color: _darkCyan.withAlpha(30)),
      dialogTheme: DialogThemeData(
        backgroundColor: lighterBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _darkCyan.withAlpha(60)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lighterBg,
        contentTextStyle: const TextStyle(color: lightTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _darkGreen.withAlpha(100)),
        ),
      ),
    );
  }
}

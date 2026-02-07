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

  // Background colors
  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color darkerBg = Color(0xFF050508);
  static const Color cardBg = Color(0xFF12121A);
  static const Color surfaceBg = Color(0xFF1A1A25);

  // Board colors
  static const Color gridLine = Color(0xFF1E1E30);
  static const Color gridBg = Color(0xFF0F0F1A);

  // Text colors
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF808090);

  // Player colors
  static const Color player1Color = neonCyan;
  static const Color player1Glow = neonCyan;
  static const Color player2Color = Color(0xFFFF80FF);
  static const Color player2Glow = neonMagenta;

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
}

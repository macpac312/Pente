import 'package:flutter/material.dart';

class NeonTheme {
  // Neon color palette
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF00FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonBlue = Color(0xFF4D4DFF);
  static const Color neonOrange = Color(0xFFFF6600);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonRed = Color(0xFFFF0040);

  static const Color darkBg = Color(0xFF0A0A1A);
  static const Color darkSurface = Color(0xFF12122A);
  static const Color darkCard = Color(0xFF1A1A3E);
  static const Color gridLine = Color(0xFF2A2A5A);

  // Player colors
  static const Color player1Color = neonCyan;
  static const Color player2Color = neonPink;

  static ThemeData darkTheme(Color accent) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: neonPink,
        surface: darkSurface,
        error: neonRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: accent,
          shadows: [
            Shadow(color: accent.withOpacity(0.8), blurRadius: 12),
            Shadow(color: accent.withOpacity(0.4), blurRadius: 24),
          ],
        ),
        iconTheme: IconThemeData(color: accent),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent.withOpacity(0.3), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 14,
          color: Colors.white70,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      ),
      iconTheme: IconThemeData(color: accent),
      dividerColor: accent.withOpacity(0.2),
    );
  }

  // Neon glow box decoration
  static BoxDecoration neonBox({
    required Color color,
    double glowRadius = 8,
    double borderWidth = 1.5,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: darkCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color.withOpacity(0.6), width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: glowRadius,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: glowRadius * 2,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // Neon text shadow
  static List<Shadow> neonTextShadow(Color color, {double intensity = 1.0}) {
    return [
      Shadow(color: color.withOpacity(0.8 * intensity), blurRadius: 8),
      Shadow(color: color.withOpacity(0.4 * intensity), blurRadius: 16),
      Shadow(color: color.withOpacity(0.2 * intensity), blurRadius: 32),
    ];
  }

  // Neon gradient
  static LinearGradient neonGradient(Color color1, Color color2) {
    return LinearGradient(
      colors: [color1.withOpacity(0.8), color2.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

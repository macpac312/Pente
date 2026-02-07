import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

/// All customizable visual properties for the board and stones.
class BoardThemeData {
  final Color player1Color;
  final Color player1Glow;
  final double player1GlowIntensity; // 0.0 – 2.0
  final Color player2Color;
  final Color player2Glow;
  final double player2GlowIntensity;
  final Color boardColor;
  final Color gridLineColor;
  final Color boardBorderColor;
  final Color starPointColor;
  final Color backgroundColor;
  final Color labelColor;

  const BoardThemeData({
    required this.player1Color,
    required this.player1Glow,
    this.player1GlowIntensity = 1.0,
    required this.player2Color,
    required this.player2Glow,
    this.player2GlowIntensity = 1.0,
    required this.boardColor,
    required this.gridLineColor,
    required this.boardBorderColor,
    required this.starPointColor,
    required this.backgroundColor,
    required this.labelColor,
  });

  factory BoardThemeData.darkDefault() => BoardThemeData(
        player1Color: NeonTheme.neonCyan,
        player1Glow: NeonTheme.neonCyan,
        player1GlowIntensity: 1.0,
        player2Color: NeonTheme.player2Color,
        player2Glow: NeonTheme.neonMagenta,
        player2GlowIntensity: 1.0,
        boardColor: NeonTheme.gridBg,
        gridLineColor: NeonTheme.neonCyan.withAlpha(35),
        boardBorderColor: NeonTheme.neonCyan.withAlpha(80),
        starPointColor: NeonTheme.neonCyan.withAlpha(100),
        backgroundColor: NeonTheme.darkBg,
        labelColor: NeonTheme.textSecondary,
      );

  factory BoardThemeData.lightDefault() => BoardThemeData(
        player1Color: NeonTheme.neonCyan,
        player1Glow: NeonTheme.neonCyan,
        player1GlowIntensity: 0.6,
        player2Color: NeonTheme.player2Color,
        player2Glow: NeonTheme.neonMagenta,
        player2GlowIntensity: 0.6,
        boardColor: NeonTheme.lightGridBg,
        gridLineColor: NeonTheme.lightGridLine,
        boardBorderColor: NeonTheme.neonCyan.withAlpha(50),
        starPointColor: NeonTheme.neonCyan.withAlpha(80),
        backgroundColor: NeonTheme.lightBg,
        labelColor: NeonTheme.lightTextSecondary,
      );

  BoardThemeData copyWith({
    Color? player1Color,
    Color? player1Glow,
    double? player1GlowIntensity,
    Color? player2Color,
    Color? player2Glow,
    double? player2GlowIntensity,
    Color? boardColor,
    Color? gridLineColor,
    Color? boardBorderColor,
    Color? starPointColor,
    Color? backgroundColor,
    Color? labelColor,
  }) {
    return BoardThemeData(
      player1Color: player1Color ?? this.player1Color,
      player1Glow: player1Glow ?? this.player1Glow,
      player1GlowIntensity: player1GlowIntensity ?? this.player1GlowIntensity,
      player2Color: player2Color ?? this.player2Color,
      player2Glow: player2Glow ?? this.player2Glow,
      player2GlowIntensity: player2GlowIntensity ?? this.player2GlowIntensity,
      boardColor: boardColor ?? this.boardColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      boardBorderColor: boardBorderColor ?? this.boardBorderColor,
      starPointColor: starPointColor ?? this.starPointColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      labelColor: labelColor ?? this.labelColor,
    );
  }
}

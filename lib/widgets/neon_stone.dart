import 'package:flutter/material.dart';
import '../models/board_theme.dart';
import '../main.dart' show boardThemeNotifier;
import '../utils/constants.dart';

/// A simple neon-styled stone rendered as a glowing circle.
///
/// Reads player colors and glow intensity from the global [boardThemeNotifier].
/// An optional [themeOverride] can be passed (used by the settings preview).
class NeonStone extends StatelessWidget {
  final StoneType type;
  final double size;
  final bool isLastMove;
  final bool isWinning;
  final BoardThemeData? themeOverride;

  const NeonStone({
    super.key,
    required this.type,
    this.size = 28,
    this.isLastMove = false,
    this.isWinning = false,
    this.themeOverride,
  });

  @override
  Widget build(BuildContext context) {
    if (type == StoneType.none) return const SizedBox.shrink();

    final theme = themeOverride ?? boardThemeNotifier.value;

    final color = type == StoneType.player1
        ? theme.player1Color
        : theme.player2Color;
    final glowColor = type == StoneType.player1
        ? theme.player1Glow
        : theme.player2Glow;
    final baseIntensity = type == StoneType.player1
        ? theme.player1GlowIntensity
        : theme.player2GlowIntensity;

    final double glowIntensity = (isWinning ? 1.5 : 1.0) * baseIntensity;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha(230),
            color.withAlpha(150),
            glowColor.withAlpha(80),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          // Inner glow
          BoxShadow(
            color: glowColor.withAlpha((200 * glowIntensity).round().clamp(0, 255)),
            blurRadius: 6 * glowIntensity,
            spreadRadius: 1,
          ),
          // Outer glow
          BoxShadow(
            color: glowColor.withAlpha((100 * glowIntensity).round().clamp(0, 255)),
            blurRadius: 12 * glowIntensity,
            spreadRadius: 2,
          ),
          // Extra ambient glow for winning / last-move stones
          if (isWinning || isLastMove)
            BoxShadow(
              color: glowColor.withAlpha((50 * glowIntensity).round().clamp(0, 255)),
              blurRadius: 24,
              spreadRadius: 4,
            ),
        ],
      ),
      // Translucent highlight in the centre for a "glass" look.
      child: Center(
        child: Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(35),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

/// A simple neon-styled stone rendered as a glowing circle.
///
/// No animations — just a styled [Container] with a [RadialGradient] and
/// layered [BoxShadow]s, matching the Neon Chess piece aesthetic.
class NeonStone extends StatelessWidget {
  final StoneType type;
  final double size;
  final bool isLastMove;
  final bool isWinning;

  const NeonStone({
    super.key,
    required this.type,
    this.size = 28,
    this.isLastMove = false,
    this.isWinning = false,
  });

  @override
  Widget build(BuildContext context) {
    if (type == StoneType.none) return const SizedBox.shrink();

    final color = type == StoneType.player1
        ? NeonTheme.player1Color
        : NeonTheme.player2Color;
    final glowColor = type == StoneType.player1
        ? NeonTheme.player1Glow
        : NeonTheme.player2Glow;

    final double glowIntensity = isWinning ? 1.5 : 1.0;

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
            color: glowColor.withAlpha((200 * glowIntensity).round()),
            blurRadius: 6 * glowIntensity,
            spreadRadius: 1,
          ),
          // Outer glow
          BoxShadow(
            color: glowColor.withAlpha((100 * glowIntensity).round()),
            blurRadius: 12 * glowIntensity,
            spreadRadius: 2,
          ),
          // Extra ambient glow for winning / last-move stones
          if (isWinning || isLastMove)
            BoxShadow(
              color: glowColor.withAlpha((50 * glowIntensity).round()),
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

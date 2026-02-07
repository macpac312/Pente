import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

/// Displays a player name alongside 5 capture indicator dots.
class CaptureDisplay extends StatelessWidget {
  final String playerName;
  final int captures;
  final Color color;

  const CaptureDisplay({
    super.key,
    required this.playerName,
    required this.captures,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playerName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'CAPTURES',
          style: TextStyle(
            fontSize: 10,
            color: NeonTheme.textSecondary.withAlpha(120),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 6),
        ...List.generate(
          Constants.capturesNeededToWin,
          (i) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < captures ? color : color.withAlpha(30),
              boxShadow: i < captures
                  ? [NeonTheme.neonGlow(color, blur: 4, spread: 0)]
                  : [],
            ),
          ),
        ),
      ],
    );
  }
}

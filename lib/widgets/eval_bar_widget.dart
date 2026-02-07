import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

class EvalBar extends StatelessWidget {
  final int evaluation;
  final bool isVertical;

  const EvalBar({
    super.key,
    required this.evaluation,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize evaluation to 0.0 - 1.0 range (0.5 = equal)
    final normalized = (evaluation / 2000.0 + 0.5).clamp(0.0, 1.0);

    if (isVertical) {
      return _buildVerticalBar(normalized);
    } else {
      return _buildHorizontalBar(normalized);
    }
  }

  Widget _buildVerticalBar(double normalized) {
    final p1Pct = (normalized * 100).round().clamp(1, 99);
    final p2Pct = 100 - p1Pct;

    return Container(
      width: 24,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: NeonTheme.textSecondary.withAlpha(40)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Column(
          children: [
            // Opponent (player 2 / AI) advantage shown at top
            Flexible(
              flex: p2Pct,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      NeonTheme.neonMagenta.withAlpha(180),
                      NeonTheme.neonMagenta.withAlpha(100),
                    ],
                  ),
                ),
              ),
            ),
            // Player 1 advantage shown at bottom
            Flexible(
              flex: p1Pct,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      NeonTheme.neonCyan.withAlpha(100),
                      NeonTheme.neonCyan.withAlpha(180),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBar(double normalized) {
    final p1Pct = (normalized * 100).round().clamp(1, 99);
    final p2Pct = 100 - p1Pct;

    return Container(
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: NeonTheme.textSecondary.withAlpha(40)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Row(
          children: [
            // Player 1 advantage shown at left
            Flexible(
              flex: p1Pct,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      NeonTheme.neonCyan.withAlpha(180),
                      NeonTheme.neonCyan.withAlpha(100),
                    ],
                  ),
                ),
              ),
            ),
            // Opponent advantage shown at right
            Flexible(
              flex: p2Pct,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      NeonTheme.neonMagenta.withAlpha(100),
                      NeonTheme.neonMagenta.withAlpha(180),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

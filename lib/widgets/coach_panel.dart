import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/pente_engine.dart';
import '../providers/game_provider.dart';
import '../theme/neon_theme.dart';

class CoachPanel extends StatelessWidget {
  const CoachPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (!game.coachEnabled || game.coachHints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      constraints: const BoxConstraints(maxHeight: 140),
      decoration: NeonTheme.neonBox(
        color: NeonTheme.neonGreen,
        glowRadius: 6,
        borderRadius: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Icon(Icons.school, color: NeonTheme.neonGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  'COACH',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: NeonTheme.neonGreen,
                    shadows: NeonTheme.neonTextShadow(
                        NeonTheme.neonGreen, intensity: 0.4),
                  ),
                ),
                const Spacer(),
                Text(
                  '${game.coachHints.length} hint${game.coachHints.length > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              shrinkWrap: true,
              itemCount: game.coachHints.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final hint = game.coachHints[index];
                return _HintTile(
                  hint: hint,
                  isHighlighted: game.highlightedHint == hint.position,
                  onTap: () {
                    if (game.highlightedHint == hint.position) {
                      game.clearHighlight();
                    } else {
                      game.highlightHint(hint);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HintTile extends StatelessWidget {
  final CoachHint hint;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _HintTile({
    required this.hint,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _hintColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlighted ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted
              ? Border.all(color: color.withOpacity(0.4), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color.withOpacity(0.6), width: 1),
              ),
              child: Center(
                child: Text(
                  hint.icon,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint.message,
                style: TextStyle(
                  fontSize: 11,
                  color: isHighlighted ? color : Colors.white.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isHighlighted ? Icons.visibility : Icons.visibility_off,
              size: 14,
              color: color.withOpacity(isHighlighted ? 0.8 : 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Color get _hintColor {
    switch (hint.type) {
      case HintType.winningMove:
        return NeonTheme.neonGreen;
      case HintType.blockThreat:
        return NeonTheme.neonRed;
      case HintType.captureOpportunity:
        return NeonTheme.neonOrange;
      case HintType.vulnerablePair:
        return NeonTheme.neonYellow;
      case HintType.buildLine:
        return NeonTheme.neonCyan;
    }
  }
}

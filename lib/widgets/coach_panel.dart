import 'package:flutter/material.dart';
import '../engine/pente_engine.dart';
import '../theme/neon_theme.dart';

class CoachPanelWidget extends StatelessWidget {
  final List<CoachHint> hints;
  final bool isThinking;
  final CoachHint? currentHighlight;
  final VoidCallback onGetTip;
  final VoidCallback onSuggestMove;
  final VoidCallback onLearn;
  final void Function(CoachHint) onHintTap;

  const CoachPanelWidget({
    super.key,
    required this.hints,
    this.isThinking = false,
    this.currentHighlight,
    required this.onGetTip,
    required this.onSuggestMove,
    required this.onLearn,
    required this.onHintTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeonTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NeonTheme.neonGreen.withAlpha(60),
          width: 1,
        ),
        boxShadow: [
          NeonTheme.neonGlow(NeonTheme.neonGreen, blur: 6, spread: 0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Icon(Icons.school, color: NeonTheme.neonGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  'PENTE COACH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: NeonTheme.neonGreen,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (isThinking)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(NeonTheme.neonGreen),
                    ),
                  ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: NeonTheme.neonGreen.withAlpha(30),
          ),

          // Tip content area
          if (!isThinking && hints.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: NeonTheme.textSecondary.withAlpha(120),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap a button below for coaching advice...',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: NeonTheme.textSecondary.withAlpha(120),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (!isThinking && hints.isNotEmpty)
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                shrinkWrap: true,
                itemCount: hints.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final hint = hints[index];
                  final isHighlighted = currentHighlight == hint;
                  final color = _hintColor(hint.type);

                  return GestureDetector(
                    onTap: () => onHintTap(hint),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? color.withAlpha(30)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isHighlighted
                            ? Border.all(
                                color: color.withAlpha(80), width: 1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hintIcon(hint.type),
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hintTitle(hint.type),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  hint.message,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isHighlighted
                                        ? color
                                        : NeonTheme.textPrimary
                                            .withAlpha(180),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          Divider(
            height: 1,
            color: NeonTheme.neonGreen.withAlpha(30),
          ),

          // 3 action buttons at bottom
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.lightbulb_outline,
                    label: 'Tip',
                    color: NeonTheme.neonGreen,
                    onTap: onGetTip,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.place,
                    label: 'Hint',
                    color: NeonTheme.neonCyan,
                    onTap: onSuggestMove,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.menu_book,
                    label: 'Learn',
                    color: NeonTheme.neonPurple,
                    onTap: onLearn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withAlpha(60), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hintColor(HintType type) {
    switch (type) {
      case HintType.winningMove:
        return NeonTheme.neonGreen;
      case HintType.blockThreat:
        return NeonTheme.neonRed;
      case HintType.captureOpportunity:
        return NeonTheme.neonOrange;
      case HintType.vulnerablePair:
        return NeonTheme.neonYellow;
      case HintType.openTessera:
        return NeonTheme.neonGreen;
      case HintType.openTria:
        return NeonTheme.neonCyan;
      case HintType.stretchTria:
        return NeonTheme.neonPurple;
      case HintType.wedge:
        return NeonTheme.neonOrange;
      case HintType.buildLine:
        return NeonTheme.neonCyan;
    }
  }

  IconData _hintIcon(HintType type) {
    switch (type) {
      case HintType.winningMove:
        return Icons.star;
      case HintType.blockThreat:
        return Icons.warning;
      case HintType.captureOpportunity:
        return Icons.gps_fixed;
      case HintType.vulnerablePair:
        return Icons.shield;
      case HintType.openTessera:
        return Icons.auto_awesome;
      case HintType.openTria:
        return Icons.change_history;
      case HintType.stretchTria:
        return Icons.unfold_more;
      case HintType.wedge:
        return Icons.compress;
      case HintType.buildLine:
        return Icons.timeline;
    }
  }

  String _hintTitle(HintType type) {
    switch (type) {
      case HintType.winningMove:
        return 'WINNING MOVE';
      case HintType.blockThreat:
        return 'BLOCK THREAT';
      case HintType.captureOpportunity:
        return 'CAPTURE';
      case HintType.vulnerablePair:
        return 'VULNERABLE';
      case HintType.openTessera:
        return 'OPEN TESSERA';
      case HintType.openTria:
        return 'OPEN TRIA';
      case HintType.stretchTria:
        return 'STRETCH TRIA';
      case HintType.wedge:
        return 'WEDGE';
      case HintType.buildLine:
        return 'BUILD LINE';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

class MoveHistory extends StatelessWidget {
  const MoveHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final moves = game.state.moveHistory;

    if (moves.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      constraints: const BoxConstraints(maxHeight: 80),
      decoration: NeonTheme.neonBox(
        color: settings.accentColor.withOpacity(0.5),
        glowRadius: 4,
        borderRadius: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
            child: Text(
              'MOVES',
              style: TextStyle(
                fontFamily: NeonTheme.fontFamily,
                fontSize: 10,
                color: settings.accentColor.withOpacity(0.6),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              child: Row(
                children: List.generate(moves.length, (index) {
                  final move = moves[index];
                  final isP1 = move.player == StoneType.player1;
                  final color = isP1 ? settings.player1Color : settings.player2Color;

                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: color.withOpacity(0.1),
                      border: Border.all(color: color.withOpacity(0.3), width: 0.5),
                    ),
                    child: Text(
                      '${move.moveNumber}. ${move.notation}',
                      style: TextStyle(
                        fontSize: 10,
                        color: color.withOpacity(0.9),
                        fontFamily: NeonTheme.fontFamily,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

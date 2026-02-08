import 'package:flutter/material.dart';
import '../models/move_record.dart';
import '../theme/neon_theme.dart';

class MoveHistoryWidget extends StatelessWidget {
  final List<MoveRecord> moves;
  final int boardSize;

  const MoveHistoryWidget({
    super.key,
    required this.moves,
    this.boardSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return Center(
        child: Text(
          'No moves yet.',
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: NeonTheme.textSecondary,
          ),
        ),
      );
    }

    final pairCount = (moves.length / 2).ceil();
    final lastPairIndex = pairCount - 1;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: pairCount,
      itemBuilder: (context, index) {
        final moveNum = index + 1;
        final p1Idx = index * 2;
        final p2Idx = index * 2 + 1;
        final isLastPair = index == lastPairIndex;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: isLastPair
                ? NeonTheme.neonCyan.withAlpha(15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isLastPair
                ? Border(
                    left: BorderSide(
                      color: NeonTheme.neonCyan.withAlpha(120),
                      width: 2,
                    ),
                  )
                : null,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 3,
            horizontal: isLastPair ? 8 : 4,
          ),
          child: Row(
            children: [
              // Move number
              SizedBox(
                width: 32,
                child: Text(
                  '$moveNum.',
                  style: TextStyle(
                    color: NeonTheme.textSecondary.withAlpha(120),
                    fontSize: 12,
                  ),
                ),
              ),
              // Player 1 move (cyan)
              Expanded(
                child: Text(
                  moves[p1Idx].notationFor(boardSize),
                  style: TextStyle(
                    color: NeonTheme.neonCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Player 2 move (magenta)
              if (p2Idx < moves.length)
                Expanded(
                  child: Text(
                    moves[p2Idx].notationFor(boardSize),
                    style: TextStyle(
                      color: NeonTheme.neonMagenta,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
  }
}

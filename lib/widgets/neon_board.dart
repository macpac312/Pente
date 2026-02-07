import 'package:flutter/material.dart';
import '../models/position.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import 'neon_stone.dart';

class NeonBoard extends StatelessWidget {
  final List<List<StoneType>> board;
  final Position? highlightPosition; // for coach hint
  final Position? lastMove;
  final List<Position>? winningStones;
  final bool interactive;
  final int moveCount; // for tournament rule display
  final StoneType currentPlayer;
  final void Function(Position)? onTap;
  final bool showLabels;

  const NeonBoard({
    super.key,
    required this.board,
    this.highlightPosition,
    this.lastMove,
    this.winningStones,
    this.interactive = true,
    this.moveCount = 0,
    this.currentPlayer = StoneType.player1,
    this.onTap,
    this.showLabels = true,
  });

  // ── Helpers ──────────────────────────────────────────────────────────

  /// True when the tournament-rule restricted zone should be displayed.
  bool get _showTournamentZone =>
      moveCount == 2 && currentPlayer == StoneType.player1;

  /// Star-point positions on a standard 19x19 board.
  static bool _isStarPoint(int row, int col) {
    return (row == 3 || row == 9 || row == 15) &&
        (col == 3 || col == 9 || col == 15);
  }

  /// Whether [row],[col] falls inside the tournament-rule restricted area
  /// (Chebyshev distance < tournamentRuleDistance from centre).
  static bool _isInTournamentZone(int row, int col) {
    final dr = (row - Constants.boardCenter).abs();
    final dc = (col - Constants.boardCenter).abs();
    return dr < Constants.tournamentRuleDistance &&
        dc < Constants.tournamentRuleDistance;
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!showLabels) {
      return AspectRatio(
        aspectRatio: 1,
        child: _buildBoardContainer(),
      );
    }

    return Column(
      children: [
        // Column labels (A-S)
        SizedBox(
          height: 16,
          child: Row(
            children: [
              const SizedBox(width: 18), // spacer matching row-label width
              Expanded(
                child: Row(
                  children: List.generate(Constants.boardSize, (col) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + col),
                          style: const TextStyle(
                            color: NeonTheme.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // Board + row labels
        Expanded(
          child: Row(
            children: [
              // Row labels (19 down to 1)
              SizedBox(
                width: 18,
                child: Column(
                  children: List.generate(Constants.boardSize, (row) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          '${Constants.boardSize - row}',
                          style: const TextStyle(
                            color: NeonTheme.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // The board itself
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildBoardContainer(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Board container with neon border & glow ──────────────────────────

  Widget _buildBoardContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: NeonTheme.neonCyan.withAlpha(80),
          width: 2,
        ),
        boxShadow: NeonTheme.neonGlowMultiple(NeonTheme.neonCyan),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Column(
          children: List.generate(Constants.boardSize, (row) {
            return Expanded(
              child: Row(
                children: List.generate(Constants.boardSize, (col) {
                  return Expanded(
                    child: _buildSquare(row, col),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Individual square ────────────────────────────────────────────────

  Widget _buildSquare(int row, int col) {
    final pos = Position(row, col);
    final stone = board[row][col];
    final isLast = lastMove == pos;
    final isWinning = winningStones?.contains(pos) ?? false;
    final isHighlight = highlightPosition == pos && stone == StoneType.none;
    final isRestricted = _showTournamentZone && _isInTournamentZone(row, col);

    // Alternating subtle dark colours (chess-style)
    final isDark = (row + col) % 2 == 0;
    Color bgColor = isDark ? NeonTheme.gridBg : NeonTheme.gridLine;

    // Last-move highlight
    if (isLast && stone != StoneType.none) {
      bgColor = NeonTheme.neonYellow.withAlpha(25);
    }

    return GestureDetector(
      onTap: interactive && onTap != null ? () => onTap!(pos) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: NeonTheme.neonCyan.withAlpha(12),
            width: 0.5,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth;
            final stoneSize = cellSize * 0.78;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Tournament-rule restricted zone overlay
                if (isRestricted)
                  Positioned.fill(
                    child: Container(color: NeonTheme.neonRed.withAlpha(18)),
                  ),

                // Star point dot (only visible when no stone)
                if (stone == StoneType.none && _isStarPoint(row, col))
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NeonTheme.neonCyan.withAlpha(80),
                      boxShadow: [
                        BoxShadow(
                          color: NeonTheme.neonCyan.withAlpha(40),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),

                // Coach hint / legal-move dot
                if (isHighlight)
                  Container(
                    width: cellSize * 0.32,
                    height: cellSize * 0.32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NeonTheme.neonGreen.withAlpha(100),
                      boxShadow: [
                        BoxShadow(
                          color: NeonTheme.neonGreen.withAlpha(80),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),

                // Stone
                if (stone != StoneType.none)
                  NeonStone(
                    type: stone,
                    size: stoneSize,
                    isLastMove: isLast,
                    isWinning: isWinning,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

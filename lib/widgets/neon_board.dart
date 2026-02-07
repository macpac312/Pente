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

  bool get _showTournamentZone =>
      moveCount == 2 && currentPlayer == StoneType.player1;

  static bool _isStarPoint(int row, int col) {
    return (row == 3 || row == 9 || row == 15) &&
        (col == 3 || col == 9 || col == 15);
  }

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
              const SizedBox(width: 18),
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
        color: NeonTheme.gridBg,
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
                    child: _buildIntersection(row, col),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Individual intersection ────────────────────────────────────────

  Widget _buildIntersection(int row, int col) {
    final pos = Position(row, col);
    final stone = board[row][col];
    final isLast = lastMove == pos;
    final isWinning = winningStones?.contains(pos) ?? false;
    final isHighlight = highlightPosition == pos && stone == StoneType.none;
    final isRestricted = _showTournamentZone && _isInTournamentZone(row, col);

    return GestureDetector(
      onTap: interactive && onTap != null ? () => onTap!(pos) : null,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth;
          final stoneSize = cellSize * 0.85;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Grid lines through center of each intersection
              CustomPaint(
                size: Size(cellSize, cellSize),
                painter: _GridLinePainter(
                  row: row,
                  col: col,
                  boardSize: Constants.boardSize,
                  lineColor: NeonTheme.neonCyan.withAlpha(35),
                ),
              ),

              // Tournament-rule restricted zone overlay
              if (isRestricted)
                Positioned.fill(
                  child: Container(color: NeonTheme.neonRed.withAlpha(18)),
                ),

              // Last-move highlight glow behind stone
              if (isLast && stone != StoneType.none)
                Container(
                  width: cellSize * 0.6,
                  height: cellSize * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NeonTheme.neonYellow.withAlpha(25),
                    boxShadow: [
                      BoxShadow(
                        color: NeonTheme.neonYellow.withAlpha(30),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // Star point dot (only visible when no stone)
              if (stone == StoneType.none && _isStarPoint(row, col))
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NeonTheme.neonCyan.withAlpha(100),
                    boxShadow: [
                      BoxShadow(
                        color: NeonTheme.neonCyan.withAlpha(50),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),

              // Coach hint dot
              if (isHighlight)
                Container(
                  width: cellSize * 0.35,
                  height: cellSize * 0.35,
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

              // Stone on the intersection
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
    );
  }
}

// ── CustomPainter for grid lines ──────────────────────────────────────

class _GridLinePainter extends CustomPainter {
  final int row;
  final int col;
  final int boardSize;
  final Color lineColor;

  _GridLinePainter({
    required this.row,
    required this.col,
    required this.boardSize,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Horizontal line: from left edge to right edge of cell,
    // but stop at center for board edges.
    final left = col == 0 ? cx : 0.0;
    final right = col == boardSize - 1 ? cx : size.width;
    canvas.drawLine(Offset(left, cy), Offset(right, cy), paint);

    // Vertical line: from top edge to bottom edge of cell,
    // but stop at center for board edges.
    final top = row == 0 ? cy : 0.0;
    final bottom = row == boardSize - 1 ? cy : size.height;
    canvas.drawLine(Offset(cx, top), Offset(cx, bottom), paint);
  }

  @override
  bool shouldRepaint(_GridLinePainter oldDelegate) => false;
}

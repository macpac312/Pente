import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/board_theme.dart';
import '../models/position.dart';
import '../main.dart' show boardThemeNotifier;
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import 'neon_stone.dart';

class NeonBoard extends StatelessWidget {
  final List<List<StoneType>> board;
  final Position? highlightPosition;
  final Position? lastMove;
  final List<Position>? winningStones;
  final bool interactive;
  final int moveCount;
  final StoneType currentPlayer;
  final void Function(Position)? onTap;
  final bool showLabels;
  final BoardThemeData? themeOverride;

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
    this.themeOverride,
  });

  // ── Helpers ──────────────────────────────────────────────────────────

  int get _size => board.length;
  int get _center => board.length ~/ 2;

  bool get _showTournamentZone =>
      moveCount == 2 && currentPlayer == StoneType.player1;

  /// Compute star point positions for any board size.
  static bool _isStarPoint(int row, int col, int boardSize) {
    final center = boardSize ~/ 2;
    final d = boardSize >= 13 ? 3 : 2;
    final pts = <int>{d, center, boardSize - 1 - d};
    return pts.contains(row) && pts.contains(col);
  }

  bool _isInTournamentZone(int row, int col) {
    final dr = (row - _center).abs();
    final dc = (col - _center).abs();
    return dr < Constants.tournamentRuleDistance &&
        dc < Constants.tournamentRuleDistance;
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bt = themeOverride ?? boardThemeNotifier.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = math.min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: SizedBox(
            width: maxSize,
            height: maxSize,
            child: showLabels
                ? _buildWithLabels(bt)
                : _buildBoardContainer(bt),
          ),
        );
      },
    );
  }

  Widget _buildWithLabels(BoardThemeData bt) {
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
                  children: List.generate(_size, (col) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + col),
                          style: TextStyle(
                            color: bt.labelColor,
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
                  children: List.generate(_size, (row) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          '${_size - row}',
                          style: TextStyle(
                            color: bt.labelColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // The board itself – force square via AspectRatio
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildBoardContainer(bt),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Board container with neon border & glow ──────────────────────────

  Widget _buildBoardContainer(BoardThemeData bt) {
    return Container(
      decoration: BoxDecoration(
        color: bt.boardColor,
        border: Border.all(color: bt.boardBorderColor, width: 2),
        boxShadow: bt.boardBorderColor.alpha > 50
            ? NeonTheme.neonGlowMultiple(bt.boardBorderColor)
            : [],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            // Grid of intersections
            Column(
              children: List.generate(_size, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_size, (col) {
                      return Expanded(
                        child: _buildIntersection(row, col, bt),
                      );
                    }),
                  ),
                );
              }),
            ),

            // Tournament boundary overlay
            if (_showTournamentZone)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _TournamentBoundaryPainter(
                      boardSize: _size,
                      centerIdx: _center,
                      distance: Constants.tournamentRuleDistance,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Individual intersection ────────────────────────────────────────

  Widget _buildIntersection(int row, int col, BoardThemeData bt) {
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
                  boardSize: _size,
                  lineColor: bt.gridLineColor,
                ),
              ),

              // Tournament-rule restricted zone tint
              if (isRestricted)
                Positioned.fill(
                  child: Container(color: NeonTheme.neonRed.withAlpha(12)),
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
              if (stone == StoneType.none && _isStarPoint(row, col, _size))
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bt.starPointColor,
                    boxShadow: [
                      BoxShadow(
                        color: bt.starPointColor.withAlpha(50),
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
                  themeOverride: themeOverride,
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

    // Horizontal line
    final left = col == 0 ? cx : 0.0;
    final right = col == boardSize - 1 ? cx : size.width;
    canvas.drawLine(Offset(left, cy), Offset(right, cy), paint);

    // Vertical line
    final top = row == 0 ? cy : 0.0;
    final bottom = row == boardSize - 1 ? cy : size.height;
    canvas.drawLine(Offset(cx, top), Offset(cx, bottom), paint);
  }

  @override
  bool shouldRepaint(_GridLinePainter oldDelegate) =>
      lineColor != oldDelegate.lineColor;
}

// ── CustomPainter for tournament rule boundary ────────────────────────

class _TournamentBoundaryPainter extends CustomPainter {
  final int boardSize;
  final int centerIdx;
  final int distance;

  _TournamentBoundaryPainter({
    required this.boardSize,
    required this.centerIdx,
    required this.distance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / boardSize;
    final cellH = size.height / boardSize;

    final firstRestricted = centerIdx - distance + 1;
    final lastRestricted = centerIdx + distance - 1;

    final left = firstRestricted * cellW;
    final top = firstRestricted * cellH;
    final right = (lastRestricted + 1) * cellW;
    final bottom = (lastRestricted + 1) * cellH;

    final rect = Rect.fromLTRB(left, top, right, bottom);

    final paint = Paint()
      ..color = NeonTheme.neonRed.withAlpha(120)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(rect, paint);

    final glowPaint = Paint()
      ..color = NeonTheme.neonRed.withAlpha(40)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawRect(rect, glowPaint);
  }

  @override
  bool shouldRepaint(_TournamentBoundaryPainter oldDelegate) => false;
}

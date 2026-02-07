import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/position.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import 'neon_stone.dart';

class NeonBoard extends StatefulWidget {
  final bool interactive;
  final List<List<StoneType>>? customBoard;
  final Position? highlightPosition;
  final void Function(Position)? onTap;

  const NeonBoard({
    super.key,
    this.interactive = true,
    this.customBoard,
    this.highlightPosition,
    this.onTap,
  });

  @override
  State<NeonBoard> createState() => _NeonBoardState();
}

class _NeonBoardState extends State<NeonBoard> {
  final TransformationController _transformController = TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth;
        final boardHeight = constraints.maxHeight;
        final boardSize = boardWidth < boardHeight ? boardWidth : boardHeight;

        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 3.0,
          boundaryMargin: EdgeInsets.all(boardSize * 0.3),
          onInteractionUpdate: (details) {
            setState(() {
              _currentScale = _transformController.value.getMaxScaleOnAxis();
            });
          },
          child: Center(
            child: SizedBox(
              width: boardSize,
              height: boardSize,
              child: CustomPaint(
                painter: _BoardPainter(
                  gridColor: NeonTheme.gridLine,
                  accentColor: settings.accentColor,
                  showLabels: settings.showGridLabels,
                ),
                child: _buildStonesOverlay(boardSize, settings),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStonesOverlay(double boardSize, SettingsProvider settings) {
    final gameProvider = context.watch<GameProvider>();
    final board = widget.customBoard ?? gameProvider.state.board;
    final cellSize = boardSize / (Constants.boardSize + 1);
    final stoneSize = cellSize * 0.85;

    return Stack(
      children: [
        // Tap targets
        if (widget.interactive)
          ...List.generate(Constants.boardSize, (r) {
            return List.generate(Constants.boardSize, (c) {
              final pos = Position(r, c);
              final left = (c + 1) * cellSize - stoneSize / 2;
              final top = (r + 1) * cellSize - stoneSize / 2;

              return Positioned(
                left: left,
                top: top,
                width: stoneSize,
                height: stoneSize,
                child: GestureDetector(
                  onTap: () {
                    if (widget.onTap != null) {
                      widget.onTap!(pos);
                    } else if (widget.interactive) {
                      gameProvider.makeMove(pos);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _buildCellContent(
                    pos, board, gameProvider, settings, stoneSize,
                  ),
                ),
              );
            });
          }).expand((e) => e),

        // Non-interactive stones
        if (!widget.interactive)
          ...List.generate(Constants.boardSize, (r) {
            return List.generate(Constants.boardSize, (c) {
              final pos = Position(r, c);
              if (board[r][c] == StoneType.none &&
                  pos != widget.highlightPosition) {
                return const SizedBox.shrink();
              }
              final left = (c + 1) * cellSize - stoneSize / 2;
              final top = (r + 1) * cellSize - stoneSize / 2;

              return Positioned(
                left: left,
                top: top,
                width: stoneSize,
                height: stoneSize,
                child: Center(
                  child: NeonStone(
                    type: board[r][c],
                    player1Color: settings.player1Color,
                    player2Color: settings.player2Color,
                    size: stoneSize * 0.9,
                    isHinted: pos == widget.highlightPosition &&
                        board[r][c] == StoneType.none,
                    animate: false,
                  ),
                ),
              );
            });
          }).expand((e) => e),

        // Tournament rule indicator
        if (widget.interactive && gameProvider.state.moveCount == 2 &&
            gameProvider.state.currentPlayer == StoneType.player1)
          _buildTournamentZone(cellSize, settings),
      ],
    );
  }

  Widget _buildCellContent(
    Position pos,
    List<List<StoneType>> board,
    GameProvider gameProvider,
    SettingsProvider settings,
    double stoneSize,
  ) {
    final stone = board[pos.row][pos.col];
    final isLastMove = gameProvider.lastMove == pos && settings.showLastMove;
    final isWinning = gameProvider.state.winningStones?.contains(pos) ?? false;
    final isHinted = gameProvider.highlightedHint == pos && stone == StoneType.none;

    if (stone == StoneType.none && !isHinted) {
      return const SizedBox.shrink();
    }

    return Center(
      child: NeonStone(
        type: stone,
        player1Color: settings.player1Color,
        player2Color: settings.player2Color,
        size: stoneSize * 0.9,
        isLastMove: isLastMove,
        isWinningStone: isWinning,
        isHinted: isHinted,
        moveNumber: gameProvider.getMoveNumber(pos),
        showMoveNumber: gameProvider.showMoveNumbers,
        animate: isLastMove,
      ),
    );
  }

  Widget _buildTournamentZone(double cellSize, SettingsProvider settings) {
    final center = Constants.boardCenter;
    final dist = Constants.tournamentRuleDistance;
    final left = (center - dist + 1.5) * cellSize;
    final top = (center - dist + 1.5) * cellSize;
    final size = (dist * 2 - 1) * cellSize;

    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: NeonTheme.neonRed.withOpacity(0.4),
              width: 1.5,
            ),
            color: NeonTheme.neonRed.withOpacity(0.05),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final Color gridColor;
  final Color accentColor;
  final bool showLabels;

  _BoardPainter({
    required this.gridColor,
    required this.accentColor,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / (Constants.boardSize + 1);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..strokeWidth = 0.5;

    // Draw background grid glow
    final bgRect = Rect.fromLTWH(
      cellSize, cellSize,
      cellSize * (Constants.boardSize - 1),
      cellSize * (Constants.boardSize - 1),
    );
    canvas.drawRect(
      bgRect,
      Paint()
        ..color = accentColor.withOpacity(0.03)
        ..style = PaintingStyle.fill,
    );

    // Draw grid lines
    for (int i = 0; i < Constants.boardSize; i++) {
      final offset = (i + 1) * cellSize;

      // Horizontal lines
      canvas.drawLine(
        Offset(cellSize, offset),
        Offset(cellSize * Constants.boardSize, offset),
        gridPaint,
      );

      // Vertical lines
      canvas.drawLine(
        Offset(offset, cellSize),
        Offset(offset, cellSize * Constants.boardSize),
        gridPaint,
      );
    }

    // Draw star points (standard Pente markers)
    final starPoints = [
      const Position(3, 3), const Position(3, 9), const Position(3, 15),
      const Position(9, 3), const Position(9, 9), const Position(9, 15),
      const Position(15, 3), const Position(15, 9), const Position(15, 15),
    ];

    final starPaint = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (final point in starPoints) {
      canvas.drawCircle(
        Offset((point.col + 1) * cellSize, (point.row + 1) * cellSize),
        cellSize * 0.12,
        starPaint,
      );
    }

    // Center point (larger)
    canvas.drawCircle(
      Offset((Constants.boardCenter + 1) * cellSize,
          (Constants.boardCenter + 1) * cellSize),
      cellSize * 0.18,
      Paint()..color = accentColor.withOpacity(0.6),
    );

    // Draw labels
    if (showLabels) {
      final textStyle = TextStyle(
        color: accentColor.withOpacity(0.4),
        fontSize: cellSize * 0.35,
        fontFamily: NeonTheme.fontFamily,
      );

      for (int i = 0; i < Constants.boardSize; i++) {
        // Column labels (A-S)
        final colLabel = String.fromCharCode(65 + i);
        _drawText(canvas, colLabel, Offset((i + 1) * cellSize, cellSize * 0.35),
            textStyle);

        // Row labels (19-1)
        final rowLabel = (Constants.boardSize - i).toString();
        _drawText(canvas, rowLabel,
            Offset(cellSize * 0.35, (i + 1) * cellSize), textStyle);
      }
    }

    // Draw outer border glow
    final borderPaint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(bgRect, borderPaint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) =>
      gridColor != oldDelegate.gridColor ||
      accentColor != oldDelegate.accentColor ||
      showLabels != oldDelegate.showLabels;
}

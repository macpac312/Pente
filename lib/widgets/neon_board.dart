import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/board_theme.dart';
import '../models/position.dart';
import '../main.dart' show boardThemeNotifier;
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import 'neon_stone.dart';

class NeonBoard extends StatefulWidget {
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

  /// When true, touch-drag zooms the board to ~9×9 and shows a crosshair
  /// for precise stone placement (designed for mobile).
  final bool dragToPlace;

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
    this.dragToPlace = false,
  });

  @override
  State<NeonBoard> createState() => _NeonBoardState();
}

class _NeonBoardState extends State<NeonBoard> {
  // ── Drag-to-place state ────────────────────────────────────────────
  bool _isDragging = false;

  /// Target position in board-cell coordinates (floating point).
  Offset _targetCellPos = Offset.zero;

  /// Snapped target as a board [Position] (null if off-board).
  Position? _targetSnapped;

  /// Cached board pixel size for coordinate math.
  double _boardPixelSize = 0;

  // ── Helpers ────────────────────────────────────────────────────────

  int get _size => widget.board.length;
  int get _center => widget.board.length ~/ 2;

  bool get _showTournamentZone =>
      widget.moveCount == 2 && widget.currentPlayer == StoneType.player1;

  /// Zoom factor: a 19×19 board shows ~9 cells → ~2.1× zoom.
  double get _zoomScale {
    if (_size <= 9) return 1.0;
    return _size / 9.0;
  }

  /// Finger-to-crosshair offset in logical pixels (~1 cm).
  static const double _fingerOffset = 60.0;

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

  // ── Drag-to-place pointer handlers ─────────────────────────────────

  bool get _dragEnabled =>
      widget.dragToPlace && widget.interactive && widget.onTap != null;

  void _onPointerDown(PointerDownEvent event) {
    if (!_dragEnabled) return;
    final cellSize = _boardPixelSize / _size;
    setState(() {
      _isDragging = true;
      // First touch: no zoom yet, compute target in unzoomed space.
      _targetCellPos = Offset(
        event.localPosition.dx / cellSize,
        (event.localPosition.dy - _fingerOffset) / cellSize,
      );
      _snap();
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isDragging) return;
    final cellSize = _boardPixelSize / _size;
    // Delta is in screen pixels; divide by (cellSize × zoom) to get cell-delta.
    final scale = _zoomScale;
    final dx = event.delta.dx / (cellSize * scale);
    final dy = event.delta.dy / (cellSize * scale);
    setState(() {
      _targetCellPos = Offset(
        _targetCellPos.dx + dx,
        _targetCellPos.dy + dy,
      );
      _snap();
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isDragging) return;
    final pos = _targetSnapped;
    setState(() {
      _isDragging = false;
      _targetSnapped = null;
    });
    // Only place if the target is a valid on-board position.
    if (pos != null && pos.isValidFor(_size)) {
      widget.onTap!(pos);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_isDragging) return;
    setState(() {
      _isDragging = false;
      _targetSnapped = null;
    });
  }

  void _snap() {
    final col = _targetCellPos.dx.round();
    final row = _targetCellPos.dy.round();
    if (row >= 0 && row < _size && col >= 0 && col < _size) {
      _targetSnapped = Position(row, col);
    } else {
      _targetSnapped = null; // off-board → will not place
    }
  }

  // ── Zoom matrix ────────────────────────────────────────────────────

  Matrix4 _computeZoomMatrix(double boardPx) {
    if (!_isDragging || _zoomScale <= 1.0 || _targetSnapped == null) {
      return Matrix4.identity();
    }

    final scale = _zoomScale;
    final cellSize = boardPx / _size;

    // Center the zoom on the snapped target cell.
    final focalX = (_targetSnapped!.col + 0.5) * cellSize;
    final focalY = (_targetSnapped!.row + 0.5) * cellSize;

    double tx = boardPx / 2 - focalX * scale;
    double ty = boardPx / 2 - focalY * scale;

    // Clamp so the scaled board fills the visible area.
    final minT = -(boardPx * (scale - 1));
    tx = tx.clamp(minT, 0.0);
    ty = ty.clamp(minT, 0.0);

    return Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale, scale);
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bt = widget.themeOverride ?? boardThemeNotifier.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = math.min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: SizedBox(
            width: maxSize,
            height: maxSize,
            child: widget.showLabels
                ? _buildWithLabels(bt)
                : _buildBoardMaybeZoom(bt),
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
                  child: _buildBoardMaybeZoom(bt),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Board with optional zoom ──────────────────────────────────────

  Widget _buildBoardMaybeZoom(BoardThemeData bt) {
    if (!_dragEnabled) {
      return _buildBoardContainer(bt, null);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _boardPixelSize = math.min(constraints.maxWidth, constraints.maxHeight);
        final zoom = _computeZoomMatrix(_boardPixelSize);

        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          behavior: HitTestBehavior.opaque,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Board (zoomed when dragging)
                Transform(
                  transform: zoom,
                  child: SizedBox(
                    width: _boardPixelSize,
                    height: _boardPixelSize,
                    child: _buildBoardContainer(bt, _targetSnapped),
                  ),
                ),

                // Crosshair + ghost stone overlay
                if (_isDragging && _targetSnapped != null)
                  IgnorePointer(
                    child: Transform(
                      transform: zoom,
                      child: CustomPaint(
                        size: Size(_boardPixelSize, _boardPixelSize),
                        painter: _CrosshairPainter(
                          targetRow: _targetSnapped!.row,
                          targetCol: _targetSnapped!.col,
                          boardSize: _size,
                          color: _ghostColor(),
                          boardPixelSize: _boardPixelSize,
                        ),
                      ),
                    ),
                  ),

                // Position label top-left when zoomed
                if (_isDragging && _targetSnapped != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: _buildPositionLabel(),
                  ),

                // "off-board" indicator when target is null
                if (_isDragging && _targetSnapped == null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: NeonTheme.darkBg.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: NeonTheme.neonRed.withAlpha(120)),
                      ),
                      child: Text(
                        'OFF BOARD',
                        style: TextStyle(
                          color: NeonTheme.neonRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _ghostColor() {
    final bt = widget.themeOverride ?? boardThemeNotifier.value;
    return widget.currentPlayer == StoneType.player1
        ? bt.player1Color
        : bt.player2Color;
  }

  Widget _buildPositionLabel() {
    final pos = _targetSnapped!;
    final col = String.fromCharCode(65 + pos.col);
    final row = (_size - pos.row).toString();
    final color = _ghostColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: NeonTheme.darkBg.withAlpha(220),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(120)),
        boxShadow: [NeonTheme.neonGlow(color, blur: 8, spread: 0)],
      ),
      child: Text(
        '$col$row',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // ── Board container with neon border & glow ────────────────────────

  Widget _buildBoardContainer(BoardThemeData bt, Position? dragTarget) {
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
                        child: _buildIntersection(row, col, bt, dragTarget),
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

  // ── Individual intersection ──────────────────────────────────────

  Widget _buildIntersection(
      int row, int col, BoardThemeData bt, Position? dragTarget) {
    final pos = Position(row, col);
    final stone = widget.board[row][col];
    final isLast = widget.lastMove == pos;
    final isWinning = widget.winningStones?.contains(pos) ?? false;
    final isHighlight =
        widget.highlightPosition == pos && stone == StoneType.none;
    final isRestricted =
        _showTournamentZone && _isInTournamentZone(row, col);
    final isDragTarget = dragTarget == pos && stone == StoneType.none;

    // When dragToPlace is active, disable per-cell taps.
    final tapHandler = (!widget.dragToPlace && widget.interactive && widget.onTap != null)
        ? () => widget.onTap!(pos)
        : null;

    return GestureDetector(
      onTap: tapHandler,
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
              if (stone == StoneType.none &&
                  !isDragTarget &&
                  _isStarPoint(row, col, _size))
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
              if (isHighlight && !isDragTarget)
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

              // Ghost stone (semi-transparent preview while dragging)
              if (isDragTarget)
                Opacity(
                  opacity: 0.55,
                  child: NeonStone(
                    type: widget.currentPlayer,
                    size: stoneSize,
                    themeOverride: widget.themeOverride,
                  ),
                ),

              // Stone on the intersection
              if (stone != StoneType.none)
                NeonStone(
                  type: stone,
                  size: stoneSize,
                  isLastMove: isLast,
                  isWinning: isWinning,
                  themeOverride: widget.themeOverride,
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── CustomPainter: crosshair ────────────────────────────────────────────

class _CrosshairPainter extends CustomPainter {
  final int targetRow;
  final int targetCol;
  final int boardSize;
  final Color color;
  final double boardPixelSize;

  _CrosshairPainter({
    required this.targetRow,
    required this.targetCol,
    required this.boardSize,
    required this.color,
    required this.boardPixelSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = boardPixelSize / boardSize;
    final cx = (targetCol + 0.5) * cellSize;
    final cy = (targetRow + 0.5) * cellSize;

    // Thin lines spanning the full board
    final linePaint = Paint()
      ..color = color.withAlpha(60)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(cx, 0), Offset(cx, boardPixelSize), linePaint);
    canvas.drawLine(Offset(0, cy), Offset(boardPixelSize, cy), linePaint);

    // Brighter crosshair near the center
    final brightPaint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final arm = cellSize * 1.2;
    canvas.drawLine(
        Offset(cx - arm, cy), Offset(cx + arm, cy), brightPaint);
    canvas.drawLine(
        Offset(cx, cy - arm), Offset(cx, cy + arm), brightPaint);

    // Glow circle around the target
    final glowPaint = Paint()
      ..color = color.withAlpha(35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), cellSize * 0.7, glowPaint);

    final ringPaint = Paint()
      ..color = color.withAlpha(120)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), cellSize * 0.55, ringPaint);
  }

  @override
  bool shouldRepaint(_CrosshairPainter old) =>
      targetRow != old.targetRow ||
      targetCol != old.targetCol ||
      color != old.color;
}

// ── CustomPainter: grid lines ───────────────────────────────────────────

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

// ── CustomPainter: tournament boundary ──────────────────────────────────

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

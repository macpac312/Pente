import '../models/game_state.dart';
import '../models/position.dart';
import '../models/move_record.dart';
import '../utils/constants.dart';

class PenteEngine {
  /// Check if a move is valid given the current game state.
  static bool isValidMove(GameState state, Position pos) {
    if (!pos.isValid) return false;
    if (state.board[pos.row][pos.col] != StoneType.none) return false;
    if (state.isGameOver) return false;

    // First move must be at center
    if (state.moveCount == 0) {
      return pos.row == Constants.boardCenter && pos.col == Constants.boardCenter;
    }

    // Tournament rule: player 1's second move must be >= 3 away from center
    if (state.moveCount == 2 && state.currentPlayer == StoneType.player1) {
      final center = const Position(Constants.boardCenter, Constants.boardCenter);
      if (pos.distanceTo(center) < Constants.tournamentRuleDistance) {
        return false;
      }
    }

    return true;
  }

  /// Make a move and return the new game state.
  static GameState makeMove(GameState state, Position pos) {
    if (!isValidMove(state, pos)) return state;

    // Create a mutable copy of the board
    final newBoard = state.board.map((row) => List<StoneType>.from(row)).toList();
    final player = state.currentPlayer;
    newBoard[pos.row][pos.col] = player;

    // Check for captures
    final captured = _findCaptures(newBoard, pos, player);
    for (final capturedPos in captured) {
      newBoard[capturedPos.row][capturedPos.col] = StoneType.none;
    }

    int p1Captures = state.player1Captures;
    int p2Captures = state.player2Captures;
    final capturedPairs = captured.length ~/ 2;
    if (player == StoneType.player1) {
      p1Captures += capturedPairs;
    } else {
      p2Captures += capturedPairs;
    }

    final moveRecord = MoveRecord(
      position: pos,
      player: player,
      moveNumber: state.moveCount + 1,
      capturedStones: captured,
      timestamp: DateTime.now(),
    );

    final newHistory = List<MoveRecord>.from(state.moveHistory)..add(moveRecord);
    final newMoveCount = state.moveCount + 1;
    final nextPlayer = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;

    // Check win conditions
    final winResult = _checkWin(newBoard, pos, player, p1Captures, p2Captures);

    return GameState(
      board: newBoard,
      currentPlayer: winResult != null ? player : nextPlayer,
      player1Captures: p1Captures,
      player2Captures: p2Captures,
      moveHistory: newHistory,
      phase: winResult != null ? GamePhase.finished : GamePhase.playing,
      winner: winResult?.winner,
      moveCount: newMoveCount,
      winningStones: winResult?.winningLine,
    );
  }

  /// Find all captures resulting from placing a stone at pos.
  static List<Position> _findCaptures(
      List<List<StoneType>> board, Position pos, StoneType player) {
    final opponent =
        player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    final captured = <Position>[];

    for (final dir in Constants.directions) {
      for (final sign in [1, -1]) {
        final dr = dir[0] * sign;
        final dc = dir[1] * sign;

        final p1 = Position(pos.row + dr, pos.col + dc);
        final p2 = Position(pos.row + dr * 2, pos.col + dc * 2);
        final p3 = Position(pos.row + dr * 3, pos.col + dc * 3);

        if (p1.isValid &&
            p2.isValid &&
            p3.isValid &&
            board[p1.row][p1.col] == opponent &&
            board[p2.row][p2.col] == opponent &&
            board[p3.row][p3.col] == player) {
          captured.addAll([p1, p2]);
        }
      }
    }

    return captured;
  }

  /// Check for win conditions.
  static _WinResult? _checkWin(
    List<List<StoneType>> board,
    Position lastMove,
    StoneType player,
    int p1Captures,
    int p2Captures,
  ) {
    final winLine = _checkFiveInRow(board, lastMove, player);
    if (winLine != null) {
      return _WinResult(winner: player, winningLine: winLine);
    }

    if (player == StoneType.player1 && p1Captures >= Constants.capturesNeededToWin) {
      return _WinResult(winner: StoneType.player1);
    }
    if (player == StoneType.player2 && p2Captures >= Constants.capturesNeededToWin) {
      return _WinResult(winner: StoneType.player2);
    }

    return null;
  }

  /// Check if the last move creates 5 (or more) in a row.
  static List<Position>? _checkFiveInRow(
      List<List<StoneType>> board, Position pos, StoneType player) {
    for (final dir in Constants.directions) {
      final line = <Position>[pos];

      for (int i = 1; i < Constants.boardSize; i++) {
        final next = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
        if (!next.isValid || board[next.row][next.col] != player) break;
        line.add(next);
      }

      for (int i = 1; i < Constants.boardSize; i++) {
        final next = Position(pos.row - dir[0] * i, pos.col - dir[1] * i);
        if (!next.isValid || board[next.row][next.col] != player) break;
        line.insert(0, next);
      }

      if (line.length >= Constants.stonesInRowToWin) {
        return line;
      }
    }
    return null;
  }

  /// Get all valid moves for the current state.
  static List<Position> getValidMoves(GameState state) {
    final moves = <Position>[];
    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        final pos = Position(r, c);
        if (isValidMove(state, pos)) {
          moves.add(pos);
        }
      }
    }
    return moves;
  }

  /// Get "interesting" moves near existing stones (for AI efficiency).
  static List<Position> getNeighborMoves(GameState state, {int radius = 2}) {
    if (state.moveCount == 0) {
      return [const Position(Constants.boardCenter, Constants.boardCenter)];
    }

    final seen = <Position>{};
    final moves = <Position>[];

    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (state.board[r][c] != StoneType.none) {
          for (int dr = -radius; dr <= radius; dr++) {
            for (int dc = -radius; dc <= radius; dc++) {
              final pos = Position(r + dr, c + dc);
              if (pos.isValid &&
                  !seen.contains(pos) &&
                  isValidMove(state, pos)) {
                seen.add(pos);
                moves.add(pos);
              }
            }
          }
        }
      }
    }

    return moves.isEmpty ? getValidMoves(state) : moves;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  PATTERN-BASED EVALUATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Evaluate a board position from the perspective of the given player.
  /// Uses 5-cell window scanning for comprehensive pattern detection.
  static double evaluatePosition(GameState state, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    double score = 0;

    // 1. Capture score
    final playerCaptures = state.capturesFor(player);
    final opponentCaptures = state.capturesFor(opponent);
    score += playerCaptures * 80;
    score -= opponentCaptures * 80;
    // Near-win capture bonus
    if (playerCaptures >= 4) score += 400;
    if (opponentCaptures >= 4) score -= 400;

    // 2. Pattern-based evaluation (5-window scanning)
    score += _evaluateAllPatterns(state.board, player);
    score -= _evaluateAllPatterns(state.board, opponent);

    // 3. Pair vulnerability
    score -= _countVulnerablePairs(state.board, player) * 45;
    score += _countVulnerablePairs(state.board, opponent) * 45;

    // 4. Capture threats (moves that would capture)
    score += _countCaptureThreats(state, player) * 20;
    score -= _countCaptureThreats(state, opponent) * 20;

    return score;
  }

  /// Scan all 5-cell windows across the board and score patterns for a player.
  static double _evaluateAllPatterns(List<List<StoneType>> board, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    double score = 0;

    for (final dir in Constants.directions) {
      for (int r = 0; r < Constants.boardSize; r++) {
        for (int c = 0; c < Constants.boardSize; c++) {
          // Check if a 5-cell window fits starting at (r,c) in this direction
          final endR = r + dir[0] * 4;
          final endC = c + dir[1] * 4;
          if (endR < 0 || endR >= Constants.boardSize ||
              endC < 0 || endC >= Constants.boardSize) continue;

          int playerCount = 0;
          bool hasOpponent = false;
          int pattern = 0; // bitmask: bit i = player stone at position i

          for (int i = 0; i < 5; i++) {
            final stone = board[r + dir[0] * i][c + dir[1] * i];
            if (stone == player) {
              playerCount++;
              pattern |= (1 << i);
            } else if (stone == opponent) {
              hasOpponent = true;
              break;
            }
          }

          if (hasOpponent || playerCount == 0) continue;

          // Check cells just outside the window for open-endedness
          final beforeR = r - dir[0];
          final beforeC = c - dir[1];
          final afterR = r + dir[0] * 5;
          final afterC = c + dir[1] * 5;

          bool openBefore = _isCellEmpty(board, beforeR, beforeC);
          bool openAfter = _isCellEmpty(board, afterR, afterC);

          score += _scoreWindowPattern(playerCount, pattern, openBefore, openAfter);
        }
      }
    }

    return score;
  }

  static bool _isCellEmpty(List<List<StoneType>> board, int r, int c) {
    if (r < 0 || r >= Constants.boardSize || c < 0 || c >= Constants.boardSize) {
      return false; // Off-board = blocked
    }
    return board[r][c] == StoneType.none;
  }

  /// Score a pattern found in a 5-cell window.
  /// pattern is a bitmask where bit i means player stone at position i.
  static double _scoreWindowPattern(
      int playerCount, int pattern, bool openBefore, bool openAfter) {
    switch (playerCount) {
      case 5:
        return 100000.0;

      case 4:
        // Four stones in 5 cells - very threatening
        if (pattern == 0x0F) {
          // 01111: XXXX_ - four at start, gap at position 4
          // Left end open = openBefore, right gap = always open within window
          return openBefore ? 9000.0 : 4500.0;
        } else if (pattern == 0x1E) {
          // 11110: _XXXX - four at end, gap at position 0
          return openAfter ? 9000.0 : 4500.0;
        } else {
          // Split/stretch tessera: 11101(29), 11011(27), 10111(23)
          // Gap in middle - opponent must fill exact spot to block
          return 7000.0;
        }

      case 3:
        return _scoreTriaPattern(pattern, openBefore, openAfter);

      case 2:
        return _scoreTwoPattern(pattern, openBefore, openAfter);

      case 1:
        return 1.0;

      default:
        return 0.0;
    }
  }

  /// Score a 3-stone pattern within a 5-cell window.
  static double _scoreTriaPattern(int pattern, bool openBefore, bool openAfter) {
    // Open Tria: _XXX_ (pattern 14 = positions 1,2,3)
    if (pattern == 14) {
      return 500.0; // Both ends open within window - very strong
    }

    // Tria at start: XXX__ (pattern 7 = positions 0,1,2)
    if (pattern == 7) {
      return openBefore ? 200.0 : 80.0;
    }

    // Tria at end: __XXX (pattern 28 = positions 2,3,4)
    if (pattern == 28) {
      return openAfter ? 200.0 : 80.0;
    }

    // Stretch trias (3 stones with exactly 1 gap between stones)
    // Strong stretch trias (open on both sides of window):
    // _XX_X (22): positions 1,2,4 - open at 0 and 3
    // _X_XX (26): positions 1,3,4 - open at 0 and 2
    // XX_X_ (11): positions 0,1,3 - open at 2 and 4
    // X_XX_ (13): positions 0,2,3 - open at 1 and 4
    if (pattern == 22 || pattern == 26) {
      // Open on left side (position 0 empty within window)
      return openAfter ? 350.0 : 150.0;
    }
    if (pattern == 11 || pattern == 13) {
      // Open on right side (position 4 empty within window)
      return openBefore ? 350.0 : 150.0;
    }

    // Wide stretch patterns: XX__X(19), X__XX(25), X_X_X(21)
    if (pattern == 21) {
      // X_X_X: double stretch - has potential but needs 2 moves
      return 30.0;
    }
    if (pattern == 19 || pattern == 25) {
      // Wide gap stretch - less immediately threatening
      return 20.0;
    }

    return 10.0; // Other scattered patterns
  }

  /// Score a 2-stone pattern within a 5-cell window.
  static double _scoreTwoPattern(int pattern, bool openBefore, bool openAfter) {
    // Check if adjacent or stretch
    // Adjacent pairs: positions (0,1)=3, (1,2)=6, (2,3)=12, (3,4)=24
    const adjacentPairs = {3, 6, 12, 24};

    // Stretch twos (one gap): (0,2)=5, (1,3)=10, (2,4)=20
    const stretchTwos = {5, 10, 20};

    if (adjacentPairs.contains(pattern)) {
      // Adjacent pair - useful but vulnerable to capture
      if (pattern == 6) {
        // _XX_ (center of window) - both inner ends open
        return 15.0;
      }
      if (pattern == 3) return openBefore ? 12.0 : 5.0;
      if (pattern == 24) return openAfter ? 12.0 : 5.0;
      return 10.0;
    }

    if (stretchTwos.contains(pattern)) {
      // Stretch two (X_X) - safer, not immediately capturable
      if (pattern == 10) {
        // _X_X_ (center positions) - ideal stretch two
        return 22.0;
      }
      if (pattern == 5) return openBefore ? 18.0 : 8.0;
      if (pattern == 20) return openAfter ? 18.0 : 8.0;
      return 15.0;
    }

    // Wide twos (2+ gap): (0,3)=9, (0,4)=17, (1,4)=18
    return 3.0;
  }

  /// Count how many of the player's adjacent pairs are vulnerable to capture.
  static int _countVulnerablePairs(List<List<StoneType>> board, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    int count = 0;

    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (board[r][c] != player) continue;
        for (final dir in Constants.directions) {
          final nr = r + dir[0];
          final nc = c + dir[1];
          if (nr < 0 || nr >= Constants.boardSize ||
              nc < 0 || nc >= Constants.boardSize) continue;
          if (board[nr][nc] != player) continue;

          // We have a pair at (r,c)-(nr,nc). Check if vulnerable.
          final beforeR = r - dir[0];
          final beforeC = c - dir[1];
          final afterR = nr + dir[0];
          final afterC = nc + dir[1];

          // Vulnerable if one end has opponent and other end is empty
          final beforeValid = beforeR >= 0 && beforeR < Constants.boardSize &&
              beforeC >= 0 && beforeC < Constants.boardSize;
          final afterValid = afterR >= 0 && afterR < Constants.boardSize &&
              afterC >= 0 && afterC < Constants.boardSize;

          if (beforeValid && afterValid) {
            final beforeStone = board[beforeR][beforeC];
            final afterStone = board[afterR][afterC];
            if ((beforeStone == opponent && afterStone == StoneType.none) ||
                (beforeStone == StoneType.none && afterStone == opponent)) {
              count++;
            }
          }
        }
      }
    }

    return count ~/ 2; // Each pair is counted twice (from each stone)
  }

  /// Count positions where player can capture opponent's pairs.
  static int _countCaptureThreats(GameState state, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    int threats = 0;

    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (state.board[r][c] != StoneType.none) continue;
        for (final dir in Constants.directions) {
          for (final sign in [1, -1]) {
            final dr = dir[0] * sign;
            final dc = dir[1] * sign;
            final p1 = Position(r + dr, c + dc);
            final p2 = Position(r + dr * 2, c + dc * 2);
            final p3 = Position(r + dr * 3, c + dc * 3);
            if (p1.isValid &&
                p2.isValid &&
                p3.isValid &&
                state.board[p1.row][p1.col] == opponent &&
                state.board[p2.row][p2.col] == opponent &&
                state.board[p3.row][p3.col] == player) {
              threats++;
            }
          }
        }
      }
    }
    return threats;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  SHAPE DETECTION (for Coach & AI)
  // ═══════════════════════════════════════════════════════════════════════

  /// Detect all notable shapes/patterns for a player on the board.
  /// Returns a list of ShapeInfo describing each found shape.
  static List<ShapeInfo> detectShapes(List<List<StoneType>> board, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    final shapes = <ShapeInfo>[];

    for (final dir in Constants.directions) {
      for (int r = 0; r < Constants.boardSize; r++) {
        for (int c = 0; c < Constants.boardSize; c++) {
          final endR = r + dir[0] * 4;
          final endC = c + dir[1] * 4;
          if (endR < 0 || endR >= Constants.boardSize ||
              endC < 0 || endC >= Constants.boardSize) continue;

          int playerCount = 0;
          bool hasOpponent = false;
          int pattern = 0;
          final positions = <Position>[];

          for (int i = 0; i < 5; i++) {
            final cr = r + dir[0] * i;
            final cc = c + dir[1] * i;
            final stone = board[cr][cc];
            if (stone == player) {
              playerCount++;
              pattern |= (1 << i);
              positions.add(Position(cr, cc));
            } else if (stone == opponent) {
              hasOpponent = true;
              break;
            }
          }

          if (hasOpponent || playerCount < 2) continue;

          bool openBefore = _isCellEmpty(board, r - dir[0], c - dir[1]);
          bool openAfter = _isCellEmpty(board, r + dir[0] * 5, c + dir[1] * 5);

          final shape = _classifyPattern(playerCount, pattern, openBefore, openAfter);
          if (shape != null) {
            // Find the empty cells (potential moves) within the window
            final emptyInWindow = <Position>[];
            for (int i = 0; i < 5; i++) {
              if ((pattern & (1 << i)) == 0) {
                emptyInWindow.add(Position(r + dir[0] * i, c + dir[1] * i));
              }
            }

            shapes.add(ShapeInfo(
              type: shape,
              positions: positions,
              keyMoves: emptyInWindow,
              direction: dir,
            ));
          }
        }
      }
    }

    return shapes;
  }

  /// Classify a pattern into a named shape type.
  static ShapeType? _classifyPattern(
      int count, int pattern, bool openBefore, bool openAfter) {
    switch (count) {
      case 5:
        return ShapeType.five;

      case 4:
        if (pattern == 0x0F) {
          return openBefore ? ShapeType.openTessera : ShapeType.closedTessera;
        }
        if (pattern == 0x1E) {
          return openAfter ? ShapeType.openTessera : ShapeType.closedTessera;
        }
        return ShapeType.stretchTessera; // Gap in middle

      case 3:
        if (pattern == 14) return ShapeType.openTria; // _XXX_
        if (pattern == 7) return openBefore ? ShapeType.openTria : ShapeType.closedTria;
        if (pattern == 28) return openAfter ? ShapeType.openTria : ShapeType.closedTria;
        // Stretch trias
        if (pattern == 22 || pattern == 26 || pattern == 11 || pattern == 13) {
          return ShapeType.stretchTria;
        }
        return null; // Too scattered

      case 2:
        // Stretch twos
        if (pattern == 5 || pattern == 10 || pattern == 20) {
          return ShapeType.stretchTwo;
        }
        // Adjacent pairs
        if (pattern == 3 || pattern == 6 || pattern == 12 || pattern == 24) {
          return ShapeType.pair;
        }
        return null;

      default:
        return null;
    }
  }

  /// Detect wedge opportunities: placing between two opponent pairs to threaten both.
  static List<Position> findWedgeOpportunities(
      List<List<StoneType>> board, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    final wedges = <Position>[];

    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (board[r][c] != StoneType.none) continue;
        final pos = Position(r, c);

        // Count how many capture threats this position would create
        int captureThreats = 0;
        for (final dir in Constants.directions) {
          for (final sign in [1, -1]) {
            final dr = dir[0] * sign;
            final dc = dir[1] * sign;
            final p1 = Position(r + dr, c + dc);
            final p2 = Position(r + dr * 2, c + dc * 2);
            final p3 = Position(r + dr * 3, c + dc * 3);
            if (p1.isValid && p2.isValid && p3.isValid &&
                board[p1.row][p1.col] == opponent &&
                board[p2.row][p2.col] == opponent &&
                (board[p3.row][p3.col] == player ||
                 board[p3.row][p3.col] == StoneType.none)) {
              // Already a capture if p3 is player, or a threat if p3 is empty
              if (board[p3.row][p3.col] == StoneType.none) {
                captureThreats++;
              }
            }
          }
        }

        if (captureThreats >= 2) {
          wedges.add(pos);
        }
      }
    }

    return wedges;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  COACH ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════

  /// Analyze a position and return coach hints.
  static List<CoachHint> analyzePosition(GameState state) {
    final hints = <CoachHint>[];
    final player = state.currentPlayer;
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;

    // Check for immediate winning moves
    for (final move in getNeighborMoves(state)) {
      final newState = makeMove(state, move);
      if (newState.winner == player) {
        hints.add(CoachHint(
          type: HintType.winningMove,
          position: move,
          message: 'Winning move available at ${posNotation(move)}!',
          priority: 100,
        ));
      }
    }

    // Check for opponent winning threats
    final opponentState = state.copyWith(currentPlayer: opponent);
    for (final move in getNeighborMoves(opponentState)) {
      final newState = makeMove(opponentState, move);
      if (newState.winner == opponent) {
        hints.add(CoachHint(
          type: HintType.blockThreat,
          position: move,
          message: 'Block opponent\'s winning threat at ${posNotation(move)}!',
          priority: 90,
        ));
      }
    }

    // Check for capture opportunities
    for (final move in getNeighborMoves(state)) {
      final testBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
      testBoard[move.row][move.col] = player;
      final captures = _findCaptures(testBoard, move, player);
      if (captures.isNotEmpty) {
        final pairs = captures.length ~/ 2;
        final currentCaptures = state.capturesFor(player);
        final isWinningCapture = currentCaptures + pairs >= Constants.capturesNeededToWin;

        hints.add(CoachHint(
          type: HintType.captureOpportunity,
          position: move,
          message: isWinningCapture
              ? 'Win by capture! Take $pairs pair(s) at ${posNotation(move)}'
              : 'Capture $pairs pair(s) at ${posNotation(move)}',
          priority: isWinningCapture ? 95 : 70,
        ));
      }
    }

    // Detect shapes and give tactical advice
    _analyzeShapes(state, player, opponent, hints);

    // Check for vulnerable pairs
    _findVulnerablePairs(state, player, hints);

    // Check for wedge opportunities
    final wedges = findWedgeOpportunities(state.board, player);
    for (final pos in wedges) {
      hints.add(CoachHint(
        type: HintType.wedge,
        position: pos,
        message: 'Wedge at ${posNotation(pos)} threatens multiple captures!',
        priority: 65,
      ));
    }

    // Suggest building patterns
    _findBuildOpportunities(state, player, hints);

    hints.sort((a, b) => b.priority.compareTo(a.priority));
    return hints;
  }

  /// Analyze shapes on the board for coaching.
  static void _analyzeShapes(
      GameState state, StoneType player, StoneType opponent,
      List<CoachHint> hints) {
    // Detect opponent's dangerous shapes first
    final opponentShapes = detectShapes(state.board, opponent);
    for (final shape in opponentShapes) {
      if (shape.type == ShapeType.openTessera) {
        // Open tessera is unstoppable - warn urgently
        hints.add(CoachHint(
          type: HintType.blockThreat,
          position: shape.keyMoves.isNotEmpty ? shape.keyMoves.first : shape.positions.first,
          message: 'Opponent has an Open Tessera - unstoppable unless you capture!',
          priority: 88,
        ));
      } else if (shape.type == ShapeType.closedTessera || shape.type == ShapeType.stretchTessera) {
        for (final keyMove in shape.keyMoves) {
          if (state.board[keyMove.row][keyMove.col] == StoneType.none) {
            hints.add(CoachHint(
              type: HintType.blockThreat,
              position: keyMove,
              message: 'Block opponent\'s ${_shapeName(shape.type)} at ${posNotation(keyMove)}',
              priority: 85,
            ));
            break;
          }
        }
      } else if (shape.type == ShapeType.openTria || shape.type == ShapeType.stretchTria) {
        for (final keyMove in shape.keyMoves) {
          if (state.board[keyMove.row][keyMove.col] == StoneType.none) {
            hints.add(CoachHint(
              type: HintType.blockThreat,
              position: keyMove,
              message: 'Block opponent\'s ${_shapeName(shape.type)} at ${posNotation(keyMove)}',
              priority: 75,
            ));
            break;
          }
        }
      }
    }

    // Detect player's opportunities to create strong shapes
    for (final move in getNeighborMoves(state, radius: 2)) {
      final testBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
      testBoard[move.row][move.col] = player;
      final newShapes = detectShapes(testBoard, player);

      for (final shape in newShapes) {
        if (shape.type == ShapeType.openTessera) {
          hints.add(CoachHint(
            type: HintType.openTessera,
            position: move,
            message: 'Create an Open Tessera at ${posNotation(move)} - unstoppable!',
            priority: 82,
          ));
        } else if (shape.type == ShapeType.openTria &&
            !_hasHintAt(hints, HintType.openTria, move)) {
          hints.add(CoachHint(
            type: HintType.openTria,
            position: move,
            message: 'Create an Open Tria at ${posNotation(move)} - hard to defend',
            priority: 60,
          ));
        } else if (shape.type == ShapeType.stretchTria &&
            !_hasHintAt(hints, HintType.stretchTria, move)) {
          hints.add(CoachHint(
            type: HintType.stretchTria,
            position: move,
            message: 'Create a Stretch Tria at ${posNotation(move)} - tricky to block',
            priority: 55,
          ));
        }
      }
    }
  }

  static bool _hasHintAt(List<CoachHint> hints, HintType type, Position pos) {
    return hints.any((h) => h.type == type && h.position == pos);
  }

  static String _shapeName(ShapeType type) {
    switch (type) {
      case ShapeType.five: return 'Five';
      case ShapeType.openTessera: return 'Open Tessera';
      case ShapeType.closedTessera: return 'Tessera';
      case ShapeType.stretchTessera: return 'Stretch Tessera';
      case ShapeType.openTria: return 'Open Tria';
      case ShapeType.closedTria: return 'Tria';
      case ShapeType.stretchTria: return 'Stretch Tria';
      case ShapeType.stretchTwo: return 'Stretch Two';
      case ShapeType.pair: return 'Pair';
    }
  }

  static void _findVulnerablePairs(
      GameState state, StoneType player, List<CoachHint> hints) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;

    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (state.board[r][c] != player) continue;
        for (final dir in Constants.directions) {
          final nr = r + dir[0];
          final nc = c + dir[1];
          if (nr < 0 || nr >= Constants.boardSize ||
              nc < 0 || nc >= Constants.boardSize) continue;
          if (state.board[nr][nc] != player) continue;

          final before = Position(r - dir[0], c - dir[1]);
          final after = Position(nr + dir[0], nc + dir[1]);
          if (before.isValid &&
              after.isValid &&
              ((state.board[before.row][before.col] == StoneType.none &&
                      state.board[after.row][after.col] == opponent) ||
                  (state.board[before.row][before.col] == opponent &&
                      state.board[after.row][after.col] == StoneType.none))) {
            final threatPos = state.board[before.row][before.col] == StoneType.none
                ? before : after;
            hints.add(CoachHint(
              type: HintType.vulnerablePair,
              position: threatPos,
              message:
                  'Your pair at ${posNotation(Position(r, c))}-${posNotation(Position(nr, nc))} '
                  'is vulnerable! Protect it or use Stretch Twos instead.',
              priority: 60,
            ));
          }
        }
      }
    }
  }

  static void _findBuildOpportunities(
      GameState state, StoneType player, List<CoachHint> hints) {
    for (final move in getNeighborMoves(state, radius: 1)) {
      final testBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
      testBoard[move.row][move.col] = player;

      for (final dir in Constants.directions) {
        int count = 1;
        int openEnds = 0;
        for (int i = 1; i <= 4; i++) {
          final p = Position(move.row + dir[0] * i, move.col + dir[1] * i);
          if (!p.isValid) break;
          if (testBoard[p.row][p.col] == player) {
            count++;
          } else if (testBoard[p.row][p.col] == StoneType.none) {
            openEnds++;
            break;
          } else {
            break;
          }
        }
        for (int i = 1; i <= 4; i++) {
          final p = Position(move.row - dir[0] * i, move.col - dir[1] * i);
          if (!p.isValid) break;
          if (testBoard[p.row][p.col] == player) {
            count++;
          } else if (testBoard[p.row][p.col] == StoneType.none) {
            openEnds++;
            break;
          } else {
            break;
          }
        }

        if (count >= 3 && openEnds >= 1) {
          hints.add(CoachHint(
            type: HintType.buildLine,
            position: move,
            message:
                'Build a line of $count at ${posNotation(move)} ($openEnds open end${openEnds > 1 ? "s" : ""})',
            priority: 30 + count * 10,
          ));
        }
      }
    }
  }

  /// Convert a board position to chess-style notation (e.g. J10).
  static String posNotation(Position pos) {
    final col = String.fromCharCode(65 + pos.col);
    final row = (Constants.boardSize - pos.row).toString();
    return '$col$row';
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════════════

class _WinResult {
  final StoneType winner;
  final List<Position>? winningLine;

  _WinResult({required this.winner, this.winningLine});
}

/// Shape types recognized in Pente patterns.
enum ShapeType {
  five,
  openTessera,    // _XXXX_ - unstoppable
  closedTessera,  // blocked on one end
  stretchTessera, // gap in middle (XX_XX, XXX_X, etc.)
  openTria,       // _XXX_ - strong threat
  closedTria,     // blocked on one end
  stretchTria,    // X_XX or XX_X with open ends
  stretchTwo,     // X_X - safer than adjacent pair
  pair,           // XX - adjacent, vulnerable to capture
}

/// Information about a detected shape on the board.
class ShapeInfo {
  final ShapeType type;
  final List<Position> positions; // stones that form the shape
  final List<Position> keyMoves;  // empty cells that complete/extend it
  final List<int> direction;

  const ShapeInfo({
    required this.type,
    required this.positions,
    required this.keyMoves,
    required this.direction,
  });
}

enum HintType {
  winningMove,
  blockThreat,
  captureOpportunity,
  vulnerablePair,
  openTessera,
  openTria,
  stretchTria,
  wedge,
  buildLine,
}

class CoachHint {
  final HintType type;
  final Position position;
  final String message;
  final int priority;

  const CoachHint({
    required this.type,
    required this.position,
    required this.message,
    required this.priority,
  });

  String get icon {
    switch (type) {
      case HintType.winningMove:
        return '★';
      case HintType.blockThreat:
        return '⚠';
      case HintType.captureOpportunity:
        return '◎';
      case HintType.vulnerablePair:
        return '⚡';
      case HintType.openTessera:
        return '✦';
      case HintType.openTria:
        return '▲';
      case HintType.stretchTria:
        return '⟡';
      case HintType.wedge:
        return '⧖';
      case HintType.buildLine:
        return '→';
    }
  }
}

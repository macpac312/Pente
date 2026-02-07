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
      // Check both directions along each axis
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
    // Check 5-in-a-row
    final winLine = _checkFiveInRow(board, lastMove, player);
    if (winLine != null) {
      return _WinResult(winner: player, winningLine: winLine);
    }

    // Check capture win (5 pairs)
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

      // Count in positive direction
      for (int i = 1; i < Constants.boardSize; i++) {
        final next = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
        if (!next.isValid || board[next.row][next.col] != player) break;
        line.add(next);
      }

      // Count in negative direction
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

  /// Evaluate a board position from the perspective of the given player.
  /// Returns a score (positive = good for player, negative = bad).
  static double evaluatePosition(GameState state, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    double score = 0;

    // Capture score
    final playerCaptures = state.capturesFor(player);
    final opponentCaptures = state.capturesFor(opponent);
    score += playerCaptures * 50;
    score -= opponentCaptures * 50;

    // Evaluate lines for both players
    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (state.board[r][c] != StoneType.none) {
          final pos = Position(r, c);
          final stone = state.board[r][c];
          final isPlayer = stone == player;

          for (final dir in Constants.directions) {
            final lineScore = _evaluateLine(state.board, pos, stone, dir);
            score += isPlayer ? lineScore : -lineScore;
          }
        }
      }
    }

    // Evaluate capture threats
    score += _evaluateCaptureThreats(state, player) * 15;
    score -= _evaluateCaptureThreats(state, opponent) * 15;

    return score;
  }

  /// Evaluate a line starting from pos in a given direction.
  static double _evaluateLine(
      List<List<StoneType>> board, Position pos, StoneType player, List<int> dir) {
    int count = 0;
    int openEnds = 0;

    // Count forward
    for (int i = 1; i <= 4; i++) {
      final next = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
      if (!next.isValid) break;
      if (board[next.row][next.col] == player) {
        count++;
      } else if (board[next.row][next.col] == StoneType.none) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    // Count backward
    for (int i = 1; i <= 4; i++) {
      final next = Position(pos.row - dir[0] * i, pos.col - dir[1] * i);
      if (!next.isValid) break;
      if (board[next.row][next.col] == player) {
        count++;
      } else if (board[next.row][next.col] == StoneType.none) {
        openEnds++;
        break;
      } else {
        break;
      }
    }

    // Score based on consecutive stones and open ends
    if (count >= 4) return 10000; // winning or near-winning
    if (count == 3 && openEnds == 2) return 500; // open four
    if (count == 3 && openEnds == 1) return 100; // half-open four
    if (count == 2 && openEnds == 2) return 50;  // open three
    if (count == 2 && openEnds == 1) return 10;  // half-open three
    if (count == 1 && openEnds == 2) return 5;   // open two
    return 0;
  }

  /// Count positions where player can capture opponent's pairs.
  static int _evaluateCaptureThreats(GameState state, StoneType player) {
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    int threats = 0;

    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (state.board[r][c] != StoneType.none) continue;
        final pos = Position(r, c);
        // Temporarily place stone and check captures
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
          message: 'Winning move available at ${_posNotation(move)}!',
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
          message: 'Block opponent\'s winning threat at ${_posNotation(move)}!',
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
        hints.add(CoachHint(
          type: HintType.captureOpportunity,
          position: move,
          message: 'Capture ${captures.length ~/ 2} pair(s) at ${_posNotation(move)}',
          priority: 70,
        ));
      }
    }

    // Check for vulnerable pairs
    _findVulnerablePairs(state, player, hints);

    // Suggest building towards 5-in-a-row
    _findBuildOpportunities(state, player, hints);

    hints.sort((a, b) => b.priority.compareTo(a.priority));
    return hints;
  }

  static void _findVulnerablePairs(
      GameState state, StoneType player, List<CoachHint> hints) {
    for (int r = 0; r < Constants.boardSize; r++) {
      for (int c = 0; c < Constants.boardSize; c++) {
        if (state.board[r][c] != player) continue;
        for (final dir in Constants.directions) {
          final next = Position(r + dir[0], c + dir[1]);
          if (next.isValid && state.board[next.row][next.col] == player) {
            // We have a pair, check if it's vulnerable
            final before = Position(r - dir[0], c - dir[1]);
            final after = Position(next.row + dir[0], next.col + dir[1]);
            if (before.isValid &&
                after.isValid &&
                ((state.board[before.row][before.col] == StoneType.none &&
                        _isOpponent(state.board[after.row][after.col], player)) ||
                    (_isOpponent(state.board[before.row][before.col], player) &&
                        state.board[after.row][after.col] == StoneType.none))) {
              hints.add(CoachHint(
                type: HintType.vulnerablePair,
                position: Position(r, c),
                message:
                    'Your pair at ${_posNotation(Position(r, c))} is vulnerable to capture!',
                priority: 60,
              ));
            }
          }
        }
      }
    }
  }

  static bool _isOpponent(StoneType stone, StoneType player) {
    if (player == StoneType.player1) return stone == StoneType.player2;
    return stone == StoneType.player1;
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
                'Build a line of $count at ${_posNotation(move)} (${openEnds} open end${openEnds > 1 ? "s" : ""})',
            priority: 30 + count * 10,
          ));
        }
      }
    }
  }

  static String _posNotation(Position pos) {
    final col = String.fromCharCode(65 + pos.col);
    final row = (Constants.boardSize - pos.row).toString();
    return '$col$row';
  }
}

class _WinResult {
  final StoneType winner;
  final List<Position>? winningLine;

  _WinResult({required this.winner, this.winningLine});
}

enum HintType {
  winningMove,
  blockThreat,
  captureOpportunity,
  vulnerablePair,
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
      case HintType.buildLine:
        return '→';
    }
  }
}

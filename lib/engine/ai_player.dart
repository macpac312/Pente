import 'dart:math';
import '../models/game_state.dart';
import '../models/position.dart';
import '../utils/constants.dart';
import 'pente_engine.dart';

class AIPlayer {
  final AIDifficulty difficulty;
  final Random _random = Random();

  AIPlayer({this.difficulty = AIDifficulty.medium});

  /// Get the best move for the AI player.
  Future<Position> getBestMove(GameState state) async {
    // Add slight delay for UX (feels more natural)
    await Future.delayed(Duration(milliseconds: _thinkingTime));

    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyMove(state);
      case AIDifficulty.medium:
        return _getMediumMove(state);
      case AIDifficulty.hard:
        return _getHardMove(state);
      case AIDifficulty.expert:
        return _getExpertMove(state);
    }
  }

  int get _thinkingTime {
    switch (difficulty) {
      case AIDifficulty.easy:
        return 300;
      case AIDifficulty.medium:
        return 500;
      case AIDifficulty.hard:
        return 800;
      case AIDifficulty.expert:
        return 1000;
    }
  }

  /// Easy: random move near existing stones with basic threat detection.
  Position _getEasyMove(GameState state) {
    final moves = PenteEngine.getNeighborMoves(state);

    // 40% chance to make a smart move
    if (_random.nextDouble() < 0.4) {
      final smart = _findUrgentMove(state);
      if (smart != null) return smart;
    }

    return moves[_random.nextInt(moves.length)];
  }

  /// Medium: checks threats and opportunities, moderate lookahead.
  Position _getMediumMove(GameState state) {
    // Always block immediate wins and take winning moves
    final urgent = _findUrgentMove(state);
    if (urgent != null) return urgent;

    // Evaluate candidate moves
    final moves = PenteEngine.getNeighborMoves(state);
    return _scoreMoves(state, moves);
  }

  /// Hard: deeper evaluation with minimax.
  Position _getHardMove(GameState state) {
    final urgent = _findUrgentMove(state);
    if (urgent != null) return urgent;

    final moves = PenteEngine.getNeighborMoves(state);
    return _minimaxSearch(state, moves, depth: 2);
  }

  /// Expert: deepest search with alpha-beta pruning.
  Position _getExpertMove(GameState state) {
    final urgent = _findUrgentMove(state);
    if (urgent != null) return urgent;

    final moves = PenteEngine.getNeighborMoves(state);
    return _minimaxSearch(state, moves, depth: 3);
  }

  /// Find immediate winning or blocking moves.
  Position? _findUrgentMove(GameState state) {
    final player = state.currentPlayer;
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    final moves = PenteEngine.getNeighborMoves(state);

    // 1. Check for winning move
    for (final move in moves) {
      final newState = PenteEngine.makeMove(state, move);
      if (newState.winner == player) return move;
    }

    // 2. Block opponent's winning move
    final opponentState = state.copyWith(currentPlayer: opponent);
    for (final move in PenteEngine.getNeighborMoves(opponentState)) {
      final newState = PenteEngine.makeMove(opponentState, move);
      if (newState.winner == opponent) {
        if (PenteEngine.isValidMove(state, move)) return move;
      }
    }

    // 3. Create open tessera if possible (unstoppable)
    for (final move in moves) {
      final testBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
      testBoard[move.row][move.col] = player;
      final shapes = PenteEngine.detectShapes(testBoard, player);
      if (shapes.any((s) => s.type == ShapeType.openTessera)) {
        return move;
      }
    }

    // 4. Block opponent's open tria (which becomes an open tessera next turn)
    for (final move in PenteEngine.getNeighborMoves(opponentState)) {
      final testBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
      testBoard[move.row][move.col] = opponent;
      final shapes = PenteEngine.detectShapes(testBoard, opponent);
      if (shapes.any((s) => s.type == ShapeType.openTessera)) {
        if (PenteEngine.isValidMove(state, move)) return move;
      }
    }

    return null;
  }

  /// Score moves and return the best one (greedy, single depth).
  Position _scoreMoves(GameState state, List<Position> moves) {
    final player = state.currentPlayer;
    double bestScore = double.negativeInfinity;
    Position bestMove = moves.first;

    for (final move in moves) {
      final newState = PenteEngine.makeMove(state, move);
      double score = PenteEngine.evaluatePosition(newState, player);

      // Bonus for captures
      final captured = newState.capturesFor(player) - state.capturesFor(player);
      score += captured * 100;

      // Bonus for center proximity (early game)
      if (state.moveCount < 10) {
        final center = state.board.length ~/ 2;
        final centerDist = move.distanceTo(Position(center, center));
        score += (10 - centerDist).clamp(0, 10).toDouble() * 2;
      }

      // Bonus for creating shapes
      score += _evaluateMoveShapes(state, move, player);

      // Add randomness to avoid repetitive play
      score += _random.nextDouble() * 5;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  /// Evaluate the shapes a move would create (for move scoring).
  double _evaluateMoveShapes(GameState state, Position move, StoneType player) {
    final testBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
    testBoard[move.row][move.col] = player;
    final shapes = PenteEngine.detectShapes(testBoard, player);

    double bonus = 0;
    for (final shape in shapes) {
      // Only count shapes that involve the new stone
      if (!shape.positions.contains(move)) continue;

      switch (shape.type) {
        case ShapeType.openTessera:
          bonus += 5000;
          break;
        case ShapeType.closedTessera:
        case ShapeType.stretchTessera:
          bonus += 2000;
          break;
        case ShapeType.openTria:
          bonus += 400;
          break;
        case ShapeType.stretchTria:
          bonus += 300;
          break;
        case ShapeType.closedTria:
          bonus += 80;
          break;
        case ShapeType.stretchTwo:
          bonus += 25; // Prefer stretch twos (safer than pairs)
          break;
        case ShapeType.pair:
          bonus += 10;
          break;
        case ShapeType.five:
          bonus += 100000;
          break;
      }
    }

    // Penalty for creating vulnerable pairs
    final size = state.board.length;
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;
    for (final dir in Constants.directions) {
      final nr = move.row + dir[0];
      final nc = move.col + dir[1];
      if (nr >= 0 && nr < size &&
          nc >= 0 && nc < size &&
          testBoard[nr][nc] == player) {
        // Check if this creates a vulnerable pair
        final beforeR = move.row - dir[0];
        final beforeC = move.col - dir[1];
        final afterR = nr + dir[0];
        final afterC = nc + dir[1];

        if (beforeR >= 0 && beforeR < size &&
            beforeC >= 0 && beforeC < size &&
            afterR >= 0 && afterR < size &&
            afterC >= 0 && afterC < size) {
          if ((testBoard[beforeR][beforeC] == opponent &&
                  testBoard[afterR][afterC] == StoneType.none) ||
              (testBoard[beforeR][beforeC] == StoneType.none &&
                  testBoard[afterR][afterC] == opponent)) {
            bonus -= 50; // Penalty for vulnerable pair
          }
        }
      }
      // Also check in negative direction
      final nr2 = move.row - dir[0];
      final nc2 = move.col - dir[1];
      if (nr2 >= 0 && nr2 < size &&
          nc2 >= 0 && nc2 < size &&
          testBoard[nr2][nc2] == player) {
        final beforeR = nr2 - dir[0];
        final beforeC = nc2 - dir[1];
        final afterR = move.row + dir[0];
        final afterC = move.col + dir[1];

        if (beforeR >= 0 && beforeR < size &&
            beforeC >= 0 && beforeC < size &&
            afterR >= 0 && afterR < size &&
            afterC >= 0 && afterC < size) {
          if ((testBoard[beforeR][beforeC] == opponent &&
                  testBoard[afterR][afterC] == StoneType.none) ||
              (testBoard[beforeR][beforeC] == StoneType.none &&
                  testBoard[afterR][afterC] == opponent)) {
            bonus -= 50;
          }
        }
      }
    }

    return bonus;
  }

  /// Minimax search with alpha-beta pruning.
  Position _minimaxSearch(GameState state, List<Position> moves, {int depth = 2}) {
    final player = state.currentPlayer;
    double bestScore = double.negativeInfinity;
    Position bestMove = moves.first;

    // Limit and prioritize moves for performance
    final candidateMoves = _prioritizeMoves(state, moves).take(15).toList();

    for (final move in candidateMoves) {
      final newState = PenteEngine.makeMove(state, move);
      final score = _minimax(
        newState, depth - 1, double.negativeInfinity, double.infinity, false, player,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  double _minimax(
    GameState state,
    int depth,
    double alpha,
    double beta,
    bool isMaximizing,
    StoneType aiPlayer,
  ) {
    if (depth == 0 || state.isGameOver) {
      return PenteEngine.evaluatePosition(state, aiPlayer);
    }

    final moves = PenteEngine.getNeighborMoves(state);
    final candidateMoves = _prioritizeMoves(state, moves).take(12).toList();

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      for (final move in candidateMoves) {
        final newState = PenteEngine.makeMove(state, move);
        final eval = _minimax(newState, depth - 1, alpha, beta, false, aiPlayer);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in candidateMoves) {
        final newState = PenteEngine.makeMove(state, move);
        final eval = _minimax(newState, depth - 1, alpha, beta, true, aiPlayer);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  /// Sort moves by rough score for better alpha-beta pruning.
  List<Position> _prioritizeMoves(GameState state, List<Position> moves) {
    final player = state.currentPlayer;
    final opponent = player == StoneType.player1 ? StoneType.player2 : StoneType.player1;

    final scored = moves.map((m) {
      final newState = PenteEngine.makeMove(state, m);
      double score = 0;

      // Immediate win
      if (newState.winner == player) score += 100000;

      // Captures
      final cap = newState.capturesFor(player) - state.capturesFor(player);
      score += cap * 200;

      // Check if move creates strong shapes
      final testBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
      testBoard[m.row][m.col] = player;
      final shapes = PenteEngine.detectShapes(testBoard, player);
      for (final shape in shapes) {
        if (!shape.positions.contains(m)) continue;
        switch (shape.type) {
          case ShapeType.openTessera:
            score += 5000;
            break;
          case ShapeType.closedTessera:
          case ShapeType.stretchTessera:
            score += 1500;
            break;
          case ShapeType.openTria:
            score += 400;
            break;
          case ShapeType.stretchTria:
            score += 300;
            break;
          default:
            break;
        }
      }

      // Check if move blocks opponent's shapes
      final oppTestBoard = state.board.map((r) => List<StoneType>.from(r)).toList();
      oppTestBoard[m.row][m.col] = opponent;
      final oppShapes = PenteEngine.detectShapes(oppTestBoard, opponent);
      for (final shape in oppShapes) {
        if (shape.type == ShapeType.openTessera) score += 3000;
        if (shape.type == ShapeType.openTria) score += 200;
      }

      // Center proximity
      final center = state.board.length ~/ 2;
      score += (center - m.distanceTo(Position(center, center))).toDouble();

      return _ScoredMove(m, score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((s) => s.move).toList();
  }
}

class _ScoredMove {
  final Position move;
  final double score;
  _ScoredMove(this.move, this.score);
}

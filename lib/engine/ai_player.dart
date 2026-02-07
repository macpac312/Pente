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
    return _scoreMoves(state, moves, depth: 1);
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
        // Verify we can play here
        if (PenteEngine.isValidMove(state, move)) return move;
      }
    }

    return null;
  }

  /// Score moves and return the best one (greedy, single depth).
  Position _scoreMoves(GameState state, List<Position> moves, {int depth = 1}) {
    final player = state.currentPlayer;
    double bestScore = double.negativeInfinity;
    Position bestMove = moves.first;

    for (final move in moves) {
      final newState = PenteEngine.makeMove(state, move);
      double score = PenteEngine.evaluatePosition(newState, player);

      // Bonus for captures
      final captured = newState.capturesFor(player) - state.capturesFor(player);
      score += captured * 80;

      // Bonus for center proximity
      final centerDist = move.distanceTo(
          const Position(Constants.boardCenter, Constants.boardCenter));
      score += (10 - centerDist).clamp(0, 10).toDouble();

      // Add randomness to avoid repetitive play
      score += _random.nextDouble() * 5;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  /// Minimax search with alpha-beta pruning.
  Position _minimaxSearch(GameState state, List<Position> moves, {int depth = 2}) {
    final player = state.currentPlayer;
    double bestScore = double.negativeInfinity;
    Position bestMove = moves.first;

    // Limit moves for performance
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
    final scored = moves.map((m) {
      final newState = PenteEngine.makeMove(state, m);
      double score = 0;

      // Immediate win
      if (newState.winner == player) score += 100000;

      // Captures
      final cap = newState.capturesFor(player) - state.capturesFor(player);
      score += cap * 100;

      // Center proximity
      score += (9 - m.distanceTo(
          const Position(Constants.boardCenter, Constants.boardCenter))).toDouble();

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

import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/position.dart';
import '../utils/constants.dart';
import '../engine/pente_engine.dart';
import '../engine/ai_player.dart';

class GameProvider extends ChangeNotifier {
  GameState _state = GameState.initial();
  GameMode _mode = GameMode.pvAI;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;
  AIPlayer? _aiPlayer;
  bool _isAIThinking = false;
  bool _coachEnabled = false;
  List<CoachHint> _coachHints = [];
  Position? _lastMove;
  List<Position> _lastCaptured = [];
  bool _showMoveNumbers = false;
  Position? _highlightedHint;

  // Getters
  GameState get state => _state;
  GameMode get mode => _mode;
  AIDifficulty get aiDifficulty => _aiDifficulty;
  bool get isAIThinking => _isAIThinking;
  bool get coachEnabled => _coachEnabled;
  List<CoachHint> get coachHints => _coachHints;
  Position? get lastMove => _lastMove;
  List<Position> get lastCaptured => _lastCaptured;
  bool get showMoveNumbers => _showMoveNumbers;
  Position? get highlightedHint => _highlightedHint;

  bool get isPlayer1Turn => _state.currentPlayer == StoneType.player1;
  bool get isGameOver => _state.isGameOver;
  int get moveCount => _state.moveCount;

  /// Start a new game.
  void newGame({GameMode? mode, AIDifficulty? difficulty}) {
    _mode = mode ?? _mode;
    _aiDifficulty = difficulty ?? _aiDifficulty;
    _state = GameState.initial();
    _lastMove = null;
    _lastCaptured = [];
    _coachHints = [];
    _highlightedHint = null;
    _isAIThinking = false;

    if (_mode == GameMode.pvAI) {
      _aiPlayer = AIPlayer(difficulty: _aiDifficulty);
    } else {
      _aiPlayer = null;
    }

    notifyListeners();
  }

  /// Place a stone at the given position.
  void makeMove(Position pos) {
    if (_isAIThinking) return;
    if (_state.isGameOver) return;
    if (!PenteEngine.isValidMove(_state, pos)) return;

    _executeMove(pos);

    // If playing against AI and game isn't over, let AI move
    if (_mode == GameMode.pvAI &&
        !_state.isGameOver &&
        _state.currentPlayer == StoneType.player2) {
      _doAIMove();
    }
  }

  void _executeMove(Position pos) {
    final oldCaptures1 = _state.player1Captures;
    final oldCaptures2 = _state.player2Captures;

    _state = PenteEngine.makeMove(_state, pos);
    _lastMove = pos;

    // Track what was captured this move
    if (_state.moveHistory.isNotEmpty) {
      _lastCaptured = _state.moveHistory.last.capturedStones;
    }

    // Update coach hints
    if (_coachEnabled && !_state.isGameOver) {
      _coachHints = PenteEngine.analyzePosition(_state);
    } else {
      _coachHints = [];
    }

    _highlightedHint = null;
    notifyListeners();
  }

  /// Let the AI make a move.
  Future<void> _doAIMove() async {
    if (_aiPlayer == null) return;

    _isAIThinking = true;
    notifyListeners();

    try {
      final aiMove = await _aiPlayer!.getBestMove(_state);
      _executeMove(aiMove);
    } catch (e) {
      // Fallback: make a random valid move
      final moves = PenteEngine.getNeighborMoves(_state);
      if (moves.isNotEmpty) {
        _executeMove(moves.first);
      }
    }

    _isAIThinking = false;
    notifyListeners();
  }

  /// Undo the last move (and AI response if applicable).
  void undoMove() {
    if (_state.moveHistory.isEmpty) return;
    if (_isAIThinking) return;

    // In PvAI mode, undo both the AI and player move
    int undoCount = (_mode == GameMode.pvAI && _state.moveHistory.length >= 2) ? 2 : 1;

    for (int i = 0; i < undoCount; i++) {
      if (_state.moveHistory.isEmpty) break;
      _undoSingleMove();
    }

    if (_coachEnabled) {
      _coachHints = PenteEngine.analyzePosition(_state);
    }
    _highlightedHint = null;
    notifyListeners();
  }

  void _undoSingleMove() {
    if (_state.moveHistory.isEmpty) return;

    final lastRecord = _state.moveHistory.last;
    final newBoard = _state.board.map((r) => List<StoneType>.from(r)).toList();

    // Remove placed stone
    newBoard[lastRecord.position.row][lastRecord.position.col] = StoneType.none;

    // Restore captured stones
    final opponent = lastRecord.player == StoneType.player1
        ? StoneType.player2
        : StoneType.player1;
    for (final capturedPos in lastRecord.capturedStones) {
      newBoard[capturedPos.row][capturedPos.col] = opponent;
    }

    int p1Cap = _state.player1Captures;
    int p2Cap = _state.player2Captures;
    if (lastRecord.player == StoneType.player1) {
      p1Cap -= lastRecord.capturedPairs;
    } else {
      p2Cap -= lastRecord.capturedPairs;
    }

    final newHistory = List.from(_state.moveHistory)..removeLast();
    _lastMove = newHistory.isNotEmpty ? (newHistory.last as dynamic).position : null;
    _lastCaptured = [];

    _state = GameState(
      board: newBoard,
      currentPlayer: lastRecord.player,
      player1Captures: p1Cap,
      player2Captures: p2Cap,
      moveHistory: newHistory.cast(),
      phase: GamePhase.playing,
      winner: null,
      moveCount: _state.moveCount - 1,
      winningStones: null,
    );
  }

  /// Toggle coach mode.
  void toggleCoach() {
    _coachEnabled = !_coachEnabled;
    if (_coachEnabled && !_state.isGameOver) {
      _coachHints = PenteEngine.analyzePosition(_state);
    } else {
      _coachHints = [];
    }
    _highlightedHint = null;
    notifyListeners();
  }

  /// Highlight a coach hint on the board.
  void highlightHint(CoachHint hint) {
    _highlightedHint = hint.position;
    notifyListeners();
  }

  void clearHighlight() {
    _highlightedHint = null;
    notifyListeners();
  }

  /// Toggle move number display.
  void toggleMoveNumbers() {
    _showMoveNumbers = !_showMoveNumbers;
    notifyListeners();
  }

  /// Get the move number at a position (for display).
  int? getMoveNumber(Position pos) {
    for (final record in _state.moveHistory) {
      if (record.position == pos) return record.moveNumber;
    }
    return null;
  }

  /// Check if a position is valid for the current tournament rule.
  bool isTournamentRestricted(Position pos) {
    if (_state.moveCount == 2 && _state.currentPlayer == StoneType.player1) {
      final center = const Position(Constants.boardCenter, Constants.boardCenter);
      return pos.distanceTo(center) < Constants.tournamentRuleDistance;
    }
    return false;
  }
}

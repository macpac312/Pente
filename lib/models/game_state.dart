import '../utils/constants.dart';
import 'position.dart';
import 'move_record.dart';

class GameState {
  final List<List<StoneType>> board;
  final StoneType currentPlayer;
  final int player1Captures; // number of pairs captured
  final int player2Captures;
  final List<MoveRecord> moveHistory;
  final GamePhase phase;
  final StoneType? winner;
  final int moveCount;
  final List<Position>? winningStones; // 5-in-a-row positions

  const GameState({
    required this.board,
    this.currentPlayer = StoneType.player1,
    this.player1Captures = 0,
    this.player2Captures = 0,
    this.moveHistory = const [],
    this.phase = GamePhase.playing,
    this.winner,
    this.moveCount = 0,
    this.winningStones,
  });

  factory GameState.initial() {
    final board = List.generate(
      Constants.boardSize,
      (_) => List.filled(Constants.boardSize, StoneType.none),
    );
    return GameState(board: board);
  }

  GameState copyWith({
    List<List<StoneType>>? board,
    StoneType? currentPlayer,
    int? player1Captures,
    int? player2Captures,
    List<MoveRecord>? moveHistory,
    GamePhase? phase,
    StoneType? winner,
    int? moveCount,
    List<Position>? winningStones,
  }) {
    return GameState(
      board: board ?? this.board.map((row) => List<StoneType>.from(row)).toList(),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      player1Captures: player1Captures ?? this.player1Captures,
      player2Captures: player2Captures ?? this.player2Captures,
      moveHistory: moveHistory ?? List.from(this.moveHistory),
      phase: phase ?? this.phase,
      winner: winner ?? this.winner,
      moveCount: moveCount ?? this.moveCount,
      winningStones: winningStones ?? this.winningStones,
    );
  }

  StoneType stoneAt(Position pos) {
    if (!pos.isValid) return StoneType.none;
    return board[pos.row][pos.col];
  }

  bool get isGameOver => phase == GamePhase.finished;
  bool get isPlayer1Turn => currentPlayer == StoneType.player1;

  int capturesFor(StoneType player) {
    return player == StoneType.player1 ? player1Captures : player2Captures;
  }
}

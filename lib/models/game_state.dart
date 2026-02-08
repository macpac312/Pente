import 'dart:math' as math;
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

  /// The side length of the board (derived from the board data).
  int get size => board.length;

  /// The center index for this board.
  int get center => board.length ~/ 2;

  factory GameState.initial({int size = Constants.boardSize}) {
    final s = size.clamp(Constants.minBoardSize, Constants.boardSize);
    final board = List.generate(
      s,
      (_) => List.filled(s, StoneType.none),
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
    if (!pos.isValidFor(size)) return StoneType.none;
    return board[pos.row][pos.col];
  }

  bool get isGameOver => phase == GamePhase.finished;
  bool get isPlayer1Turn => currentPlayer == StoneType.player1;

  int capturesFor(StoneType player) {
    return player == StoneType.player1 ? player1Captures : player2Captures;
  }

  // ── Serialization (for LAN multiplayer) ──────────────────────────────

  Map<String, dynamic> toJson() {
    // Encode board as compact string: each cell is 0/1/2
    final buf = StringBuffer();
    for (final row in board) {
      for (final cell in row) {
        buf.write(cell.index);
      }
    }
    return {
      'board': buf.toString(),
      'currentPlayer': currentPlayer.index,
      'p1Captures': player1Captures,
      'p2Captures': player2Captures,
      'moves': moveHistory.map((m) => m.toJson()).toList(),
      'phase': phase.index,
      'winner': winner?.index,
      'moveCount': moveCount,
      'winStones': winningStones?.map((p) => [p.row, p.col]).toList(),
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    final boardStr = json['board'] as String;
    // Derive board size from string length (size² characters)
    final size = math.sqrt(boardStr.length).round();
    final board = List.generate(size, (r) {
      return List.generate(size, (c) {
        final idx = r * size + c;
        return StoneType.values[int.parse(boardStr[idx])];
      });
    });

    final movesJson = json['moves'] as List<dynamic>? ?? [];
    final moves = movesJson
        .map((m) => MoveRecord.fromJson(m as Map<String, dynamic>))
        .toList();

    final winStonesJson = json['winStones'] as List<dynamic>?;
    final winStones = winStonesJson
        ?.map((p) => Position((p as List)[0] as int, p[1] as int))
        .toList();

    return GameState(
      board: board,
      currentPlayer: StoneType.values[json['currentPlayer'] as int],
      player1Captures: json['p1Captures'] as int,
      player2Captures: json['p2Captures'] as int,
      moveHistory: moves,
      phase: GamePhase.values[json['phase'] as int],
      winner: json['winner'] != null
          ? StoneType.values[json['winner'] as int]
          : null,
      moveCount: json['moveCount'] as int,
      winningStones: winStones,
    );
  }
}

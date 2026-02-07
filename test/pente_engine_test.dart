import 'package:flutter_test/flutter_test.dart';
import 'package:neon_pente/engine/pente_engine.dart';
import 'package:neon_pente/models/game_state.dart';
import 'package:neon_pente/models/position.dart';
import 'package:neon_pente/utils/constants.dart';

void main() {
  group('Position', () {
    test('equality works correctly', () {
      expect(const Position(5, 5), equals(const Position(5, 5)));
      expect(const Position(5, 5), isNot(equals(const Position(5, 6))));
    });

    test('isValid checks bounds', () {
      expect(const Position(0, 0).isValid, isTrue);
      expect(const Position(18, 18).isValid, isTrue);
      expect(const Position(-1, 0).isValid, isFalse);
      expect(const Position(0, 19).isValid, isFalse);
    });

    test('distanceTo calculates Chebyshev distance', () {
      expect(const Position(9, 9).distanceTo(const Position(9, 9)), equals(0));
      expect(const Position(9, 9).distanceTo(const Position(9, 12)), equals(3));
      expect(const Position(9, 9).distanceTo(const Position(7, 7)), equals(2));
    });
  });

  group('PenteEngine - Move Validation', () {
    test('first move must be center', () {
      final state = GameState.initial();
      expect(PenteEngine.isValidMove(state, const Position(9, 9)), isTrue);
      expect(PenteEngine.isValidMove(state, const Position(0, 0)), isFalse);
      expect(PenteEngine.isValidMove(state, const Position(5, 5)), isFalse);
    });

    test('cannot place on occupied position', () {
      var state = GameState.initial();
      state = PenteEngine.makeMove(state, const Position(9, 9));
      expect(PenteEngine.isValidMove(state, const Position(9, 9)), isFalse);
    });

    test('tournament rule restricts player 1 second move', () {
      var state = GameState.initial();
      // Move 1: P1 at center
      state = PenteEngine.makeMove(state, const Position(9, 9));
      // Move 2: P2 anywhere
      state = PenteEngine.makeMove(state, const Position(8, 8));
      // Move 3: P1 must be 3+ away from center
      expect(PenteEngine.isValidMove(state, const Position(9, 10)), isFalse); // too close
      expect(PenteEngine.isValidMove(state, const Position(9, 11)), isFalse); // still too close
      expect(PenteEngine.isValidMove(state, const Position(9, 12)), isTrue); // exactly 3 away
      expect(PenteEngine.isValidMove(state, const Position(6, 6)), isTrue); // 3 away diag
    });
  });

  group('PenteEngine - Captures', () {
    test('horizontal capture', () {
      var state = GameState.initial();
      // Set up: P1 at (9,9), P2 at (9,10), P2 at (9,11)
      state = PenteEngine.makeMove(state, const Position(9, 9)); // P1
      state = PenteEngine.makeMove(state, const Position(9, 10)); // P2
      // P1 plays elsewhere (tournament rule won't apply since it's a regular move)
      state = PenteEngine.makeMove(state, const Position(5, 5)); // P1
      state = PenteEngine.makeMove(state, const Position(9, 11)); // P2
      // P1 captures by placing at (9, 12)
      state = PenteEngine.makeMove(state, const Position(9, 12)); // P1

      expect(state.player1Captures, equals(1));
      expect(state.board[9][10], equals(StoneType.none)); // captured
      expect(state.board[9][11], equals(StoneType.none)); // captured
    });

    test('diagonal capture', () {
      var state = GameState.initial();
      state = PenteEngine.makeMove(state, const Position(9, 9)); // P1
      state = PenteEngine.makeMove(state, const Position(10, 10)); // P2
      state = PenteEngine.makeMove(state, const Position(5, 5)); // P1
      state = PenteEngine.makeMove(state, const Position(11, 11)); // P2
      state = PenteEngine.makeMove(state, const Position(12, 12)); // P1

      expect(state.player1Captures, equals(1));
      expect(state.board[10][10], equals(StoneType.none));
      expect(state.board[11][11], equals(StoneType.none));
    });

    test('no self-capture - placing between enemies is safe', () {
      var state = GameState.initial();
      // Manually construct a board where P1 plays between two P2 stones
      final board = List.generate(19, (_) => List.filled(19, StoneType.none));
      board[9][9] = StoneType.player2;
      board[9][11] = StoneType.player2;

      state = GameState(
        board: board,
        currentPlayer: StoneType.player1,
        moveCount: 4, // skip first move restrictions
      );

      state = PenteEngine.makeMove(state, const Position(9, 10));
      // P1 stone should still be there - no self-capture
      expect(state.board[9][10], equals(StoneType.player1));
      expect(state.player2Captures, equals(0));
    });
  });

  group('PenteEngine - Win Conditions', () {
    test('win by 5 in a row horizontal', () {
      final board = List.generate(19, (_) => List.filled(19, StoneType.none));
      board[9][5] = StoneType.player1;
      board[9][6] = StoneType.player1;
      board[9][7] = StoneType.player1;
      board[9][8] = StoneType.player1;

      var state = GameState(
        board: board,
        currentPlayer: StoneType.player1,
        moveCount: 10,
      );

      state = PenteEngine.makeMove(state, const Position(9, 9));
      expect(state.isGameOver, isTrue);
      expect(state.winner, equals(StoneType.player1));
      expect(state.winningStones, isNotNull);
      expect(state.winningStones!.length, equals(5));
    });

    test('win by 5 in a row diagonal', () {
      final board = List.generate(19, (_) => List.filled(19, StoneType.none));
      board[5][5] = StoneType.player1;
      board[6][6] = StoneType.player1;
      board[7][7] = StoneType.player1;
      board[8][8] = StoneType.player1;

      var state = GameState(
        board: board,
        currentPlayer: StoneType.player1,
        moveCount: 10,
      );

      state = PenteEngine.makeMove(state, const Position(9, 9));
      expect(state.isGameOver, isTrue);
      expect(state.winner, equals(StoneType.player1));
    });

    test('win by 5 captures', () {
      final board = List.generate(19, (_) => List.filled(19, StoneType.none));
      // Set up one more capturable pair
      board[9][7] = StoneType.player1;
      board[9][8] = StoneType.player2;
      board[9][9] = StoneType.player2;

      var state = GameState(
        board: board,
        currentPlayer: StoneType.player1,
        player1Captures: 4, // needs one more pair
        moveCount: 20,
      );

      state = PenteEngine.makeMove(state, const Position(9, 10));
      expect(state.isGameOver, isTrue);
      expect(state.winner, equals(StoneType.player1));
      expect(state.player1Captures, equals(5));
    });

    test('6 in a row also wins', () {
      final board = List.generate(19, (_) => List.filled(19, StoneType.none));
      board[9][4] = StoneType.player1;
      board[9][5] = StoneType.player1;
      board[9][6] = StoneType.player1;
      board[9][7] = StoneType.player1;
      board[9][8] = StoneType.player1;

      var state = GameState(
        board: board,
        currentPlayer: StoneType.player1,
        moveCount: 12,
      );

      state = PenteEngine.makeMove(state, const Position(9, 9));
      expect(state.isGameOver, isTrue);
      expect(state.winner, equals(StoneType.player1));
      expect(state.winningStones!.length, equals(6));
    });
  });

  group('PenteEngine - Coach Analysis', () {
    test('detects winning move', () {
      final board = List.generate(19, (_) => List.filled(19, StoneType.none));
      board[9][5] = StoneType.player1;
      board[9][6] = StoneType.player1;
      board[9][7] = StoneType.player1;
      board[9][8] = StoneType.player1;

      final state = GameState(
        board: board,
        currentPlayer: StoneType.player1,
        moveCount: 10,
      );

      final hints = PenteEngine.analyzePosition(state);
      final winHints = hints.where((h) => h.type == HintType.winningMove);
      expect(winHints, isNotEmpty);
    });

    test('detects blocking threat', () {
      final board = List.generate(19, (_) => List.filled(19, StoneType.none));
      board[9][5] = StoneType.player2;
      board[9][6] = StoneType.player2;
      board[9][7] = StoneType.player2;
      board[9][8] = StoneType.player2;

      final state = GameState(
        board: board,
        currentPlayer: StoneType.player1,
        moveCount: 10,
      );

      final hints = PenteEngine.analyzePosition(state);
      final blockHints = hints.where((h) => h.type == HintType.blockThreat);
      expect(blockHints, isNotEmpty);
    });
  });

  group('PenteEngine - Neighbor Moves', () {
    test('first move returns center only', () {
      final state = GameState.initial();
      final moves = PenteEngine.getNeighborMoves(state);
      expect(moves.length, equals(1));
      expect(moves.first, equals(const Position(9, 9)));
    });

    test('returns moves near existing stones', () {
      var state = GameState.initial();
      state = PenteEngine.makeMove(state, const Position(9, 9));
      final moves = PenteEngine.getNeighborMoves(state);
      expect(moves, isNotEmpty);
      // All moves should be within radius 2 of center
      for (final move in moves) {
        expect(move.distanceTo(const Position(9, 9)), lessThanOrEqualTo(2));
      }
    });
  });
}

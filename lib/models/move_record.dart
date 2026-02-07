import '../utils/constants.dart';
import 'position.dart';

class MoveRecord {
  final Position position;
  final StoneType player;
  final int moveNumber;
  final List<Position> capturedStones;
  final DateTime timestamp;

  const MoveRecord({
    required this.position,
    required this.player,
    required this.moveNumber,
    this.capturedStones = const [],
    required this.timestamp,
  });

  bool get hadCapture => capturedStones.isNotEmpty;
  int get capturedPairs => capturedStones.length ~/ 2;

  String get notation {
    final col = String.fromCharCode(65 + position.col); // A-S
    final row = (Constants.boardSize - position.row).toString();
    final capture = hadCapture ? 'x${capturedPairs}' : '';
    return '$col$row$capture';
  }

  @override
  String toString() => 'Move #$moveNumber: ${player == StoneType.player1 ? "P1" : "P2"} at $notation';
}

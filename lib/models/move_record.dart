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

  Map<String, dynamic> toJson() => {
        'r': position.row,
        'c': position.col,
        'p': player.index,
        'n': moveNumber,
        'cap': capturedStones.map((p) => [p.row, p.col]).toList(),
        't': timestamp.millisecondsSinceEpoch,
      };

  factory MoveRecord.fromJson(Map<String, dynamic> json) {
    final capJson = json['cap'] as List<dynamic>? ?? [];
    return MoveRecord(
      position: Position(json['r'] as int, json['c'] as int),
      player: StoneType.values[json['p'] as int],
      moveNumber: json['n'] as int,
      capturedStones: capJson
          .map((p) => Position((p as List)[0] as int, p[1] as int))
          .toList(),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
    );
  }
}

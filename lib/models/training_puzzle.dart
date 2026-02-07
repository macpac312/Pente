import '../utils/constants.dart';
import 'position.dart';

class TrainingPuzzle {
  final String id;
  final String title;
  final String description;
  final String category; // capture, defend, win, threat
  final int difficulty; // 1-5
  final List<StonePlacement> initialStones;
  final Position solutionMove;
  final String explanation;
  final List<Position>? highlightPositions;

  const TrainingPuzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.initialStones,
    required this.solutionMove,
    required this.explanation,
    this.highlightPositions,
  });
}

class StonePlacement {
  final Position position;
  final StoneType type;

  const StonePlacement(this.position, this.type);
}

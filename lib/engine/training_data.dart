import '../models/position.dart';
import '../models/training_puzzle.dart';
import '../utils/constants.dart';

class TrainingData {
  static List<TrainingPuzzle> getAllPuzzles() => [
        ...capturePuzzles,
        ...defendPuzzles,
        ...winPuzzles,
        ...threatPuzzles,
      ];

  static List<TrainingPuzzle> getPuzzlesByCategory(String category) {
    switch (category) {
      case Constants.puzzleCapture:
        return capturePuzzles;
      case Constants.puzzleDefend:
        return defendPuzzles;
      case Constants.puzzleWin:
        return winPuzzles;
      case Constants.puzzleThreat:
        return threatPuzzles;
      default:
        return getAllPuzzles();
    }
  }

  // ===== CAPTURE PUZZLES =====
  static final List<TrainingPuzzle> capturePuzzles = [
    TrainingPuzzle(
      id: 'cap_01',
      title: 'Basic Capture',
      description: 'Capture the opponent\'s pair by flanking them.',
      category: Constants.puzzleCapture,
      difficulty: 1,
      initialStones: [
        StonePlacement(const Position(9, 9), StoneType.player1),
        StonePlacement(const Position(9, 10), StoneType.player2),
        StonePlacement(const Position(9, 11), StoneType.player2),
      ],
      solutionMove: const Position(9, 12),
      explanation:
          'Place your stone to complete the flanking pattern: YOUR-OPP-OPP-YOUR. The two opponent stones are captured.',
    ),
    TrainingPuzzle(
      id: 'cap_02',
      title: 'Diagonal Capture',
      description: 'Capture diagonally placed opponent stones.',
      category: Constants.puzzleCapture,
      difficulty: 1,
      initialStones: [
        StonePlacement(const Position(7, 7), StoneType.player1),
        StonePlacement(const Position(8, 8), StoneType.player2),
        StonePlacement(const Position(9, 9), StoneType.player2),
      ],
      solutionMove: const Position(10, 10),
      explanation:
          'Diagonal captures work the same way. Flank two opponent stones diagonally.',
    ),
    TrainingPuzzle(
      id: 'cap_03',
      title: 'Double Capture',
      description: 'Capture two pairs with a single move!',
      category: Constants.puzzleCapture,
      difficulty: 2,
      initialStones: [
        StonePlacement(const Position(9, 7), StoneType.player1),
        StonePlacement(const Position(9, 8), StoneType.player2),
        StonePlacement(const Position(9, 9), StoneType.player2),
        StonePlacement(const Position(10, 11), StoneType.player2),
        StonePlacement(const Position(11, 12), StoneType.player2),
        StonePlacement(const Position(12, 13), StoneType.player1),
      ],
      solutionMove: const Position(9, 10),
      explanation:
          'One stone can capture multiple pairs simultaneously if it flanks pairs in different directions.',
    ),
    TrainingPuzzle(
      id: 'cap_04',
      title: 'Vertical Capture Setup',
      description: 'Set up a capture along a vertical line.',
      category: Constants.puzzleCapture,
      difficulty: 1,
      initialStones: [
        StonePlacement(const Position(6, 9), StoneType.player1),
        StonePlacement(const Position(7, 9), StoneType.player2),
        StonePlacement(const Position(8, 9), StoneType.player2),
      ],
      solutionMove: const Position(9, 9),
      explanation:
          'Vertical captures follow the same flanking rule. Complete the pattern vertically.',
    ),
    TrainingPuzzle(
      id: 'cap_05',
      title: 'Strategic Capture',
      description: 'This capture also builds your line. Find it!',
      category: Constants.puzzleCapture,
      difficulty: 3,
      initialStones: [
        StonePlacement(const Position(9, 6), StoneType.player1),
        StonePlacement(const Position(9, 7), StoneType.player1),
        StonePlacement(const Position(9, 8), StoneType.player1),
        StonePlacement(const Position(9, 10), StoneType.player2),
        StonePlacement(const Position(9, 11), StoneType.player2),
        StonePlacement(const Position(9, 12), StoneType.player1),
      ],
      solutionMove: const Position(9, 9),
      explanation:
          'This move both extends your line to 4 AND captures the opponent pair. Multi-purpose moves are key!',
    ),
  ];

  // ===== DEFEND PUZZLES =====
  static final List<TrainingPuzzle> defendPuzzles = [
    TrainingPuzzle(
      id: 'def_01',
      title: 'Protect Your Pair',
      description: 'Your pair is about to be captured! Block it.',
      category: Constants.puzzleDefend,
      difficulty: 1,
      initialStones: [
        StonePlacement(const Position(9, 8), StoneType.player2),
        StonePlacement(const Position(9, 9), StoneType.player1),
        StonePlacement(const Position(9, 10), StoneType.player1),
      ],
      solutionMove: const Position(9, 11),
      explanation:
          'By placing your stone at the end of your pair, you prevent the opponent from flanking.',
    ),
    TrainingPuzzle(
      id: 'def_02',
      title: 'Block the Four',
      description: 'Opponent has 4 in a row! Stop them!',
      category: Constants.puzzleDefend,
      difficulty: 2,
      initialStones: [
        StonePlacement(const Position(9, 7), StoneType.player2),
        StonePlacement(const Position(9, 8), StoneType.player2),
        StonePlacement(const Position(9, 9), StoneType.player2),
        StonePlacement(const Position(9, 10), StoneType.player2),
        StonePlacement(const Position(8, 8), StoneType.player1),
        StonePlacement(const Position(10, 10), StoneType.player1),
      ],
      solutionMove: const Position(9, 11),
      explanation:
          'With 4 in a row, the opponent needs just one more. Block the open end!',
    ),
    TrainingPuzzle(
      id: 'def_03',
      title: 'Defend by Capturing',
      description: 'The best defense is a good offense. Capture to break the line.',
      category: Constants.puzzleDefend,
      difficulty: 3,
      initialStones: [
        StonePlacement(const Position(9, 7), StoneType.player2),
        StonePlacement(const Position(9, 8), StoneType.player2),
        StonePlacement(const Position(9, 9), StoneType.player2),
        StonePlacement(const Position(9, 10), StoneType.player2),
        StonePlacement(const Position(9, 6), StoneType.player1),
        StonePlacement(const Position(9, 11), StoneType.player2),
        StonePlacement(const Position(9, 5), StoneType.player2),
        StonePlacement(const Position(9, 4), StoneType.player1),
      ],
      solutionMove: const Position(9, 12),
      explanation:
          'Both ends are blocked or extended. Capture a pair from the line to break their 5-in-a-row threat!',
    ),
    TrainingPuzzle(
      id: 'def_04',
      title: 'Safe Placement',
      description: 'Don\'t create a vulnerable pair! Find the safe move.',
      category: Constants.puzzleDefend,
      difficulty: 2,
      initialStones: [
        StonePlacement(const Position(9, 9), StoneType.player1),
        StonePlacement(const Position(9, 7), StoneType.player2),
        StonePlacement(const Position(9, 12), StoneType.player2),
      ],
      solutionMove: const Position(9, 11),
      explanation:
          'Placing next to your stone towards the opponent creates a vulnerable pair. Place with distance instead.',
    ),
  ];

  // ===== WIN PUZZLES =====
  static final List<TrainingPuzzle> winPuzzles = [
    TrainingPuzzle(
      id: 'win_01',
      title: 'Complete the Five',
      description: 'You have 4 in a row. Finish it!',
      category: Constants.puzzleWin,
      difficulty: 1,
      initialStones: [
        StonePlacement(const Position(9, 7), StoneType.player1),
        StonePlacement(const Position(9, 8), StoneType.player1),
        StonePlacement(const Position(9, 9), StoneType.player1),
        StonePlacement(const Position(9, 10), StoneType.player1),
        StonePlacement(const Position(8, 8), StoneType.player2),
        StonePlacement(const Position(8, 9), StoneType.player2),
        StonePlacement(const Position(10, 10), StoneType.player2),
      ],
      solutionMove: const Position(9, 11),
      explanation: 'Simply complete your 5-in-a-row to win!',
    ),
    TrainingPuzzle(
      id: 'win_02',
      title: 'Diagonal Victory',
      description: 'Find the winning diagonal move.',
      category: Constants.puzzleWin,
      difficulty: 1,
      initialStones: [
        StonePlacement(const Position(6, 6), StoneType.player1),
        StonePlacement(const Position(7, 7), StoneType.player1),
        StonePlacement(const Position(8, 8), StoneType.player1),
        StonePlacement(const Position(10, 10), StoneType.player1),
        StonePlacement(const Position(7, 8), StoneType.player2),
        StonePlacement(const Position(8, 9), StoneType.player2),
        StonePlacement(const Position(6, 7), StoneType.player2),
      ],
      solutionMove: const Position(9, 9),
      explanation: 'Fill the gap in your diagonal line to complete 5 in a row!',
    ),
    TrainingPuzzle(
      id: 'win_03',
      title: 'Win by Capture',
      description: 'You have 4 captured pairs. Get the fifth!',
      category: Constants.puzzleWin,
      difficulty: 2,
      initialStones: [
        StonePlacement(const Position(9, 7), StoneType.player1),
        StonePlacement(const Position(9, 8), StoneType.player2),
        StonePlacement(const Position(9, 9), StoneType.player2),
        StonePlacement(const Position(8, 8), StoneType.player1),
        StonePlacement(const Position(10, 8), StoneType.player1),
      ],
      solutionMove: const Position(9, 10),
      explanation:
          'With 4 pairs already captured, one more capture wins! Flank the opponent pair.',
    ),
    TrainingPuzzle(
      id: 'win_04',
      title: 'Double Threat Win',
      description: 'Create two winning threats. Opponent can only block one!',
      category: Constants.puzzleWin,
      difficulty: 3,
      initialStones: [
        StonePlacement(const Position(9, 7), StoneType.player1),
        StonePlacement(const Position(9, 8), StoneType.player1),
        StonePlacement(const Position(9, 9), StoneType.player1),
        StonePlacement(const Position(7, 9), StoneType.player1),
        StonePlacement(const Position(8, 9), StoneType.player1),
        StonePlacement(const Position(8, 7), StoneType.player2),
        StonePlacement(const Position(10, 10), StoneType.player2),
        StonePlacement(const Position(7, 8), StoneType.player2),
      ],
      solutionMove: const Position(9, 10),
      explanation:
          'This creates an open four horizontally AND extends the vertical line. Opponent can\'t block both!',
    ),
  ];

  // ===== THREAT PUZZLES =====
  static final List<TrainingPuzzle> threatPuzzles = [
    TrainingPuzzle(
      id: 'thr_01',
      title: 'Create Open Three',
      description: 'Build an open three - it\'s hard to stop!',
      category: Constants.puzzleThreat,
      difficulty: 1,
      initialStones: [
        StonePlacement(const Position(9, 8), StoneType.player1),
        StonePlacement(const Position(9, 9), StoneType.player1),
        StonePlacement(const Position(8, 7), StoneType.player2),
        StonePlacement(const Position(10, 10), StoneType.player2),
      ],
      solutionMove: const Position(9, 10),
      explanation:
          'An open three (with both ends free) is a powerful threat. Opponent must respond immediately.',
    ),
    TrainingPuzzle(
      id: 'thr_02',
      title: 'Fork Threat',
      description: 'Create threats in two directions at once.',
      category: Constants.puzzleThreat,
      difficulty: 2,
      initialStones: [
        StonePlacement(const Position(9, 8), StoneType.player1),
        StonePlacement(const Position(9, 9), StoneType.player1),
        StonePlacement(const Position(7, 9), StoneType.player1),
        StonePlacement(const Position(8, 7), StoneType.player2),
        StonePlacement(const Position(10, 10), StoneType.player2),
      ],
      solutionMove: const Position(8, 9),
      explanation:
          'This extends both the horizontal and vertical line, creating a fork that\'s hard to defend.',
    ),
    TrainingPuzzle(
      id: 'thr_03',
      title: 'Capture Threat Setup',
      description: 'Position yourself to threaten a capture.',
      category: Constants.puzzleThreat,
      difficulty: 2,
      initialStones: [
        StonePlacement(const Position(9, 8), StoneType.player2),
        StonePlacement(const Position(9, 9), StoneType.player2),
        StonePlacement(const Position(9, 11), StoneType.player1),
      ],
      solutionMove: const Position(9, 7),
      explanation:
          'Now your stone at the other end threatens a capture. Opponent must respond or lose the pair.',
    ),
    TrainingPuzzle(
      id: 'thr_04',
      title: 'Combined Threat',
      description: 'Threaten both a line extension and a capture.',
      category: Constants.puzzleThreat,
      difficulty: 3,
      initialStones: [
        StonePlacement(const Position(9, 6), StoneType.player1),
        StonePlacement(const Position(9, 7), StoneType.player1),
        StonePlacement(const Position(9, 8), StoneType.player1),
        StonePlacement(const Position(9, 10), StoneType.player2),
        StonePlacement(const Position(9, 11), StoneType.player2),
        StonePlacement(const Position(9, 12), StoneType.player1),
      ],
      solutionMove: const Position(9, 9),
      explanation:
          'This move extends your line to 4 AND captures a pair. The ultimate multi-threat move!',
    ),
  ];
}

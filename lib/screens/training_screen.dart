import 'package:flutter/material.dart';
import '../engine/training_data.dart';
import '../models/training_puzzle.dart';
import '../models/position.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import '../widgets/neon_board.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonTheme.darkBg,
      appBar: AppBar(title: const Text('TRAINING')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(
              context,
              'CAPTURE PUZZLES',
              Icons.gps_fixed,
              NeonTheme.neonOrange,
              'Learn to capture opponent pairs',
              TrainingData.capturePuzzles,
            ),
            const SizedBox(height: 24),
            _buildCategorySection(
              context,
              'DEFEND PUZZLES',
              Icons.shield,
              NeonTheme.neonBlue,
              'Protect your stones from capture',
              TrainingData.defendPuzzles,
            ),
            const SizedBox(height: 24),
            _buildCategorySection(
              context,
              'WIN PUZZLES',
              Icons.emoji_events,
              NeonTheme.neonGreen,
              'Find the winning move',
              TrainingData.winPuzzles,
            ),
            const SizedBox(height: 24),
            _buildCategorySection(
              context,
              'THREAT PUZZLES',
              Icons.flash_on,
              NeonTheme.neonPurple,
              'Create powerful multi-threats',
              TrainingData.threatPuzzles,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    List<TrainingPuzzle> puzzles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: NeonTheme.textSecondary,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: NeonTheme.textSecondary.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Puzzle cards
        ...puzzles.map((puzzle) => _buildPuzzleCard(context, puzzle, color)),
      ],
    );
  }

  Widget _buildPuzzleCard(
      BuildContext context, TrainingPuzzle puzzle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PuzzleScreen(puzzle: puzzle, color: color),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeonTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withAlpha(60),
                width: 1,
              ),
              boxShadow: [
                NeonTheme.neonGlow(color, blur: 4, spread: 0),
              ],
            ),
            child: Row(
              children: [
                // Difficulty stars
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < puzzle.difficulty ? Icons.star : Icons.star_border,
                      size: 12,
                      color: i < puzzle.difficulty
                          ? color
                          : color.withAlpha(50),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        puzzle.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        puzzle.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: NeonTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color.withAlpha(120)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  final TrainingPuzzle puzzle;
  final Color color;

  const PuzzleScreen({super.key, required this.puzzle, required this.color});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late List<List<StoneType>> _board;
  bool _solved = false;
  bool _showHint = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _resetBoard() {
    _board = List.generate(
      Constants.boardSize,
      (_) => List.filled(Constants.boardSize, StoneType.none),
    );
    for (final placement in widget.puzzle.initialStones) {
      _board[placement.position.row][placement.position.col] = placement.type;
    }
    _solved = false;
    _showHint = false;
    _attempts = 0;
  }

  void _handleTap(Position pos) {
    if (_solved) return;
    if (_board[pos.row][pos.col] != StoneType.none) return;

    setState(() {
      _attempts++;
      if (pos == widget.puzzle.solutionMove) {
        _board[pos.row][pos.col] = StoneType.player1;
        _solved = true;
      } else {
        _board[pos.row][pos.col] = StoneType.player1;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _board[pos.row][pos.col] = StoneType.none;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonTheme.darkBg,
      appBar: AppBar(title: Text(widget.puzzle.title)),
      body: Column(
        children: [
          // Puzzle description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeonTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withAlpha(60),
                width: 1,
              ),
              boxShadow: [
                NeonTheme.neonGlow(widget.color, blur: 6, spread: 1),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.puzzle.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_attempts > 2 || _showHint) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Hint: Look at position ${_posNotation(widget.puzzle.solutionMove)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: NeonTheme.neonYellow.withAlpha(180),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: NeonBoard(
                board: _board,
                interactive: true,
                highlightPosition:
                    _showHint ? widget.puzzle.solutionMove : null,
                onTap: _handleTap,
              ),
            ),
          ),

          // Solved banner
          if (_solved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NeonTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: NeonTheme.neonGreen.withAlpha(80),
                  width: 1,
                ),
                boxShadow: [
                  NeonTheme.neonGlow(NeonTheme.neonGreen, blur: 12, spread: 2),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'CORRECT!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: NeonTheme.neonGreen,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.puzzle.explanation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: NeonTheme.textPrimary.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Solved in $_attempts attempt${_attempts > 1 ? "s" : ""}',
                    style: TextStyle(
                      fontSize: 11,
                      color: NeonTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (!_solved)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _showHint = true),
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: const Text('SHOW HINT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NeonTheme.neonYellow.withAlpha(30),
                        foregroundColor: NeonTheme.neonYellow,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: NeonTheme.neonYellow.withAlpha(120)),
                        ),
                      ),
                    ),
                  ),
                if (!_solved) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_solved) {
                        Navigator.pop(context);
                      } else {
                        setState(() => _resetBoard());
                      }
                    },
                    icon: Icon(
                      _solved ? Icons.arrow_back : Icons.refresh,
                      size: 18,
                    ),
                    label: Text(_solved ? 'BACK' : 'RESET'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color.withAlpha(30),
                      foregroundColor: widget.color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                            color: widget.color.withAlpha(120)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _posNotation(Position pos) {
    final col = String.fromCharCode(65 + pos.col);
    final row = (Constants.boardSize - pos.row).toString();
    return '$col$row';
  }
}

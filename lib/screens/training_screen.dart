import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/training_data.dart';
import '../models/training_puzzle.dart';
import '../models/game_state.dart';
import '../models/position.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import '../widgets/neon_board.dart';
import '../widgets/neon_button.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: NeonTheme.darkBg,
      appBar: AppBar(title: const Text('TRAINING')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(
              'CAPTURE PUZZLES',
              Icons.gps_fixed,
              NeonTheme.neonOrange,
              'Learn to capture opponent pairs',
            ),
            _buildPuzzleList(context, TrainingData.capturePuzzles, NeonTheme.neonOrange),
            const SizedBox(height: 24),
            _buildCategoryHeader(
              'DEFEND PUZZLES',
              Icons.shield,
              NeonTheme.neonBlue,
              'Protect your stones from capture',
            ),
            _buildPuzzleList(context, TrainingData.defendPuzzles, NeonTheme.neonBlue),
            const SizedBox(height: 24),
            _buildCategoryHeader(
              'WIN PUZZLES',
              Icons.emoji_events,
              NeonTheme.neonGreen,
              'Find the winning move',
            ),
            _buildPuzzleList(context, TrainingData.winPuzzles, NeonTheme.neonGreen),
            const SizedBox(height: 24),
            _buildCategoryHeader(
              'THREAT PUZZLES',
              Icons.flash_on,
              NeonTheme.neonPurple,
              'Create powerful multi-threats',
            ),
            _buildPuzzleList(context, TrainingData.threatPuzzles, NeonTheme.neonPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
      String title, IconData icon, Color color, String subtitle) {
    return Padding(
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
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: NeonTheme.neonTextShadow(color, intensity: 0.4),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleList(
      BuildContext context, List<TrainingPuzzle> puzzles, Color color) {
    return Column(
      children: puzzles.map((puzzle) {
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
                decoration: NeonTheme.neonBox(
                  color: color.withOpacity(0.4),
                  glowRadius: 3,
                  borderRadius: 12,
                ),
                child: Row(
                  children: [
                    // Difficulty stars
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < puzzle.difficulty
                              ? Icons.star
                              : Icons.star_border,
                          size: 12,
                          color: i < puzzle.difficulty
                              ? color
                              : color.withOpacity(0.2),
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
                              fontFamily: 'Orbitron',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            puzzle.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
        // Wrong move - flash feedback
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
            decoration: NeonTheme.neonBox(
              color: widget.color,
              glowRadius: 6,
              borderRadius: 12,
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
                      color: NeonTheme.neonYellow.withOpacity(0.7),
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
                interactive: false,
                customBoard: _board,
                highlightPosition:
                    _showHint ? widget.puzzle.solutionMove : null,
                onTap: _handleTap,
              ),
            ),
          ),

          // Solution / Actions
          if (_solved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: NeonTheme.neonBox(
                color: NeonTheme.neonGreen,
                glowRadius: 12,
                borderRadius: 12,
              ),
              child: Column(
                children: [
                  Text(
                    'CORRECT!',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: NeonTheme.neonGreen,
                      shadows: NeonTheme.neonTextShadow(NeonTheme.neonGreen),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.puzzle.explanation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Solved in $_attempts attempt${_attempts > 1 ? "s" : ""}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
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
                    child: NeonButton(
                      text: 'SHOW HINT',
                      icon: Icons.lightbulb_outline,
                      color: NeonTheme.neonYellow,
                      height: 44,
                      fontSize: 12,
                      onPressed: () => setState(() => _showHint = true),
                    ),
                  ),
                if (!_solved) const SizedBox(width: 12),
                Expanded(
                  child: NeonButton(
                    text: _solved ? 'BACK' : 'RESET',
                    icon: _solved ? Icons.arrow_back : Icons.refresh,
                    color: widget.color,
                    height: 44,
                    fontSize: 12,
                    onPressed: () {
                      if (_solved) {
                        Navigator.pop(context);
                      } else {
                        setState(() => _resetBoard());
                      }
                    },
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

import 'package:flutter/material.dart';
import '../engine/pente_engine.dart';
import '../engine/ai_player.dart';
import '../models/game_state.dart';
import '../models/position.dart';
import '../models/move_record.dart';
import '../utils/constants.dart';
import '../theme/neon_theme.dart';
import '../widgets/neon_board.dart';
import '../widgets/eval_bar_widget.dart';

class GameScreen extends StatefulWidget {
  final AIDifficulty difficulty;
  final GameMode mode;

  const GameScreen({
    super.key,
    required this.difficulty,
    this.mode = GameMode.pvAI,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  late AIDifficulty _difficulty;
  late GameMode _mode;
  late AIPlayer _aiPlayer;
  Position? _selectedPosition;
  bool _isAIThinking = false;
  bool _showCoach = false;
  bool _isCoachThinking = false;
  List<CoachHint> _coachHints = [];
  CoachHint? _currentHighlight;
  int _evaluation = 0;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _mode = widget.mode;
    _aiPlayer = AIPlayer(difficulty: _difficulty);
    _gameState = GameState.initial();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String get _difficultyLabel {
    switch (_difficulty) {
      case AIDifficulty.easy:
        return 'EASY';
      case AIDifficulty.medium:
        return 'MEDIUM';
      case AIDifficulty.hard:
        return 'HARD';
      case AIDifficulty.expert:
        return 'EXPERT';
    }
  }

  Color get _difficultyColor {
    switch (_difficulty) {
      case AIDifficulty.easy:
        return NeonTheme.neonGreen;
      case AIDifficulty.medium:
        return NeonTheme.neonCyan;
      case AIDifficulty.hard:
        return NeonTheme.neonOrange;
      case AIDifficulty.expert:
        return NeonTheme.neonPink;
    }
  }

  String get _statusText {
    if (_gameState.isGameOver) {
      if (_gameState.winner == null) return 'Draw!';
      if (_mode == GameMode.pvAI) {
        return _gameState.winner == StoneType.player1
            ? 'Player 1 wins!'
            : 'AI wins!';
      }
      return _gameState.winner == StoneType.player1
          ? 'Player 1 wins!'
          : 'Player 2 wins!';
    }
    if (_isAIThinking) return 'AI thinking...';
    if (_mode == GameMode.pvAI) {
      return _gameState.currentPlayer == StoneType.player1
          ? 'Your turn'
          : 'AI thinking...';
    }
    return _gameState.currentPlayer == StoneType.player1
        ? 'Player 1\'s turn'
        : 'Player 2\'s turn';
  }

  Color get _statusColor {
    if (_gameState.isGameOver) {
      if (_gameState.winner == null) return NeonTheme.neonYellow;
      if (_mode == GameMode.pvAI) {
        return _gameState.winner == StoneType.player1
            ? NeonTheme.neonGreen
            : NeonTheme.neonRed;
      }
      return NeonTheme.neonGreen;
    }
    if (_isAIThinking) return NeonTheme.neonMagenta;
    return NeonTheme.neonGreen;
  }

  // ── Game Logic ─────────────────────────────────────────────────────────

  void _onBoardTap(Position pos) {
    if (_isAIThinking) return;
    if (_gameState.isGameOver) return;
    if (!PenteEngine.isValidMove(_gameState, pos)) return;

    setState(() {
      _gameState = PenteEngine.makeMove(_gameState, pos);
      _selectedPosition = null;
      _currentHighlight = null;
    });

    _updateEvaluation();
    _checkGameEnd();

    // Trigger AI move if applicable
    if (_mode == GameMode.pvAI &&
        !_gameState.isGameOver &&
        _gameState.currentPlayer == StoneType.player2) {
      _makeAIMove();
    }

    // Refresh coach hints after player move
    if (_showCoach && !_gameState.isGameOver) {
      _onGetTip();
    }
  }

  Future<void> _makeAIMove() async {
    setState(() => _isAIThinking = true);

    try {
      final move = await _aiPlayer.getBestMove(_gameState);
      if (!mounted) return;

      setState(() {
        _gameState = PenteEngine.makeMove(_gameState, move);
        _isAIThinking = false;
      });

      _updateEvaluation();
      _checkGameEnd();

      // Refresh coach hints after AI move
      if (_showCoach && !_gameState.isGameOver) {
        _onGetTip();
      }
    } catch (e) {
      if (!mounted) return;
      // Fallback: pick the first neighbor move
      final moves = PenteEngine.getNeighborMoves(_gameState);
      if (moves.isNotEmpty) {
        setState(() {
          _gameState = PenteEngine.makeMove(_gameState, moves.first);
          _isAIThinking = false;
        });
        _updateEvaluation();
        _checkGameEnd();
      } else {
        setState(() => _isAIThinking = false);
      }
    }
  }

  void _updateEvaluation() {
    final score =
        PenteEngine.evaluatePosition(_gameState, StoneType.player1);
    setState(() {
      _evaluation = score.round().clamp(-1000, 1000);
    });
  }

  void _checkGameEnd() {
    if (_gameState.isGameOver) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _showGameOverDialog();
      });
    }
  }

  // ── Coach ──────────────────────────────────────────────────────────────

  void _onGetTip() {
    setState(() => _isCoachThinking = true);

    Future.microtask(() {
      final hints = PenteEngine.analyzePosition(_gameState);
      if (mounted) {
        setState(() {
          _coachHints = hints;
          _isCoachThinking = false;
        });
      }
    });
  }

  void _onSuggestMove() {
    if (_coachHints.isEmpty) {
      _onGetTip();
      return;
    }
    setState(() {
      _currentHighlight = _coachHints.first;
      _selectedPosition = _coachHints.first.position;
    });
  }

  // ── Reset ──────────────────────────────────────────────────────────────

  void _resetGame() {
    setState(() {
      _gameState = GameState.initial();
      _isAIThinking = false;
      _coachHints = [];
      _currentHighlight = null;
      _selectedPosition = null;
      _evaluation = 0;
      _isCoachThinking = false;
    });
  }

  // ── Dialogs ────────────────────────────────────────────────────────────

  void _showExitDialog() {
    if (_gameState.isGameOver || _gameState.moveCount == 0) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: NeonTheme.neonCyan.withAlpha(60)),
        ),
        title: Text(
          'LEAVE GAME?',
          style: TextStyle(
            color: NeonTheme.neonCyan,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Your current game will be lost.',
          style: TextStyle(color: NeonTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'STAY',
              style: TextStyle(color: NeonTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'LEAVE',
              style: TextStyle(color: NeonTheme.neonCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: NeonTheme.neonCyan.withAlpha(60)),
        ),
        title: Text(
          'NEW GAME?',
          style: TextStyle(
            color: NeonTheme.neonCyan,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Start a new game? Current progress will be lost.',
          style: TextStyle(color: NeonTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: TextStyle(color: NeonTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetGame();
            },
            child: Text(
              'NEW GAME',
              style: TextStyle(color: NeonTheme.neonGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    final winner = _gameState.winner;

    String title;
    Color titleColor;

    if (winner == null) {
      title = 'DRAW';
      titleColor = NeonTheme.neonYellow;
    } else if (_mode == GameMode.pvAI) {
      if (winner == StoneType.player1) {
        title = 'VICTORY!';
        titleColor = NeonTheme.neonGreen;
      } else {
        title = 'DEFEAT';
        titleColor = NeonTheme.neonRed;
      }
    } else {
      title = winner == StoneType.player1
          ? 'PLAYER 1 WINS!'
          : 'PLAYER 2 WINS!';
      titleColor = NeonTheme.neonGreen;
    }

    final winType =
        _gameState.winningStones != null ? '5 in a row' : 'By capture';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: titleColor.withAlpha(80)),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              winType,
              style: TextStyle(
                color: NeonTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_gameState.moveCount} moves played',
              style: TextStyle(
                color: NeonTheme.textSecondary.withAlpha(150),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'MAIN MENU',
              style: TextStyle(color: NeonTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetGame();
            },
            child: Text(
              'REMATCH',
              style: TextStyle(color: NeonTheme.neonGreen),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pente Academy ──────────────────────────────────────────────────────

  void _showPenteAcademy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: NeonTheme.cardBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(
                    color: NeonTheme.neonGreen.withAlpha(80)),
                left: BorderSide(
                    color: NeonTheme.neonGreen.withAlpha(40)),
                right: BorderSide(
                    color: NeonTheme.neonGreen.withAlpha(40)),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: NeonTheme.textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'PENTE ACADEMY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NeonTheme.neonGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: Text(
                    'Learn Pente strategy from beginner to advanced',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: NeonTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),

                // ── BASICS ──
                _academySectionHeader('BASICS'),
                _academyTopic(
                  'How to Win',
                  'There are two ways to win in Pente:\n\n'
                      '1. Five in a Row: Place 5 or more stones in an unbroken line '
                      '(horizontal, vertical, or diagonal).\n\n'
                      '2. Capture Win: Capture 5 pairs (10 opponent stones total). '
                      'Flank exactly 2 adjacent opponent stones with yours '
                      '(YOUR-OPP-OPP-YOUR) to capture the pair.',
                  Icons.emoji_events,
                  NeonTheme.neonGreen,
                ),
                _academyTopic(
                  'Tournament Rule',
                  'Player 1 must place their first stone at the center (J10). '
                      'Their second stone must be at least 3 intersections from center '
                      '(shown by the red boundary line).\n\n'
                      'This rule exists because the first player has a significant '
                      'advantage. Without it, Player 1 could build unstoppable threats '
                      'from the center too easily.',
                  Icons.gavel,
                  NeonTheme.neonYellow,
                ),
                _academyTopic(
                  'Initiative',
                  'Initiative means making moves that force your opponent to respond '
                      'defensively. When you have the initiative, you control the game.\n\n'
                      'How to gain initiative:\n'
                      '- Create threats that require an immediate response\n'
                      '- Build Open Trias or capture threats\n'
                      '- Make moves that serve dual purposes (attack + defense)\n\n'
                      'How you lose initiative:\n'
                      '- Making purely defensive moves\n'
                      '- Playing moves that don\'t create threats\n\n'
                      'Maintaining initiative is the key to winning at higher levels!',
                  Icons.speed,
                  NeonTheme.neonCyan,
                ),

                // ── BASIC SHAPES ──
                _academySectionHeader('BASIC SHAPES'),
                _academyTopic(
                  'Pair (XX)',
                  'Two adjacent stones in a line. This is the simplest formation.\n\n'
                      'Warning: Pairs are vulnerable to capture! If your opponent has '
                      'a stone on one side, they can place one on the other side to '
                      'capture your pair (OPP-XX-OPP).\n\n'
                      'Tip: Consider using Stretch Twos (X_X) instead of Pairs when '
                      'possible, as they cannot be captured.',
                  Icons.circle,
                  NeonTheme.neonOrange,
                ),
                _academyTopic(
                  'Stretch Two (X_X)',
                  'Two stones with exactly one empty space between them.\n\n'
                      'Advantages over a regular Pair:\n'
                      '- Cannot be captured (not adjacent)\n'
                      '- Can be extended in 3 ways (fill the gap, or extend either end)\n'
                      '- Harder for opponent to block all extensions\n\n'
                      'Stretch Twos are a cornerstone of good Pente play. Prefer them '
                      'over adjacent pairs whenever you can!',
                  Icons.space_bar,
                  NeonTheme.neonBlue,
                ),
                _academyTopic(
                  'Open Tria (_XXX_)',
                  'Three stones in a row with both ends open (empty).\n\n'
                      'This is one of the most powerful shapes in Pente! Your opponent '
                      'must respond immediately, or you will extend to an Open Tessera '
                      'next turn.\n\n'
                      'An Open Tria forces a response because:\n'
                      '- It can be extended to 4 from either end\n'
                      '- Blocking one end leaves the other open\n'
                      '- Only a capture or a block can stop it',
                  Icons.change_history,
                  NeonTheme.neonMagenta,
                ),
                _academyTopic(
                  'Stretch Tria (XX_X / X_XX)',
                  'Three stones with one gap, creating a "stretched" line.\n\n'
                      'Examples: XX_X, X_XX, or patterns like _XX_X_, _X_XX_\n\n'
                      'Why Stretch Trias are powerful:\n'
                      '- Harder to spot and block than regular trias\n'
                      '- Filling the gap creates 4-in-a-row\n'
                      '- The gap can sometimes be misidentified by opponents\n\n'
                      'Like Open Trias, these force your opponent to respond!',
                  Icons.unfold_more,
                  NeonTheme.neonPurple,
                ),
                _academyTopic(
                  'Open Tessera (_XXXX_)',
                  'Four stones in a row with both ends open. This is UNSTOPPABLE!\n\n'
                      'Your opponent cannot block both ends in one move, so you will '
                      'complete five-in-a-row next turn.\n\n'
                      'The only defense against an Open Tessera is to have already '
                      'set up a winning capture threat, or to win first.\n\n'
                      'Goal of every game: create an Open Tessera while preventing '
                      'your opponent from doing the same.',
                  Icons.auto_awesome,
                  NeonTheme.neonGreen,
                ),

                // ── ADVANCED SHAPES ──
                _academySectionHeader('ADVANCED SHAPES'),
                _academyTopic(
                  'I-Shape',
                  'Two Stretch Twos sharing a common stone, forming a straight line '
                      'like X_X_X.\n\n'
                      'This creates a double threat: filling either gap creates a '
                      'Stretch Tria. The opponent must carefully block in the right '
                      'place or face unstoppable escalation.\n\n'
                      'The I-shape is one of the easiest advanced patterns to set up.',
                  Icons.straighten,
                  NeonTheme.neonCyan,
                ),
                _academyTopic(
                  'L-Shape',
                  'Two Stretch Twos sharing a common stone at a 90-degree angle, '
                      'forming an L pattern.\n\n'
                      'This is powerful because filling either gap creates a Stretch Tria '
                      'in a different direction. The opponent can only block one direction '
                      'per move!\n\n'
                      'Look for opportunities to build L-shapes at line intersections.',
                  Icons.turn_right,
                  NeonTheme.neonBlue,
                ),
                _academyTopic(
                  'X-Shape (Double Fork)',
                  'Two Stretch Twos sharing a common stone at opposing angles (e.g., '
                      'both diagonals through one stone).\n\n'
                      'Like the L-shape but even harder to defend against, since the '
                      'threats extend in two non-adjacent directions.\n\n'
                      'Building X-shapes from the center of the board is particularly '
                      'effective as it maximizes your attacking reach.',
                  Icons.close,
                  NeonTheme.neonMagenta,
                ),
                _academyTopic(
                  'H-Shape',
                  'Two Trias on parallel adjacent lines sharing extending stones. '
                      'This creates a complex threat structure.\n\n'
                      'The H-shape often leads to unstoppable combinations because '
                      'the opponent cannot block threats on two separate lines '
                      'simultaneously.\n\n'
                      'These typically arise in the midgame from well-placed Stretch Twos.',
                  Icons.view_column,
                  NeonTheme.neonOrange,
                ),

                // ── CAPTURE TACTICS ──
                _academySectionHeader('CAPTURE TACTICS'),
                _academyTopic(
                  'Wedge',
                  'A Wedge creates multiple capture threats with a single move.\n\n'
                      'Place your stone between two opponent pairs so that you threaten '
                      'to capture in multiple directions at once. The opponent can only '
                      'protect one pair per move!\n\n'
                      'How to set up a Wedge:\n'
                      '- Spot two enemy pairs that share a common adjacent empty cell\n'
                      '- Place your stone at that intersection\n'
                      '- The opponent must lose at least one pair\n\n'
                      'The coach will highlight Wedge opportunities with the Wedge icon.',
                  Icons.compress,
                  NeonTheme.neonRed,
                ),
                _academyTopic(
                  'Extension',
                  'Extension is a capture tactic where you extend a line toward a '
                      'capturable pair.\n\n'
                      'For example: You have a line of 3 (XXX), and two spaces away '
                      'there is an opponent pair (OO) with your stone behind it.\n'
                      'Extending to XXXX threatens both five-in-a-row AND completing '
                      'the capture.\n\n'
                      'The best moves in Pente serve multiple purposes: extending your '
                      'line while threatening captures, or blocking while building.',
                  Icons.open_in_full,
                  NeonTheme.neonPurple,
                ),
                _academyTopic(
                  'Capture Safety',
                  'Avoid creating pairs that can be immediately captured!\n\n'
                      'A pair is vulnerable when:\n'
                      '- One end has an opponent stone\n'
                      '- The other end is empty (opponent can complete the flank)\n\n'
                      'Safe alternatives:\n'
                      '- Use Stretch Twos (X_X) instead of Pairs (XX)\n'
                      '- Place pairs where both ends are protected\n'
                      '- Create pairs only when the capture threat gives you initiative\n\n'
                      'Remember: Losing 5 pairs loses the game, regardless of your '
                      'line progress!',
                  Icons.security,
                  NeonTheme.neonYellow,
                ),

                // ── STRATEGY ──
                _academySectionHeader('STRATEGY'),
                _academyTopic(
                  'Opening Principles',
                  'The opening moves set the tone for the entire game.\n\n'
                      'For Player 1:\n'
                      '- First move is always center (J10)\n'
                      '- Second move must be 3+ away (tournament rule)\n'
                      '- Aim for Stretch Twos pointing toward center\n\n'
                      'For Player 2:\n'
                      '- Place near center to contest control\n'
                      '- Don\'t place adjacent to Player 1 (creates capture risk)\n'
                      '- Look for diagonal development\n\n'
                      'General: Develop in multiple directions early. Don\'t commit '
                      'everything to one line!',
                  Icons.flag,
                  NeonTheme.neonGreen,
                ),
                _academyTopic(
                  'Dual-Purpose Moves',
                  'The strongest moves serve multiple purposes at once:\n\n'
                      '- Attack + Defense: Extend your line while blocking opponent\'s\n'
                      '- Line + Capture: Extend a line toward a capturable pair\n'
                      '- Double Threat: Create threats in two directions simultaneously\n\n'
                      'Always ask yourself: "Does this move do more than one thing?"\n\n'
                      'Moves that only serve one purpose waste tempo (initiative). '
                      'The best players find moves that create problems in multiple '
                      'directions at once.',
                  Icons.all_inclusive,
                  NeonTheme.neonCyan,
                ),
                _academyTopic(
                  'When to Capture',
                  'Captures aren\'t always the best move, even when available!\n\n'
                      'Capture when:\n'
                      '- It wins the game (5th pair)\n'
                      '- It breaks an opponent\'s dangerous line\n'
                      '- It also extends your own position\n'
                      '- You\'re at 4 captures (opponent must play cautiously)\n\n'
                      'Don\'t capture when:\n'
                      '- You have a bigger threat (like creating an Open Tessera)\n'
                      '- The capture doesn\'t improve your position\n'
                      '- Your opponent WANTS you to capture (it may be a trap)\n\n'
                      'Having 4 captures creates enormous pressure: the opponent must '
                      'avoid all pairs!',
                  Icons.gps_fixed,
                  NeonTheme.neonOrange,
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _academySectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: NeonTheme.neonGreen.withAlpha(40)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                color: NeonTheme.neonGreen.withAlpha(150),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: NeonTheme.neonGreen.withAlpha(40)),
          ),
        ],
      ),
    );
  }

  Widget _academyTopic(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: color, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        iconColor: color,
        collapsedIconColor: color.withAlpha(100),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(
                color: NeonTheme.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: NeonTheme.darkerBg,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'NEON PENTE',
        style: TextStyle(
          color: NeonTheme.neonCyan,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: NeonTheme.neonCyan),
        onPressed: _showExitDialog,
      ),
      actions: [
        // AI thinking indicator
        if (_isAIThinking) ...[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation(NeonTheme.neonMagenta),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                'AI thinking...',
                style: TextStyle(
                  color: NeonTheme.neonMagenta,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
        // Coach toggle
        IconButton(
          icon: Icon(
            Icons.school,
            color: _showCoach
                ? NeonTheme.neonGreen
                : NeonTheme.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _showCoach = !_showCoach;
              if (_showCoach && !_gameState.isGameOver) {
                _onGetTip();
              } else {
                _coachHints = [];
                _currentHighlight = null;
              }
            });
          },
          tooltip: 'Toggle Coach',
        ),
        // New game
        IconButton(
          icon: const Icon(Icons.refresh, color: NeonTheme.neonCyan),
          onPressed: _showResetDialog,
          tooltip: 'New Game',
        ),
      ],
    );
  }

  // ── Wide (Desktop) Layout ──────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Eval bar (vertical)
        EvalBar(evaluation: _evaluation, isVertical: true),

        // Board + captures column
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildCapturesRow(StoneType.player2),
              Expanded(child: _buildBoardArea()),
              _buildCapturesRow(StoneType.player1),
            ],
          ),
        ),

        // Right panel (status, moves, coach)
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                  color: NeonTheme.neonCyan.withAlpha(30)),
            ),
          ),
          child: Column(
            children: [
              _buildStatusBar(),
              Divider(
                  height: 1,
                  color: NeonTheme.neonCyan.withAlpha(30)),
              Expanded(child: _buildMoveHistoryPanel()),
              if (_showCoach) ...[
                Divider(
                    height: 1,
                    color: NeonTheme.neonCyan.withAlpha(30)),
                Expanded(child: _buildCoachPanel()),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Narrow (Mobile) Layout ─────────────────────────────────────────────

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildStatusBar(),
        _buildCapturesRow(StoneType.player2),
        Expanded(child: _buildBoardArea()),
        _buildCapturesRow(StoneType.player1),

        // Eval bar (horizontal)
        EvalBar(evaluation: _evaluation, isVertical: false),

        // Bottom panels
        SizedBox(
          height: 160,
          child: _showCoach
              ? DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: NeonTheme.neonCyan,
                        labelColor: NeonTheme.neonCyan,
                        unselectedLabelColor: NeonTheme.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                        tabs: const [
                          Tab(text: 'MOVES'),
                          Tab(text: 'COACH'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildMoveHistoryPanel(),
                            _buildCoachPanel(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : _buildMoveHistoryPanel(),
        ),
      ],
    );
  }

  // ── Status Bar ─────────────────────────────────────────────────────────

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: NeonTheme.darkerBg,
      child: Row(
        children: [
          // Colored status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor,
              boxShadow: [
                BoxShadow(
                  color: _statusColor.withAlpha(100),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Status text
          Expanded(
            child: Text(
              _statusText,
              style: TextStyle(
                color: _statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Difficulty label (PvAI only)
          if (_mode == GameMode.pvAI)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: _difficultyColor.withAlpha(80)),
              ),
              child: Text(
                _difficultyLabel,
                style: TextStyle(
                  color: _difficultyColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Board Area ─────────────────────────────────────────────────────────

  Widget _buildBoardArea() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: NeonBoard(
        board: _gameState.board,
        interactive: !_isAIThinking && !_gameState.isGameOver,
        onTap: _onBoardTap,
        highlightPosition: _selectedPosition,
        lastMove: _gameState.moveHistory.isNotEmpty
            ? _gameState.moveHistory.last.position
            : null,
        winningStones: _gameState.winningStones,
        moveCount: _gameState.moveCount,
        currentPlayer: _gameState.currentPlayer,
      ),
    );
  }

  // ── Captures Row ───────────────────────────────────────────────────────

  Widget _buildCapturesRow(StoneType player) {
    final captures = player == StoneType.player1
        ? _gameState.player1Captures
        : _gameState.player2Captures;
    final color = player == StoneType.player1
        ? NeonTheme.player1Color
        : NeonTheme.player2Color;
    final isActive =
        _gameState.currentPlayer == player && !_gameState.isGameOver;
    final name = _mode == GameMode.pvAI
        ? (player == StoneType.player1 ? 'YOU' : 'AI')
        : (player == StoneType.player1 ? 'P1' : 'P2');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Player indicator dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color : color.withAlpha(80),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                          color: color.withAlpha(100), blurRadius: 6)
                    ]
                  : [],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: isActive ? color : color.withAlpha(120),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            'CAPTURES',
            style: TextStyle(
              color: NeonTheme.textSecondary.withAlpha(120),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          // Capture dots (filled = captured pair)
          ...List.generate(
            Constants.capturesNeededToWin,
            (i) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < captures ? color : color.withAlpha(30),
                boxShadow: i < captures
                    ? [
                        BoxShadow(
                            color: color.withAlpha(120),
                            blurRadius: 4)
                      ]
                    : [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Move History Panel ─────────────────────────────────────────────────

  Widget _buildMoveHistoryPanel() {
    final moves = _gameState.moveHistory;

    if (moves.isEmpty) {
      return Center(
        child: Text(
          'No moves yet',
          style: TextStyle(
            color: NeonTheme.textSecondary.withAlpha(100),
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: (moves.length / 2).ceil(),
      itemBuilder: (context, index) {
        final moveNum = index + 1;
        final p1Idx = index * 2;
        final p2Idx = index * 2 + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              // Move number
              SizedBox(
                width: 32,
                child: Text(
                  '$moveNum.',
                  style: TextStyle(
                    color: NeonTheme.textSecondary.withAlpha(120),
                    fontSize: 12,
                  ),
                ),
              ),
              // Player 1 move
              Expanded(
                child: Text(
                  moves[p1Idx].notation,
                  style: TextStyle(
                    color: NeonTheme.player1Color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Player 2 move (if exists)
              if (p2Idx < moves.length)
                Expanded(
                  child: Text(
                    moves[p2Idx].notation,
                    style: TextStyle(
                      color: NeonTheme.player2Color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
  }

  // ── Coach Panel ────────────────────────────────────────────────────────

  Widget _buildCoachPanel() {
    return Container(
      color: NeonTheme.darkBg,
      child: Column(
        children: [
          // Header row: label + action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.school,
                    color: NeonTheme.neonGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  'COACH',
                  style: TextStyle(
                    color: NeonTheme.neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                // Suggest best move
                GestureDetector(
                  onTap: _onSuggestMove,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: NeonTheme.neonGreen.withAlpha(80)),
                    ),
                    child: Text(
                      'SUGGEST',
                      style: TextStyle(
                        color: NeonTheme.neonGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Open Pente Academy
                GestureDetector(
                  onTap: _showPenteAcademy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: NeonTheme.neonBlue.withAlpha(80)),
                    ),
                    child: Text(
                      'ACADEMY',
                      style: TextStyle(
                        color: NeonTheme.neonBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: NeonTheme.neonGreen.withAlpha(30)),

          // Body: loading, empty, or hint list
          if (_isCoachThinking)
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                        NeonTheme.neonGreen),
                  ),
                ),
              ),
            )
          else if (_coachHints.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Make a move to get hints',
                  style: TextStyle(
                    color: NeonTheme.textSecondary.withAlpha(100),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _coachHints.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  return _buildHintTile(_coachHints[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHintTile(CoachHint hint) {
    final isHighlighted = _currentHighlight == hint;
    final color = _hintColor(hint.type);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_currentHighlight == hint) {
            _currentHighlight = null;
            _selectedPosition = null;
          } else {
            _currentHighlight = hint;
            _selectedPosition = hint.position;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              isHighlighted ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted
              ? Border.all(color: color.withAlpha(80), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Hint icon circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(40),
                border:
                    Border.all(color: color.withAlpha(120), width: 1),
              ),
              child: Center(
                child: Text(
                  hint.icon,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Hint message
            Expanded(
              child: Text(
                hint.message,
                style: TextStyle(
                  fontSize: 11,
                  color: isHighlighted
                      ? color
                      : NeonTheme.textPrimary.withAlpha(180),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Visibility indicator
            Icon(
              isHighlighted
                  ? Icons.visibility
                  : Icons.visibility_off,
              size: 14,
              color: color.withAlpha(isHighlighted ? 200 : 60),
            ),
          ],
        ),
      ),
    );
  }

  Color _hintColor(HintType type) {
    switch (type) {
      case HintType.winningMove:
        return NeonTheme.neonGreen;
      case HintType.blockThreat:
        return NeonTheme.neonRed;
      case HintType.captureOpportunity:
        return NeonTheme.neonOrange;
      case HintType.vulnerablePair:
        return NeonTheme.neonYellow;
      case HintType.openTessera:
        return NeonTheme.neonGreen;
      case HintType.openTria:
        return NeonTheme.neonCyan;
      case HintType.stretchTria:
        return NeonTheme.neonPurple;
      case HintType.wedge:
        return NeonTheme.neonOrange;
      case HintType.buildLine:
        return NeonTheme.neonCyan;
    }
  }
}

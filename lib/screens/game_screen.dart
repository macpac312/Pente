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
                const SizedBox(height: 20),
                _academyTopic(
                  'Captures',
                  'Flank exactly 2 adjacent opponent stones '
                      '(YOUR-OPP-OPP-YOUR) to capture the pair. '
                      'Captured stones are removed from the board. '
                      'Capture 5 pairs to win!',
                  Icons.catching_pokemon,
                  NeonTheme.neonOrange,
                ),
                _academyTopic(
                  '5 in a Row',
                  'Place 5 or more stones in an unbroken line '
                      '(horizontal, vertical, or diagonal) to win. '
                      'Building open-ended lines of 3 or 4 creates '
                      'powerful threats.',
                  Icons.linear_scale,
                  NeonTheme.neonCyan,
                ),
                _academyTopic(
                  'Tournament Rule',
                  'Player 1 must place their first stone at the center. '
                      'Their second stone must be at least 3 intersections '
                      'away from center. This balances the first-move '
                      'advantage.',
                  Icons.gavel,
                  NeonTheme.neonYellow,
                ),
                _academyTopic(
                  'Threats & Offense',
                  'Create multiple threats simultaneously. An open-ended '
                      'line of 4 is unstoppable. Look for moves that '
                      'threaten both a capture and extending a line.',
                  Icons.bolt,
                  NeonTheme.neonRed,
                ),
                _academyTopic(
                  'Defense',
                  'Always check for opponent\'s winning threats before '
                      'making your move. Protect your pairs from being '
                      'captured. Block open-ended lines of 3 early.',
                  Icons.shield,
                  NeonTheme.neonBlue,
                ),
              ],
            ),
          );
        },
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
      case HintType.buildLine:
        return NeonTheme.neonCyan;
    }
  }
}

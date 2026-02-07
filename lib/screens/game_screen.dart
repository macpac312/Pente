import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import '../widgets/neon_board.dart';
import '../widgets/neon_button.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/coach_panel.dart';
import '../widgets/move_history.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: NeonTheme.darkBg,
      appBar: _buildAppBar(context, game, settings),
      body: Column(
        children: [
          const GameInfoPanel(),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: NeonBoard(interactive: !game.isAIThinking),
            ),
          ),
          const CoachPanel(),
          const MoveHistory(),
          _buildBottomBar(context, game, settings),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, GameProvider game, SettingsProvider settings) {
    return AppBar(
      title: Text(
        game.mode == GameMode.pvAI
            ? 'VS COMPUTER'
            : 'VS PLAYER',
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: settings.accentColor),
        onPressed: () => _confirmExit(context, game),
      ),
      actions: [
        // Coach toggle
        IconButton(
          icon: Icon(
            Icons.school,
            color: game.coachEnabled
                ? NeonTheme.neonGreen
                : Colors.white.withOpacity(0.3),
          ),
          onPressed: () => game.toggleCoach(),
          tooltip: 'Toggle Coach',
        ),
        // Move numbers toggle
        IconButton(
          icon: Icon(
            Icons.format_list_numbered,
            color: game.showMoveNumbers
                ? settings.accentColor
                : Colors.white.withOpacity(0.3),
          ),
          onPressed: () => game.toggleMoveNumbers(),
          tooltip: 'Toggle Move Numbers',
        ),
        // Menu
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: settings.accentColor),
          color: NeonTheme.darkCard,
          onSelected: (value) => _handleMenuAction(context, value, game),
          itemBuilder: (context) => [
            _menuItem('new_game', Icons.refresh, 'New Game', settings.accentColor),
            _menuItem('undo', Icons.undo, 'Undo Move', NeonTheme.neonYellow),
            _menuItem('resign', Icons.flag, 'Resign', NeonTheme.neonRed),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String text, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, GameProvider game, SettingsProvider settings) {
    if (!game.state.isGameOver) return const SizedBox(height: 8);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWinMessage(game, settings),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  text: 'NEW GAME',
                  icon: Icons.refresh,
                  color: NeonTheme.neonGreen,
                  height: 48,
                  fontSize: 13,
                  onPressed: () => game.newGame(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonButton(
                  text: 'HOME',
                  icon: Icons.home,
                  color: NeonTheme.neonCyan,
                  height: 48,
                  fontSize: 13,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinMessage(GameProvider game, SettingsProvider settings) {
    final winner = game.state.winner;
    if (winner == null) return const SizedBox.shrink();

    final isP1 = winner == StoneType.player1;
    final color = isP1 ? settings.player1Color : settings.player2Color;
    final winType = game.state.winningStones != null ? '5 IN A ROW' : 'BY CAPTURE';

    String winnerName;
    if (game.mode == GameMode.pvAI) {
      winnerName = isP1 ? 'YOU WIN' : 'AI WINS';
    } else {
      winnerName = isP1 ? 'PLAYER 1 WINS' : 'PLAYER 2 WINS';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: NeonTheme.neonBox(
        color: color,
        glowRadius: 16,
        borderRadius: 12,
      ),
      child: Column(
        children: [
          Text(
            winnerName,
            style: TextStyle(
              fontFamily: NeonTheme.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: NeonTheme.neonTextShadow(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            winType,
            style: TextStyle(
              fontFamily: NeonTheme.fontFamily,
              fontSize: 11,
              color: color.withOpacity(0.7),
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, String action, GameProvider game) {
    switch (action) {
      case 'new_game':
        _showNewGameDialog(context, game);
        break;
      case 'undo':
        game.undoMove();
        break;
      case 'resign':
        _showResignDialog(context, game);
        break;
    }
  }

  void _showNewGameDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: NeonTheme.neonCyan.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Text(
          'NEW GAME?',
          style: TextStyle(
            fontFamily: NeonTheme.fontFamily,
            color: NeonTheme.neonCyan,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Start a new game? Current progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              game.newGame();
            },
            child: const Text('NEW GAME',
                style: TextStyle(color: NeonTheme.neonGreen)),
          ),
        ],
      ),
    );
  }

  void _showResignDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: NeonTheme.neonRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Text(
          'RESIGN?',
          style: TextStyle(
            fontFamily: NeonTheme.fontFamily,
            color: NeonTheme.neonRed,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to resign this game?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Force game over
              game.newGame(); // Reset for simplicity
              Navigator.pop(context);
            },
            child: const Text('RESIGN',
                style: TextStyle(color: NeonTheme.neonRed)),
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context, GameProvider game) {
    if (game.state.isGameOver || game.moveCount == 0) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: NeonTheme.neonYellow.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Text(
          'LEAVE GAME?',
          style: TextStyle(
            fontFamily: NeonTheme.fontFamily,
            color: NeonTheme.neonYellow,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Your current game will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('STAY',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('LEAVE',
                style: TextStyle(color: NeonTheme.neonYellow)),
          ),
        ],
      ),
    );
  }
}

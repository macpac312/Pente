import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _PlayerInfo(
            name: game.mode == GameMode.pvAI ? 'YOU' : 'P1',
            color: settings.player1Color,
            captures: game.state.player1Captures,
            isActive: game.state.currentPlayer == StoneType.player1 &&
                !game.state.isGameOver,
            isWinner: game.state.winner == StoneType.player1,
          ),
          const Spacer(),
          _GameStatus(game: game),
          const Spacer(),
          _PlayerInfo(
            name: game.mode == GameMode.pvAI ? 'AI' : 'P2',
            color: settings.player2Color,
            captures: game.state.player2Captures,
            isActive: game.state.currentPlayer == StoneType.player2 &&
                !game.state.isGameOver,
            isWinner: game.state.winner == StoneType.player2,
            alignRight: true,
          ),
        ],
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  final String name;
  final Color color;
  final int captures;
  final bool isActive;
  final bool isWinner;
  final bool alignRight;

  const _PlayerInfo({
    required this.name,
    required this.color,
    required this.captures,
    this.isActive = false,
    this.isWinner = false,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: NeonTheme.neonBox(
        color: isActive || isWinner ? color : color.withOpacity(0.3),
        glowRadius: isWinner ? 16 : (isActive ? 10 : 4),
        borderRadius: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!alignRight) _buildStoneIndicator(),
              if (!alignRight) const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive || isWinner ? color : color.withOpacity(0.5),
                  shadows: isActive || isWinner
                      ? NeonTheme.neonTextShadow(color, intensity: 0.5)
                      : [],
                ),
              ),
              if (alignRight) const SizedBox(width: 6),
              if (alignRight) _buildStoneIndicator(),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Captures: ',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              ...List.generate(
                Constants.capturesNeededToWin,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < captures ? color : color.withOpacity(0.15),
                    boxShadow: i < captures
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
          if (isWinner)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'WINNER!',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: NeonTheme.neonYellow,
                  shadows: NeonTheme.neonTextShadow(NeonTheme.neonYellow),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoneIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _GameStatus extends StatelessWidget {
  final GameProvider game;

  const _GameStatus({required this.game});

  @override
  Widget build(BuildContext context) {
    String status;
    Color statusColor;

    if (game.state.isGameOver) {
      if (game.state.winner == StoneType.player1) {
        status = game.mode == GameMode.pvAI ? 'YOU WIN!' : 'P1 WINS!';
        statusColor = NeonTheme.neonGreen;
      } else {
        status = game.mode == GameMode.pvAI ? 'AI WINS!' : 'P2 WINS!';
        statusColor = NeonTheme.neonRed;
      }
    } else if (game.isAIThinking) {
      status = 'THINKING...';
      statusColor = NeonTheme.neonYellow;
    } else {
      status = 'MOVE ${game.moveCount + 1}';
      statusColor = Colors.white.withOpacity(0.5);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          status,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: statusColor,
            shadows: game.state.isGameOver
                ? NeonTheme.neonTextShadow(statusColor, intensity: 0.5)
                : [],
          ),
        ),
        if (game.isAIThinking)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SizedBox(
              width: 60,
              child: LinearProgressIndicator(
                backgroundColor: NeonTheme.darkCard,
                valueColor:
                    AlwaysStoppedAnimation(NeonTheme.neonYellow.withOpacity(0.5)),
              ),
            ),
          ),
      ],
    );
  }
}

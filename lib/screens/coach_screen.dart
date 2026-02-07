import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';
import 'game_screen.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: NeonTheme.darkBg,
      appBar: AppBar(title: const Text('COACH MODE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFeatureCard(
              'REAL-TIME HINTS',
              'Get move suggestions during gameplay. The coach analyzes '
                  'threats, captures, and winning opportunities.',
              Icons.lightbulb,
              NeonTheme.neonGreen,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              'THREAT DETECTION',
              'See when your opponent is about to win or capture your '
                  'stones. Never miss a critical defense.',
              Icons.warning_amber,
              NeonTheme.neonRed,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              'CAPTURE RADAR',
              'Highlights positions where you can capture opponent pairs. '
                  'Also warns about your vulnerable pairs.',
              Icons.gps_fixed,
              NeonTheme.neonOrange,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              'LINE BUILDER',
              'Suggests moves that extend your lines towards 5-in-a-row. '
                  'Prioritizes open-ended formations.',
              Icons.timeline,
              NeonTheme.neonCyan,
            ),
            const SizedBox(height: 32),
            _buildDifficultySelector(context, settings),
            const SizedBox(height: 24),
            NeonButton(
              text: 'START COACHED GAME',
              icon: Icons.play_arrow,
              color: NeonTheme.neonGreen,
              onPressed: () => _startCoachedGame(context, settings),
            ),
            const SizedBox(height: 12),
            _buildTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: NeonTheme.neonBox(
        color: NeonTheme.neonGreen,
        glowRadius: 10,
        borderRadius: 16,
      ),
      child: Column(
        children: [
          Icon(
            Icons.school,
            size: 48,
            color: NeonTheme.neonGreen,
            shadows: [
              Shadow(
                color: NeonTheme.neonGreen.withOpacity(0.5),
                blurRadius: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'PENTE COACH',
            style: TextStyle(
              fontFamily: NeonTheme.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: NeonTheme.neonGreen,
              shadows: NeonTheme.neonTextShadow(NeonTheme.neonGreen),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn to play like a pro with real-time hints '
            'and analysis during your games.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeonTheme.neonBox(
        color: color.withOpacity(0.4),
        glowRadius: 4,
        borderRadius: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: NeonTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(
      BuildContext context, SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI OPPONENT LEVEL',
          style: TextStyle(
            fontFamily: NeonTheme.fontFamily,
            fontSize: 12,
            color: NeonTheme.neonGreen.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: AIDifficulty.values.map((diff) {
            final isSelected = settings.defaultDifficulty == diff;
            final color = _difficultyColor(diff);
            return Expanded(
              child: GestureDetector(
                onTap: () => settings.setDefaultDifficulty(diff),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? color.withOpacity(0.2) : NeonTheme.darkCard,
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.2),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _difficultyName(diff),
                      style: TextStyle(
                        fontFamily: NeonTheme.fontFamily,
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? color : color.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: NeonTheme.neonYellow.withOpacity(0.05),
        border: Border.all(
          color: NeonTheme.neonYellow.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: NeonTheme.neonYellow.withOpacity(0.5), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: You can also toggle the coach during any game '
              'using the mortarboard icon in the top bar.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startCoachedGame(BuildContext context, SettingsProvider settings) {
    final game = context.read<GameProvider>();
    game.newGame(
      mode: GameMode.pvAI,
      difficulty: settings.defaultDifficulty,
    );
    game.toggleCoach();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  String _difficultyName(AIDifficulty diff) {
    switch (diff) {
      case AIDifficulty.easy:
        return 'EASY';
      case AIDifficulty.medium:
        return 'MED';
      case AIDifficulty.hard:
        return 'HARD';
      case AIDifficulty.expert:
        return 'PRO';
    }
  }

  Color _difficultyColor(AIDifficulty diff) {
    switch (diff) {
      case AIDifficulty.easy:
        return NeonTheme.neonGreen;
      case AIDifficulty.medium:
        return NeonTheme.neonCyan;
      case AIDifficulty.hard:
        return NeonTheme.neonOrange;
      case AIDifficulty.expert:
        return NeonTheme.neonRed;
    }
  }
}


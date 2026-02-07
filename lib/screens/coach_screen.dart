import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  AIDifficulty _selectedDifficulty = AIDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            _buildDifficultySelector(),
            const SizedBox(height: 24),
            _buildStartButton(),
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
      decoration: BoxDecoration(
        color: NeonTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NeonTheme.neonGreen.withAlpha(60),
          width: 1,
        ),
        boxShadow: [
          NeonTheme.neonGlow(NeonTheme.neonGreen, blur: 10, spread: 1),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NeonTheme.neonGreen.withAlpha(30),
              border: Border.all(
                color: NeonTheme.neonGreen.withAlpha(80),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.school,
              size: 36,
              color: NeonTheme.neonGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'PENTE COACH',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: NeonTheme.neonGreen,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn to play like a pro with real-time hints '
            'and analysis during your games.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: NeonTheme.textSecondary,
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
      decoration: BoxDecoration(
        color: NeonTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(40),
          width: 1,
        ),
        boxShadow: [
          NeonTheme.neonGlow(color, blur: 4, spread: 0),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(30),
              border: Border.all(color: color.withAlpha(80), width: 1),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: NeonTheme.textSecondary,
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

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI OPPONENT LEVEL',
          style: TextStyle(
            fontSize: 12,
            color: NeonTheme.textSecondary,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: AIDifficulty.values.map((diff) {
            final isSelected = _selectedDifficulty == diff;
            final color = _difficultyColor(diff);
            final depth = _difficultyDepth(diff);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDifficulty = diff),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? color.withAlpha(40)
                        : NeonTheme.cardBg,
                    border: Border.all(
                      color: isSelected ? color : color.withAlpha(40),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                    boxShadow: isSelected
                        ? [NeonTheme.neonGlow(color, blur: 8, spread: 1)]
                        : [],
                  ),
                  child: Column(
                    children: [
                      // Radio dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? color : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? color : color.withAlpha(80),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [NeonTheme.neonGlow(color, blur: 4, spread: 0)]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _difficultyName(diff),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : color.withAlpha(100),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Depth $depth',
                        style: TextStyle(
                          fontSize: 8,
                          color: isSelected
                              ? color.withAlpha(150)
                              : NeonTheme.textSecondary.withAlpha(80),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startCoachedGame(),
        icon: const Icon(Icons.play_arrow, size: 22),
        label: const Text('START COACHED GAME'),
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonTheme.neonGreen.withAlpha(30),
          foregroundColor: NeonTheme.neonGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: NeonTheme.neonGreen.withAlpha(120)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: NeonTheme.neonYellow.withAlpha(12),
        border: Border.all(
          color: NeonTheme.neonYellow.withAlpha(50),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: NeonTheme.neonYellow.withAlpha(120), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: You can also toggle the coach during any game '
              'using the mortarboard icon in the top bar.',
              style: TextStyle(
                fontSize: 11,
                color: NeonTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startCoachedGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          difficulty: _selectedDifficulty,
          mode: GameMode.pvAI,
        ),
      ),
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

  int _difficultyDepth(AIDifficulty diff) {
    switch (diff) {
      case AIDifficulty.easy:
        return 1;
      case AIDifficulty.medium:
        return 2;
      case AIDifficulty.hard:
        return 3;
      case AIDifficulty.expert:
        return 4;
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

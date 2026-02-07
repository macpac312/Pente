import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonTheme.darkBg,
      appBar: AppBar(title: const Text('HOW TO PLAY')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'OBJECTIVE',
              NeonTheme.neonCyan,
              Icons.flag,
              'Win by getting 5 stones in a row (horizontally, vertically, '
                  'or diagonally) OR by capturing 5 pairs of opponent stones.',
            ),
            _buildSection(
              'SETUP',
              NeonTheme.neonGreen,
              Icons.grid_on,
              'The game is played on a 19x19 grid. Players take turns '
                  'placing stones on empty intersections. The first player '
                  'must place their first stone on the center point.',
            ),
            _buildSection(
              'CAPTURES',
              NeonTheme.neonOrange,
              Icons.gps_fixed,
              'Capture opponent stones by flanking exactly 2 of their '
                  'adjacent stones with your own:\n\n'
                  'YOUR - OPP - OPP - YOUR\n\n'
                  'Captures work horizontally, vertically, and diagonally. '
                  'You can capture multiple pairs in a single move!\n\n'
                  'Note: Moving between two enemy stones is safe - '
                  'you cannot capture yourself.',
            ),
            _buildSection(
              'WIN CONDITIONS',
              NeonTheme.neonPink,
              Icons.emoji_events,
              '1. Five in a Row: Place 5 or more of your stones in an '
                  'unbroken line (any direction)\n\n'
                  '2. Five Captures: Capture 5 pairs (10 stones total) of '
                  'your opponent\'s stones\n\n'
                  'The first player to achieve either condition wins instantly.',
            ),
            _buildSection(
              'TOURNAMENT RULE',
              NeonTheme.neonPurple,
              Icons.rule,
              'To balance the first-player advantage, the first player\'s '
                  'second move must be at least 3 intersections away from '
                  'the center of the board. This zone is shown with a red '
                  'indicator during the move.',
            ),
            _buildSection(
              'STRATEGY TIPS',
              NeonTheme.neonYellow,
              Icons.lightbulb,
              '- Build open-ended lines (free on both ends) - they\'re '
                  'much harder to block\n\n'
                  '- Don\'t leave pairs vulnerable to capture\n\n'
                  '- Create fork threats (two winning lines at once)\n\n'
                  '- Captures can break up opponent lines\n\n'
                  '- Control the center of the board for more options\n\n'
                  '- Use the Coach mode to learn optimal plays!',
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Pente was created by Gary Gabrel in 1977',
                style: TextStyle(
                  fontSize: 11,
                  color: NeonTheme.textSecondary.withAlpha(80),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, Color color, IconData icon, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: NeonTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

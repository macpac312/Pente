import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: NeonTheme.darkBg,
      appBar: AppBar(title: const Text('SETTINGS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('THEME', NeonTheme.neonCyan),
            _buildColorPicker(
              'Accent Color',
              settings.accentColor,
              (c) => settings.setAccentColor(c),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(
              'Player 1 Color',
              settings.player1Color,
              (c) => settings.setPlayer1Color(c),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(
              'Player 2 Color',
              settings.player2Color,
              (c) => settings.setPlayer2Color(c),
            ),
            const SizedBox(height: 24),
            _sectionTitle('GAMEPLAY', NeonTheme.neonGreen),
            _buildToggle(
              'Tournament Rule',
              'First player\'s 2nd move must be 3+ away from center',
              settings.tournamentRule,
              () => settings.toggleTournamentRule(),
              NeonTheme.neonGreen,
            ),
            _buildDifficultyPicker(settings),
            const SizedBox(height: 24),
            _sectionTitle('DISPLAY', NeonTheme.neonPurple),
            _buildToggle(
              'Grid Labels',
              'Show row and column labels on the board',
              settings.showGridLabels,
              () => settings.toggleGridLabels(),
              NeonTheme.neonPurple,
            ),
            _buildToggle(
              'Highlight Last Move',
              'Show glow effect on the most recent move',
              settings.showLastMove,
              () => settings.toggleShowLastMove(),
              NeonTheme.neonPurple,
            ),
            _buildToggle(
              'Animations',
              'Enable stone placement and capture animations',
              settings.animationsEnabled,
              () => settings.toggleAnimations(),
              NeonTheme.neonPurple,
            ),
            const SizedBox(height: 24),
            _sectionTitle('AUDIO', NeonTheme.neonOrange),
            _buildToggle(
              'Sound Effects',
              'Play sounds for moves and captures',
              settings.soundEnabled,
              () => settings.toggleSound(),
              NeonTheme.neonOrange,
            ),
            _buildToggle(
              'Vibration',
              'Haptic feedback for interactions',
              settings.vibrationEnabled,
              () => settings.toggleVibration(),
              NeonTheme.neonOrange,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: NeonTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 3,
          shadows: NeonTheme.neonTextShadow(color, intensity: 0.3),
        ),
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color currentColor, void Function(Color) onSelect) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: NeonTheme.neonBox(
        color: currentColor.withOpacity(0.3),
        glowRadius: 3,
        borderRadius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: currentColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SettingsProvider.availableColors.map((color) {
              final isSelected = color.value == currentColor.value;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(isSelected ? 0.8 : 0.3),
                    border: Border.all(
                      color: isSelected ? Colors.white : color.withOpacity(0.4),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    bool value,
    VoidCallback onToggle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: NeonTheme.darkCard,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value ? color : Colors.white.withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: (_) => onToggle(),
          activeColor: color,
          activeTrackColor: color.withOpacity(0.3),
          inactiveThumbColor: Colors.white.withOpacity(0.3),
          inactiveTrackColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildDifficultyPicker(SettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NeonTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default AI Difficulty',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NeonTheme.neonGreen,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: AIDifficulty.values.map((diff) {
              final isSelected = settings.defaultDifficulty == diff;
              final color = _diffColor(diff);
              return Expanded(
                child: GestureDetector(
                  onTap: () => settings.setDefaultDifficulty(diff),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? color : color.withOpacity(0.2),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: color.withOpacity(0.3), blurRadius: 8)
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _diffName(diff),
                        style: TextStyle(
                          fontFamily: NeonTheme.fontFamily,
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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
      ),
    );
  }

  String _diffName(AIDifficulty d) {
    switch (d) {
      case AIDifficulty.easy: return 'EASY';
      case AIDifficulty.medium: return 'MED';
      case AIDifficulty.hard: return 'HARD';
      case AIDifficulty.expert: return 'PRO';
    }
  }

  Color _diffColor(AIDifficulty d) {
    switch (d) {
      case AIDifficulty.easy: return NeonTheme.neonGreen;
      case AIDifficulty.medium: return NeonTheme.neonCyan;
      case AIDifficulty.hard: return NeonTheme.neonOrange;
      case AIDifficulty.expert: return NeonTheme.neonRed;
    }
  }
}

import 'package:flutter/material.dart';
import '../main.dart' show themeModeNotifier;
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state
  bool _tournamentRule = true;
  bool _showGridLabels = true;
  bool _showLastMove = true;
  bool _animationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  AIDifficulty _difficulty = AIDifficulty.medium;

  static const List<Color> _availableColors = [
    NeonTheme.neonCyan,
    NeonTheme.neonPink,
    NeonTheme.neonGreen,
    NeonTheme.neonBlue,
    NeonTheme.neonOrange,
    NeonTheme.neonYellow,
    NeonTheme.neonPurple,
    NeonTheme.neonRed,
  ];

  Color _accentColor = NeonTheme.neonCyan;
  Color _player1Color = NeonTheme.neonCyan;
  Color _player2Color = NeonTheme.neonPink;

  // ── Helpers for theme-aware colors ──────────────────────────────────

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? NeonTheme.darkBg : NeonTheme.lightBg;
  Color get _cardColor => _isDark ? NeonTheme.cardBg : NeonTheme.lightCardBg;
  Color get _txtPrimary =>
      _isDark ? NeonTheme.textPrimary : NeonTheme.lightTextPrimary;
  Color get _txtSecondary =>
      _isDark ? NeonTheme.textSecondary : NeonTheme.lightTextSecondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(title: const Text('SETTINGS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('APPEARANCE'),
            _buildThemeModePicker(),
            const SizedBox(height: 24),
            _sectionTitle('THEME'),
            _buildColorPicker('Accent Color', _accentColor, (c) {
              setState(() => _accentColor = c);
            }),
            const SizedBox(height: 12),
            _buildColorPicker('Player 1 Color', _player1Color, (c) {
              setState(() => _player1Color = c);
            }),
            const SizedBox(height: 12),
            _buildColorPicker('Player 2 Color', _player2Color, (c) {
              setState(() => _player2Color = c);
            }),
            const SizedBox(height: 24),
            _sectionTitle('GAMEPLAY'),
            _buildToggle(
              'Tournament Rule',
              'First player\'s 2nd move must be 3+ away from center',
              _tournamentRule,
              (v) => setState(() => _tournamentRule = v),
              NeonTheme.neonGreen,
            ),
            _buildDifficultyPicker(),
            const SizedBox(height: 24),
            _sectionTitle('DISPLAY'),
            _buildToggle(
              'Grid Labels',
              'Show row and column labels on the board',
              _showGridLabels,
              (v) => setState(() => _showGridLabels = v),
              NeonTheme.neonPurple,
            ),
            _buildToggle(
              'Highlight Last Move',
              'Show glow effect on the most recent move',
              _showLastMove,
              (v) => setState(() => _showLastMove = v),
              NeonTheme.neonPurple,
            ),
            _buildToggle(
              'Animations',
              'Enable stone placement and capture animations',
              _animationsEnabled,
              (v) => setState(() => _animationsEnabled = v),
              NeonTheme.neonPurple,
            ),
            const SizedBox(height: 24),
            _sectionTitle('AUDIO'),
            _buildToggle(
              'Sound Effects',
              'Play sounds for moves and captures',
              _soundEnabled,
              (v) => setState(() => _soundEnabled = v),
              NeonTheme.neonOrange,
            ),
            _buildToggle(
              'Vibration',
              'Haptic feedback for interactions',
              _vibrationEnabled,
              (v) => setState(() => _vibrationEnabled = v),
              NeonTheme.neonOrange,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Theme mode picker ───────────────────────────────────────────────

  Widget _buildThemeModePicker() {
    final current = themeModeNotifier.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NeonTheme.neonCyan.withAlpha(40),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildThemeModeOption(
                icon: Icons.dark_mode,
                label: 'DARK',
                mode: ThemeMode.dark,
                isSelected: current == ThemeMode.dark,
                color: NeonTheme.neonCyan,
              ),
              const SizedBox(width: 8),
              _buildThemeModeOption(
                icon: Icons.light_mode,
                label: 'LIGHT',
                mode: ThemeMode.light,
                isSelected: current == ThemeMode.light,
                color: NeonTheme.neonOrange,
              ),
              const SizedBox(width: 8),
              _buildThemeModeOption(
                icon: Icons.brightness_auto,
                label: 'AUTO',
                mode: ThemeMode.system,
                isSelected: current == ThemeMode.system,
                color: NeonTheme.neonPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption({
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required bool isSelected,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            themeModeNotifier.value = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? color.withAlpha(40) : Colors.transparent,
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
              Icon(icon, color: isSelected ? color : color.withAlpha(100),
                  size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : color.withAlpha(100),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section title ───────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _txtSecondary,
          letterSpacing: 3,
        ),
      ),
    );
  }

  // ── Color picker ────────────────────────────────────────────────────

  Widget _buildColorPicker(
      String label, Color currentColor, void Function(Color) onSelect) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentColor.withAlpha(40),
          width: 1,
        ),
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
            children: _availableColors.map((color) {
              final isSelected = color.value == currentColor.value;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? color.withAlpha(200)
                        : color.withAlpha(80),
                    border: Border.all(
                      color: isSelected
                          ? (_isDark ? Colors.white : Colors.black87)
                          : color.withAlpha(100),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [NeonTheme.neonGlow(color, blur: 12, spread: 2)]
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

  // ── Toggle ──────────────────────────────────────────────────────────

  Widget _buildToggle(
    String title,
    String subtitle,
    bool value,
    void Function(bool) onChanged,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: _cardColor,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value ? color : _txtSecondary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: _txtSecondary.withAlpha(120),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          activeTrackColor: color.withAlpha(80),
          inactiveThumbColor: _txtSecondary.withAlpha(80),
          inactiveTrackColor: _txtSecondary.withAlpha(25),
        ),
      ),
    );
  }

  // ── Difficulty picker ───────────────────────────────────────────────

  Widget _buildDifficultyPicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
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
              final isSelected = _difficulty == diff;
              final color = _diffColor(diff);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = diff),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? color.withAlpha(40)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? color : color.withAlpha(40),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                      boxShadow: isSelected
                          ? [NeonTheme.neonGlow(color, blur: 8, spread: 1)]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _diffName(diff),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? color : color.withAlpha(100),
                          letterSpacing: 1,
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

  Color _diffColor(AIDifficulty d) {
    switch (d) {
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

import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import 'game_screen.dart';
import 'training_screen.dart';
import 'coach_screen.dart';
import 'settings_screen.dart';
import 'rules_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  AIDifficulty _selectedDifficulty = AIDifficulty.medium;
  TimeControl _selectedTimeControl = TimeControl.none;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // --- Difficulty config ---

  Color _difficultyColor(AIDifficulty d) {
    switch (d) {
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

  String _difficultyName(AIDifficulty d) {
    switch (d) {
      case AIDifficulty.easy:
        return 'Beginner';
      case AIDifficulty.medium:
        return 'Medium';
      case AIDifficulty.hard:
        return 'Hard';
      case AIDifficulty.expert:
        return 'Expert';
    }
  }

  int _difficultyDots(AIDifficulty d) {
    switch (d) {
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

  // --- Time control config ---

  String _timeControlLabel(TimeControl tc) {
    switch (tc) {
      case TimeControl.none:
        return 'Unlimited';
      case TimeControl.min5:
        return '5 min';
      case TimeControl.min10:
        return '10 min';
      case TimeControl.min15:
        return '15 min';
      case TimeControl.min30:
        return '30 min';
      case TimeControl.min60:
        return '60 min';
    }
  }

  IconData _timeControlIcon(TimeControl tc) {
    switch (tc) {
      case TimeControl.none:
        return Icons.all_inclusive;
      case TimeControl.min5:
        return Icons.timer;
      case TimeControl.min10:
        return Icons.timer;
      case TimeControl.min15:
        return Icons.timer;
      case TimeControl.min30:
        return Icons.hourglass_bottom;
      case TimeControl.min60:
        return Icons.hourglass_full;
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  const SizedBox(height: 48),
                  _buildDifficultySection(),
                  const SizedBox(height: 24),
                  _buildTimeControlSection(),
                  const SizedBox(height: 32),
                  _buildStartButton(),
                  const SizedBox(height: 12),
                  _buildPuzzlesButton(),
                  const SizedBox(height: 12),
                  _buildCoachButton(),
                  const SizedBox(height: 12),
                  _buildHowToPlayButton(),
                  const SizedBox(height: 8),
                  _buildSettingsButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Title with dual cyan+magenta glow ---

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final g = _glowAnimation.value;
        return Text(
          '\u25C6 NEON PENTE \u25C6',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: Colors.white,
            shadows: [
              Shadow(
                color: NeonTheme.neonCyan.withAlpha((180 * g).round()),
                blurRadius: 20,
              ),
              Shadow(
                color: NeonTheme.neonCyan.withAlpha((120 * g).round()),
                blurRadius: 40,
              ),
              Shadow(
                color: NeonTheme.neonMagenta.withAlpha((120 * g).round()),
                blurRadius: 30,
              ),
              Shadow(
                color: NeonTheme.neonMagenta.withAlpha((80 * g).round()),
                blurRadius: 60,
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Subtitle ---

  Widget _buildSubtitle() {
    return Text(
      'TRAIN  \u2022  PLAY  \u2022  IMPROVE',
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 4,
        color: NeonTheme.neonMagenta.withAlpha(180),
      ),
    );
  }

  // --- Difficulty selector ---

  Widget _buildDifficultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIFFICULTY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
            color: NeonTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...AIDifficulty.values.map(_buildDifficultyRow),
      ],
    );
  }

  Widget _buildDifficultyRow(AIDifficulty difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    final color = _difficultyColor(difficulty);
    final name = _difficultyName(difficulty);
    final dots = _difficultyDots(difficulty);

    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withAlpha(150)
                : NeonTheme.textSecondary.withAlpha(40),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [NeonTheme.neonGlow(color, blur: 12, spread: 0)]
              : [],
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : NeonTheme.textSecondary,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            // Name
            Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 1.5,
                color: isSelected ? color : NeonTheme.textPrimary,
              ),
            ),
            const Spacer(),
            // Depth dots
            Row(
              children: List.generate(4, (i) {
                final filled = i < dots;
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? color : Colors.transparent,
                    border: Border.all(
                      color: filled
                          ? color
                          : NeonTheme.textSecondary.withAlpha(60),
                      width: 1,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- Time control selector ---

  Widget _buildTimeControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer, color: NeonTheme.textSecondary, size: 14),
            const SizedBox(width: 6),
            Text(
              'TIME CONTROL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: NeonTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TimeControl.values.map(_buildTimeChip).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeChip(TimeControl tc) {
    final isSelected = _selectedTimeControl == tc;
    final color = tc == TimeControl.none
        ? NeonTheme.textSecondary
        : NeonTheme.neonYellow;

    return GestureDetector(
      onTap: () => setState(() => _selectedTimeControl = tc),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color.withAlpha(180)
                : NeonTheme.textSecondary.withAlpha(40),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [NeonTheme.neonGlow(color, blur: 8, spread: 0)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _timeControlIcon(tc),
              size: 14,
              color: isSelected ? color : NeonTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _timeControlLabel(tc),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 1,
                color: isSelected ? color : NeonTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Start Game button (green, glow animation) ---

  Widget _buildStartButton() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final g = _glowAnimation.value;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: NeonTheme.neonGreen.withAlpha(30),
              foregroundColor: NeonTheme.neonGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: NeonTheme.neonGreen
                      .withAlpha((120 + 80 * g).round()),
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              'START GAME',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: NeonTheme.neonGreen
                        .withAlpha((100 * g).round()),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Puzzles button (purple, outlined) ---

  Widget _buildPuzzlesButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrainingScreen()),
        ),
        icon: Icon(Icons.extension, color: NeonTheme.neonPurple, size: 20),
        label: Text(
          'PUZZLES',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: NeonTheme.neonPurple,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: NeonTheme.neonPurple.withAlpha(100)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // --- Coach Mode button (green, outlined) ---

  Widget _buildCoachButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CoachScreen()),
        ),
        icon: Icon(Icons.school, color: NeonTheme.neonGreen, size: 20),
        label: Text(
          'COACH MODE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: NeonTheme.neonGreen,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: NeonTheme.neonGreen.withAlpha(100)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // --- How to Play button (cyan, text) ---

  Widget _buildHowToPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RulesScreen()),
        ),
        icon: Icon(Icons.help_outline, color: NeonTheme.neonCyan, size: 20),
        label: Text(
          'HOW TO PLAY',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: NeonTheme.neonCyan,
          ),
        ),
      ),
    );
  }

  // --- Settings button (secondary, text) ---

  Widget _buildSettingsButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        icon: Icon(Icons.settings, color: NeonTheme.textSecondary, size: 20),
        label: Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: NeonTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- Navigation ---

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          difficulty: _selectedDifficulty,
          mode: GameMode.pvAI,
          timeControl: _selectedTimeControl,
        ),
      ),
    );
  }
}

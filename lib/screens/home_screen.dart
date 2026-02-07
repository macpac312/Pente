import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';
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
  late AnimationController _titleController;
  late Animation<double> _titleGlow;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _titleGlow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final accent = settings.accentColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NeonTheme.darkBg,
              NeonTheme.darkSurface,
              NeonTheme.darkBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildTitle(accent),
                  const SizedBox(height: 8),
                  _buildSubtitle(accent),
                  const SizedBox(height: 50),
                  _buildMenuButtons(context, accent),
                  const SizedBox(height: 40),
                  _buildFooter(accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(Color accent) {
    return AnimatedBuilder(
      animation: _titleGlow,
      builder: (context, child) {
        return Text(
          'PENTE',
          style: TextStyle(
            fontFamily: NeonTheme.fontFamily,
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: accent,
            letterSpacing: 12,
            shadows: [
              Shadow(
                  color: accent.withOpacity(0.8 * _titleGlow.value),
                  blurRadius: 16),
              Shadow(
                  color: accent.withOpacity(0.5 * _titleGlow.value),
                  blurRadius: 32),
              Shadow(
                  color: accent.withOpacity(0.3 * _titleGlow.value),
                  blurRadius: 64),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(Color accent) {
    return Text(
      'NEON EDITION',
      style: TextStyle(
        fontFamily: NeonTheme.fontFamily,
        fontSize: 14,
        letterSpacing: 8,
        color: accent.withOpacity(0.5),
        shadows: NeonTheme.neonTextShadow(accent, intensity: 0.2),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context, Color accent) {
    return Column(
      children: [
        NeonButton(
          text: 'VS COMPUTER',
          icon: Icons.smart_toy,
          color: NeonTheme.neonCyan,
          onPressed: () => _startGame(context, GameMode.pvAI),
        ),
        const SizedBox(height: 14),
        NeonButton(
          text: 'VS PLAYER',
          icon: Icons.people,
          color: NeonTheme.neonPink,
          onPressed: () => _startGame(context, GameMode.pvp),
        ),
        const SizedBox(height: 14),
        NeonButton(
          text: 'TRAINING',
          icon: Icons.fitness_center,
          color: NeonTheme.neonGreen,
          onPressed: () => Navigator.push(
            context,
            _neonPageRoute(const TrainingScreen()),
          ),
        ),
        const SizedBox(height: 14),
        NeonButton(
          text: 'COACH MODE',
          icon: Icons.school,
          color: NeonTheme.neonOrange,
          onPressed: () => Navigator.push(
            context,
            _neonPageRoute(const CoachScreen()),
          ),
        ),
        const SizedBox(height: 14),
        NeonButton(
          text: 'HOW TO PLAY',
          icon: Icons.help_outline,
          color: NeonTheme.neonPurple,
          onPressed: () => Navigator.push(
            context,
            _neonPageRoute(const RulesScreen()),
          ),
        ),
        const SizedBox(height: 14),
        NeonButton(
          text: 'SETTINGS',
          icon: Icons.settings,
          color: NeonTheme.neonBlue,
          onPressed: () => Navigator.push(
            context,
            _neonPageRoute(const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Color accent) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                accent.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A STRATEGY BOARD GAME',
          style: TextStyle(
            fontFamily: NeonTheme.fontFamily,
            fontSize: 9,
            letterSpacing: 4,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  void _startGame(BuildContext context, GameMode mode) {
    final settings = context.read<SettingsProvider>();
    context.read<GameProvider>().newGame(
          mode: mode,
          difficulty: settings.defaultDifficulty,
        );
    Navigator.push(
      context,
      _neonPageRoute(const GameScreen()),
    );
  }

  PageRoute _neonPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

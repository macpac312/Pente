import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  Color _accentColor = NeonTheme.neonCyan;
  Color _player1Color = NeonTheme.neonCyan;
  Color _player2Color = NeonTheme.neonPink;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _animationsEnabled = true;
  bool _showGridLabels = true;
  bool _showLastMove = true;
  bool _tournamentRule = true;
  AIDifficulty _defaultDifficulty = AIDifficulty.medium;
  double _boardScale = 1.0;

  // Getters
  Color get accentColor => _accentColor;
  Color get player1Color => _player1Color;
  Color get player2Color => _player2Color;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get animationsEnabled => _animationsEnabled;
  bool get showGridLabels => _showGridLabels;
  bool get showLastMove => _showLastMove;
  bool get tournamentRule => _tournamentRule;
  AIDifficulty get defaultDifficulty => _defaultDifficulty;
  double get boardScale => _boardScale;

  static const List<Color> availableColors = [
    NeonTheme.neonCyan,
    NeonTheme.neonPink,
    NeonTheme.neonGreen,
    NeonTheme.neonBlue,
    NeonTheme.neonOrange,
    NeonTheme.neonYellow,
    NeonTheme.neonPurple,
    NeonTheme.neonRed,
  ];

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }

  void setPlayer1Color(Color color) {
    _player1Color = color;
    notifyListeners();
  }

  void setPlayer2Color(Color color) {
    _player2Color = color;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
  }

  void toggleAnimations() {
    _animationsEnabled = !_animationsEnabled;
    notifyListeners();
  }

  void toggleGridLabels() {
    _showGridLabels = !_showGridLabels;
    notifyListeners();
  }

  void toggleShowLastMove() {
    _showLastMove = !_showLastMove;
    notifyListeners();
  }

  void toggleTournamentRule() {
    _tournamentRule = !_tournamentRule;
    notifyListeners();
  }

  void setDefaultDifficulty(AIDifficulty difficulty) {
    _defaultDifficulty = difficulty;
    notifyListeners();
  }

  void setBoardScale(double scale) {
    _boardScale = scale.clamp(0.5, 2.0);
    notifyListeners();
  }
}

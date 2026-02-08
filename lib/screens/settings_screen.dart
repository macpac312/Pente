import 'package:flutter/material.dart';
import '../main.dart' show themeModeNotifier, boardThemeNotifier, boardSizeNotifier, dragToPlaceNotifier, zoomCellsNotifier;
import '../models/board_theme.dart';
import '../models/position.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';
import '../widgets/neon_board.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Gameplay settings
  bool _tournamentRule = true;
  bool _showGridLabels = true;
  bool _showLastMove = true;
  bool _animationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  AIDifficulty _difficulty = AIDifficulty.medium;

  // The live board theme (mirrors global notifier)
  late BoardThemeData _bt;

  @override
  void initState() {
    super.initState();
    _bt = boardThemeNotifier.value;
  }

  void _updateTheme(BoardThemeData newTheme) {
    setState(() => _bt = newTheme);
    boardThemeNotifier.value = newTheme;
  }

  // ── Theme-aware helpers ────────────────────────────────────────────

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? NeonTheme.darkBg : NeonTheme.lightBg;
  Color get _cardColor => _isDark ? NeonTheme.cardBg : NeonTheme.lightCardBg;
  Color get _txtPrimary =>
      _isDark ? NeonTheme.textPrimary : NeonTheme.lightTextPrimary;
  Color get _txtSecondary =>
      _isDark ? NeonTheme.textSecondary : NeonTheme.lightTextSecondary;

  // ── Preview board data (mini 7x7 with sample stones) ──────────────

  static final _previewBoard = () {
    final b = List.generate(
        Constants.boardSize, (_) => List.filled(Constants.boardSize, StoneType.none));
    // Place some sample stones in the center region
    b[8][8] = StoneType.player1;
    b[8][10] = StoneType.player1;
    b[9][9] = StoneType.player1;
    b[10][9] = StoneType.player2;
    b[10][10] = StoneType.player2;
    b[8][11] = StoneType.player2;
    b[11][8] = StoneType.player1;
    b[7][10] = StoneType.player2;
    return b;
  }();

  // ═══════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════

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

            // ── BOARD THEME ──────────────────────────────────────
            _sectionTitle('BOARD THEME'),

            // Live preview
            _buildLivePreview(),
            const SizedBox(height: 16),

            // Stone colors
            _buildSubHeader('STONES'),
            _buildColorRow('Player 1', _bt.player1Color, (c) {
              _updateTheme(_bt.copyWith(player1Color: c, player1Glow: c));
            }),
            _buildSliderRow('Player 1 Glow', _bt.player1GlowIntensity,
                _bt.player1Color, (v) {
              _updateTheme(_bt.copyWith(player1GlowIntensity: v));
            }),
            const SizedBox(height: 8),
            _buildColorRow('Player 2', _bt.player2Color, (c) {
              _updateTheme(_bt.copyWith(player2Color: c, player2Glow: c));
            }),
            _buildSliderRow('Player 2 Glow', _bt.player2GlowIntensity,
                _bt.player2Color, (v) {
              _updateTheme(_bt.copyWith(player2GlowIntensity: v));
            }),
            const SizedBox(height: 16),

            // Board colors
            _buildSubHeader('BOARD'),
            _buildColorRow('Board Background', _bt.boardColor, (c) {
              _updateTheme(_bt.copyWith(boardColor: c));
            }, palette: _boardBgColors),
            const SizedBox(height: 8),
            _buildColorRow('Grid Lines', _bt.gridLineColor, (c) {
              _updateTheme(_bt.copyWith(gridLineColor: c));
            }, palette: _gridLineColors),
            const SizedBox(height: 8),
            _buildColorRow('Board Border', _bt.boardBorderColor, (c) {
              _updateTheme(_bt.copyWith(boardBorderColor: c));
            }),
            const SizedBox(height: 8),
            _buildColorRow('Star Points', _bt.starPointColor, (c) {
              _updateTheme(_bt.copyWith(starPointColor: c));
            }),
            const SizedBox(height: 16),

            // Interface colors
            _buildSubHeader('INTERFACE'),
            _buildColorRow('Background', _bt.backgroundColor, (c) {
              _updateTheme(_bt.copyWith(backgroundColor: c));
            }, palette: _backgroundColors),
            const SizedBox(height: 8),
            _buildColorRow('Labels', _bt.labelColor, (c) {
              _updateTheme(_bt.copyWith(labelColor: c));
            }, palette: _textColors),
            const SizedBox(height: 12),

            // Reset button
            Center(
              child: TextButton.icon(
                onPressed: _resetTheme,
                icon: Icon(Icons.refresh, color: NeonTheme.neonRed, size: 18),
                label: Text(
                  'RESET TO DEFAULTS',
                  style: TextStyle(
                    color: NeonTheme.neonRed,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('GAMEPLAY'),
            _buildToggle(
              'Tournament Rule',
              'First player\'s 2nd move must be 3+ away from center',
              _tournamentRule,
              (v) => setState(() => _tournamentRule = v),
              NeonTheme.neonGreen,
            ),
            _buildBoardSizePicker(),
            _buildZoomSettings(),
            const SizedBox(height: 8),
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

  void _resetTheme() {
    final newTheme = _isDark
        ? BoardThemeData.darkDefault()
        : BoardThemeData.lightDefault();
    _updateTheme(newTheme);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  LIVE PREVIEW
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildLivePreview() {
    return Container(
      decoration: BoxDecoration(
        color: _bt.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _bt.boardBorderColor.withAlpha(60),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _bt.labelColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: NeonBoard(
              board: _previewBoard,
              showLabels: true,
              interactive: false,
              lastMove: const Position(11, 8),
              themeOverride: _bt,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  COLOR PICKING
  // ═══════════════════════════════════════════════════════════════════

  // Preset palettes
  static const List<Color> _stoneColors = [
    NeonTheme.neonCyan,
    Color(0xFFFF80FF), // light magenta
    NeonTheme.neonGreen,
    NeonTheme.neonBlue,
    NeonTheme.neonOrange,
    NeonTheme.neonYellow,
    NeonTheme.neonPurple,
    NeonTheme.neonRed,
    NeonTheme.neonPink,
    NeonTheme.neonMagenta,
    Color(0xFF80FF80),
    Color(0xFFFFFFFF),
  ];

  static const List<Color> _boardBgColors = [
    Color(0xFF0F0F1A), // dark navy (default dark)
    Color(0xFF0A1520), // dark teal
    Color(0xFF150A1A), // dark purple
    Color(0xFF1A0A0A), // dark red
    Color(0xFF0A1A0A), // dark green
    Color(0xFF1A1510), // dark amber
    Color(0xFF000000), // pure black
    Color(0xFF1A1A25), // dark slate
    Color(0xFFDDDDE8), // light gray
    Color(0xFFD4E0D4), // light green
    Color(0xFFE8DDD4), // light amber
    Color(0xFFE8E0F0), // light purple
  ];

  static const List<Color> _gridLineColors = [
    Color(0x2300FFFF), // cyan subtle
    Color(0x30FF80FF), // magenta subtle
    Color(0x2500FF41), // green subtle
    Color(0x404466FF), // blue subtle
    Color(0x30FFFFFF), // white subtle
    Color(0x20FF6600), // orange subtle
    Color(0x30808090), // gray
    Color(0x60808090), // gray brighter
    Color(0xFFCCCCD8), // light gray
    Color(0xFFAAAAAA), // medium gray
    Color(0xFF666666), // dark gray
    Color(0x409D00FF), // purple subtle
  ];

  static const List<Color> _backgroundColors = [
    Color(0xFF0A0A0F), // default dark bg
    Color(0xFF050510), // deeper blue-black
    Color(0xFF0A0F0A), // dark green tint
    Color(0xFF0F0A0A), // dark red tint
    Color(0xFF0A0A14), // dark blue tint
    Color(0xFF000000), // pure black
    Color(0xFF101018), // soft dark
    Color(0xFF181820), // charcoal
    Color(0xFFF5F5FA), // default light bg
    Color(0xFFE8F0E8), // light green
    Color(0xFFF0E8E8), // light pink
    Color(0xFFFFFFFF), // white
  ];

  static const List<Color> _textColors = [
    Color(0xFF808090), // default secondary
    Color(0xFFE0E0E0), // light
    Color(0xFFB0B0B0), // medium
    Color(0xFF606070), // dark
    Color(0xFF00FFFF), // cyan
    Color(0xFF00FF41), // green
    Color(0xFFFF80FF), // magenta
    Color(0xFFFFFF00), // yellow
    Color(0xFF1A1A2E), // light mode dark
    Color(0xFF606078), // light mode gray
    Color(0xFF333350), // navy
    Color(0xFF404040), // neutral gray
  ];

  Widget _buildColorRow(
      String label, Color current, void Function(Color) onChange,
      {List<Color>? palette}) {
    final colors = palette ?? _stoneColors;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: current.withAlpha(40), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Current color preview swatch
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current,
                  boxShadow: [
                    BoxShadow(
                      color: current.withAlpha(80),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _txtPrimary,
                  ),
                ),
              ),
              // Custom color button (opens HSV picker)
              GestureDetector(
                onTap: () => _showHsvPicker(context, current, onChange),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _txtSecondary.withAlpha(60), width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, size: 12, color: _txtSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'CUSTOM',
                        style: TextStyle(
                          fontSize: 9,
                          color: _txtSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: colors.map((color) {
              final isSelected = _colorsMatch(color, current);
              return GestureDetector(
                onTap: () => onChange(color),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: isSelected
                          ? (_isDark ? Colors.white : Colors.black87)
                          : color.withAlpha(100),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [NeonTheme.neonGlow(color, blur: 10, spread: 2)]
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

  bool _colorsMatch(Color a, Color b) {
    return a.value == b.value ||
        (a.red == b.red && a.green == b.green && a.blue == b.blue &&
            (a.alpha - b.alpha).abs() < 10);
  }

  Widget _buildSliderRow(
      String label, double value, Color color, void Function(double) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: _txtSecondary,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withAlpha(30),
                thumbColor: color,
                overlayColor: color.withAlpha(30),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                min: 0.0,
                max: 2.0,
                onChanged: onChange,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(value * 100).round()}%',
              style: TextStyle(fontSize: 10, color: _txtSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HSV COLOR PICKER DIALOG
  // ═══════════════════════════════════════════════════════════════════

  void _showHsvPicker(
      BuildContext context, Color current, void Function(Color) onChange) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDark ? NeonTheme.cardBg : NeonTheme.lightCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _HsvPickerSheet(
          initial: current,
          isDark: _isDark,
          onColorChanged: (c) {
            onChange(c);
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════

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

  Widget _buildSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: _txtSecondary.withAlpha(40)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _txtSecondary.withAlpha(150),
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: _txtSecondary.withAlpha(40)),
          ),
        ],
      ),
    );
  }

  // ── Theme mode picker ─────────────────────────────────────────────

  Widget _buildThemeModePicker() {
    final current = themeModeNotifier.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeonTheme.neonCyan.withAlpha(40), width: 1),
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
          // Reset board theme to match new mode
          final isDarkMode = mode == ThemeMode.dark ||
              (mode == ThemeMode.system &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);
          _updateTheme(
              isDarkMode ? BoardThemeData.darkDefault() : BoardThemeData.lightDefault());
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
              Icon(icon,
                  color: isSelected ? color : color.withAlpha(100), size: 22),
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

  // ── Toggle ────────────────────────────────────────────────────────

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

  // ── Board size picker ────────────────────────────────────────────

  Widget _buildBoardSizePicker() {
    final currentSize = boardSizeNotifier.value;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Board Size',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NeonTheme.neonCyan,
                  ),
                ),
              ),
              Text(
                '$currentSize \u00D7 $currentSize',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: NeonTheme.neonCyan,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Adjust the playing field from 9\u00D79 to 19\u00D719',
            style: TextStyle(
              fontSize: 11,
              color: _txtSecondary.withAlpha(120),
            ),
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: NeonTheme.neonCyan,
              inactiveTrackColor: NeonTheme.neonCyan.withAlpha(30),
              thumbColor: NeonTheme.neonCyan,
              overlayColor: NeonTheme.neonCyan.withAlpha(30),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: currentSize.toDouble(),
              min: Constants.minBoardSize.toDouble(),
              max: Constants.boardSize.toDouble(),
              divisions: Constants.boardSize - Constants.minBoardSize,
              onChanged: (v) {
                setState(() {
                  boardSizeNotifier.value = v.round();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Constants.minBoardSize}\u00D7${Constants.minBoardSize}',
                style: TextStyle(fontSize: 10, color: _txtSecondary),
              ),
              Text(
                '${Constants.boardSize}\u00D7${Constants.boardSize}',
                style: TextStyle(fontSize: 10, color: _txtSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Touch zoom settings ──────────────────────────────────────────

  Widget _buildZoomSettings() {
    final enabled = dragToPlaceNotifier.value;
    final zoomCells = zoomCellsNotifier.value;
    final boardSize = boardSizeNotifier.value;
    final maxZoomCells = boardSize; // = no zoom
    const minZoomCells = 9; // = max zoom
    final accentColor = NeonTheme.neonOrange;

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
          // Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Touch Zoom & Crosshair',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? accentColor
                            : _txtSecondary.withAlpha(120),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Zoom in and show crosshair when placing stones',
                      style: TextStyle(
                        fontSize: 11,
                        color: _txtSecondary.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => setState(() {
                  dragToPlaceNotifier.value = v;
                }),
                activeColor: accentColor,
              ),
            ],
          ),

          // Zoom level slider (only when enabled)
          if (enabled && boardSize > minZoomCells) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Zoom Level',
                    style: TextStyle(
                      fontSize: 12,
                      color: _txtSecondary,
                    ),
                  ),
                ),
                Text(
                  zoomCells >= boardSize
                      ? 'None (crosshair only)'
                      : '$zoomCells\u00D7$zoomCells visible',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accentColor,
                inactiveTrackColor: accentColor.withAlpha(30),
                thumbColor: accentColor,
                overlayColor: accentColor.withAlpha(30),
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: zoomCells.clamp(minZoomCells, maxZoomCells).toDouble(),
                min: minZoomCells.toDouble(),
                max: maxZoomCells.toDouble(),
                divisions: maxZoomCells - minZoomCells,
                onChanged: (v) {
                  setState(() {
                    zoomCellsNotifier.value = v.round();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Max zoom',
                  style: TextStyle(fontSize: 10, color: _txtSecondary),
                ),
                Text(
                  'No zoom',
                  style: TextStyle(fontSize: 10, color: _txtSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Difficulty picker ─────────────────────────────────────────────

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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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

// ═══════════════════════════════════════════════════════════════════════
//  HSV PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════

class _HsvPickerSheet extends StatefulWidget {
  final Color initial;
  final bool isDark;
  final void Function(Color) onColorChanged;

  const _HsvPickerSheet({
    required this.initial,
    required this.isDark,
    required this.onColorChanged,
  });

  @override
  State<_HsvPickerSheet> createState() => _HsvPickerSheetState();
}

class _HsvPickerSheetState extends State<_HsvPickerSheet> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
  }

  void _update(HSVColor hsv) {
    setState(() => _hsv = hsv);
    widget.onColorChanged(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? NeonTheme.cardBg : NeonTheme.lightCardBg;
    final txtPrimary =
        widget.isDark ? NeonTheme.textPrimary : NeonTheme.lightTextPrimary;
    final txtSecondary =
        widget.isDark ? NeonTheme.textSecondary : NeonTheme.lightTextSecondary;
    final currentColor = _hsv.toColor();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: txtSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'CUSTOM COLOR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: txtPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // Color preview
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentColor,
              boxShadow: [
                BoxShadow(
                  color: currentColor.withAlpha(150),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              fontSize: 11,
              color: txtSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 20),

          // Hue slider
          _buildHsvSlider(
            label: 'HUE',
            value: _hsv.hue / 360,
            gradient: _hueGradient(),
            onChanged: (v) => _update(_hsv.withHue(v * 360)),
            txtSecondary: txtSecondary,
          ),

          // Saturation slider
          _buildHsvSlider(
            label: 'SATURATION',
            value: _hsv.saturation,
            gradient: LinearGradient(
              colors: [
                HSVColor.fromAHSV(1, _hsv.hue, 0, _hsv.value).toColor(),
                HSVColor.fromAHSV(1, _hsv.hue, 1, _hsv.value).toColor(),
              ],
            ),
            onChanged: (v) => _update(_hsv.withSaturation(v)),
            txtSecondary: txtSecondary,
          ),

          // Brightness slider
          _buildHsvSlider(
            label: 'BRIGHTNESS',
            value: _hsv.value,
            gradient: LinearGradient(
              colors: [
                HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 0).toColor(),
                HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 1).toColor(),
              ],
            ),
            onChanged: (v) => _update(_hsv.withValue(v)),
            txtSecondary: txtSecondary,
          ),

          // Alpha slider
          _buildHsvSlider(
            label: 'OPACITY',
            value: _hsv.alpha,
            gradient: LinearGradient(
              colors: [
                currentColor.withAlpha(0),
                currentColor,
              ],
            ),
            onChanged: (v) => _update(_hsv.withAlpha(v)),
            txtSecondary: txtSecondary,
          ),

          const SizedBox(height: 12),

          // Done button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('DONE'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHsvSlider({
    required String label,
    required double value,
    required Gradient gradient,
    required void Function(double) onChanged,
    required Color txtSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: txtSecondary,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: 9,
                  color: txtSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanDown: (d) {
                    final v = (d.localPosition.dx / constraints.maxWidth)
                        .clamp(0.0, 1.0);
                    onChanged(v);
                  },
                  onPanUpdate: (d) {
                    final v = (d.localPosition.dx / constraints.maxWidth)
                        .clamp(0.0, 1.0);
                    onChanged(v);
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 32),
                    painter: _GradientSliderPainter(
                      gradient: gradient,
                      thumbPosition: value,
                      thumbColor:
                          widget.isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _hueGradient() {
    return const LinearGradient(
      colors: [
        Color(0xFFFF0000), // 0
        Color(0xFFFFFF00), // 60
        Color(0xFF00FF00), // 120
        Color(0xFF00FFFF), // 180
        Color(0xFF0000FF), // 240
        Color(0xFFFF00FF), // 300
        Color(0xFFFF0000), // 360
      ],
    );
  }
}

// ── Gradient slider painter ──────────────────────────────────────────

class _GradientSliderPainter extends CustomPainter {
  final Gradient gradient;
  final double thumbPosition;
  final Color thumbColor;

  _GradientSliderPainter({
    required this.gradient,
    required this.thumbPosition,
    required this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (size.height - 14) / 2, size.width, 14),
      const Radius.circular(7),
    );

    // Draw gradient track
    final paint = Paint()
      ..shader = gradient.createShader(trackRect.outerRect);
    canvas.drawRRect(trackRect, paint);

    // Draw track border
    final borderPaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(trackRect, borderPaint);

    // Draw thumb
    final thumbX = thumbPosition * size.width;
    final thumbCenter = Offset(thumbX, size.height / 2);

    // Shadow
    canvas.drawCircle(
      thumbCenter,
      9,
      Paint()..color = Colors.black.withAlpha(80),
    );
    // White ring
    canvas.drawCircle(
      thumbCenter,
      8,
      Paint()..color = thumbColor,
    );
    // Inner circle showing actual value
    canvas.drawCircle(
      thumbCenter,
      5.5,
      Paint()..color = thumbColor == Colors.white
          ? Colors.grey.shade600
          : Colors.white70,
    );
  }

  @override
  bool shouldRepaint(_GradientSliderPainter old) =>
      thumbPosition != old.thumbPosition ||
      gradient != old.gradient;
}

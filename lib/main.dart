import 'package:flutter/material.dart';
import 'models/board_theme.dart';
import 'theme/neon_theme.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';

/// Global theme mode notifier – accessible from settings screen.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.dark);

/// Global board theme notifier – customizable colors for board & stones.
final ValueNotifier<BoardThemeData> boardThemeNotifier =
    ValueNotifier(BoardThemeData.darkDefault());

/// Global board size notifier – adjustable from 9×9 to 19×19.
final ValueNotifier<int> boardSizeNotifier = ValueNotifier(Constants.boardSize);

/// Whether the touch-zoom crosshair is enabled (for mobile stone placement).
final ValueNotifier<bool> dragToPlaceNotifier = ValueNotifier(true);

/// Zoom level for the touch-zoom crosshair (9 = max zoom, boardSize = no zoom).
/// Represents how many cells are visible when zoomed in.
final ValueNotifier<int> zoomCellsNotifier = ValueNotifier(9);

void main() {
  runApp(const NeonPenteApp());
}

class NeonPenteApp extends StatelessWidget {
  const NeonPenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<BoardThemeData>(
          valueListenable: boardThemeNotifier,
          builder: (context, boardTheme, _) {
            return MaterialApp(
              title: 'Neon Pente',
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              theme: NeonTheme.lightThemeData,
              darkTheme: NeonTheme.themeData,
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}

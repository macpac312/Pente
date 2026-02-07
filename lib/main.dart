import 'package:flutter/material.dart';
import 'models/board_theme.dart';
import 'theme/neon_theme.dart';
import 'screens/home_screen.dart';

/// Global theme mode notifier – accessible from settings screen.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.dark);

/// Global board theme notifier – customizable colors for board & stones.
final ValueNotifier<BoardThemeData> boardThemeNotifier =
    ValueNotifier(BoardThemeData.darkDefault());

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

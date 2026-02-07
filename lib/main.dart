import 'package:flutter/material.dart';
import 'theme/neon_theme.dart';
import 'screens/home_screen.dart';

/// Global theme mode notifier – accessible from settings screen.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.dark);

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
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/neon_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

class NeonPenteApp extends StatelessWidget {
  const NeonPenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Neon Pente',
          debugShowCheckedModeBanner: false,
          theme: NeonTheme.darkTheme(settings.accentColor),
          home: const HomeScreen(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'theme/neon_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NeonPenteApp());
}

class NeonPenteApp extends StatelessWidget {
  const NeonPenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Pente',
      debugShowCheckedModeBanner: false,
      theme: NeonTheme.themeData,
      home: const HomeScreen(),
    );
  }
}

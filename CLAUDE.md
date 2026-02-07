# CLAUDE.md

## Project Overview

**Neon Pente** - A Flutter-based Pente board game with neon visual styling, AI opponent, coach mode, and training puzzles.

Pente is a strategy board game played on a 19x19 grid. Win by getting 5 stones in a row or capturing 5 opponent pairs.

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider (ChangeNotifier pattern)
- **Minimum SDK:** Dart 3.0+
- **Key packages:** provider, audioplayers, flutter_animate, google_fonts, shared_preferences

## Project Structure

```
lib/
├── main.dart                  # Entry point, provider setup
├── app.dart                   # MaterialApp with theme
├── theme/
│   └── neon_theme.dart        # Neon colors, glows, shadows, gradients
├── models/
│   ├── position.dart          # Board coordinate model
│   ├── game_state.dart        # Immutable game state (copyWith pattern)
│   ├── move_record.dart       # Move history record with notation
│   └── training_puzzle.dart   # Puzzle definition model
├── engine/
│   ├── pente_engine.dart      # Game rules, validation, captures, win detection, coach analysis
│   ├── ai_player.dart         # AI with 4 difficulty levels (minimax + alpha-beta)
│   └── training_data.dart     # 17 training puzzles across 4 categories
├── providers/
│   ├── game_provider.dart     # Game state management, AI integration, undo, coach
│   └── settings_provider.dart # Theme, audio, display, gameplay settings
├── screens/
│   ├── home_screen.dart       # Main menu with animated neon title
│   ├── game_screen.dart       # Game board with info panel, coach, history
│   ├── training_screen.dart   # Puzzle browser + interactive puzzle solver
│   ├── coach_screen.dart      # Coach feature explanation + coached game launcher
│   ├── settings_screen.dart   # Color pickers, toggles, difficulty selector
│   └── rules_screen.dart      # How-to-play guide with all Pente rules
├── widgets/
│   ├── neon_board.dart        # 19x19 board with CustomPainter, zoom, star points
│   ├── neon_stone.dart        # Animated glowing stones with radial gradients
│   ├── neon_button.dart       # Pulsing neon buttons with glow animations
│   ├── game_info_panel.dart   # Player info, captures display, game status
│   ├── coach_panel.dart       # Real-time hint list with highlight interaction
│   └── move_history.dart      # Horizontal scrolling move notation
└── utils/
    ├── constants.dart         # Board size, rules, enums (StoneType, GameMode, etc.)
    └── sound_manager.dart     # Audio player singleton

test/
└── pente_engine_test.dart     # Engine tests: validation, captures, wins, coach

web/
├── index.html                 # Neon-styled loading screen
└── manifest.json              # PWA manifest
```

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter run -d chrome        # Run as web app
flutter test                 # Run all tests
flutter test test/pente_engine_test.dart  # Run engine tests only
flutter build apk            # Build Android APK
flutter build web            # Build web app
flutter analyze              # Run static analysis
```

## Game Rules (Pente)

- **Board:** 19x19 grid, stones placed on intersections
- **First move:** Must be at center (J10)
- **Tournament rule:** Player 1's 2nd move must be 3+ intersections from center
- **Captures:** Flank exactly 2 adjacent opponent stones (YOUR-OPP-OPP-YOUR) to capture them
- **Win conditions:** 5+ in a row (any direction) OR capture 5 pairs (10 stones)
- **Self-capture:** Moving between two enemy stones is safe (no self-capture)

## Architecture Patterns

- **Immutable state:** GameState uses `copyWith()` for all mutations
- **Engine is stateless:** All PenteEngine methods are static, take state as input
- **Provider pattern:** GameProvider wraps engine logic + AI, SettingsProvider for preferences
- **Coach integration:** PenteEngine.analyzePosition() returns prioritized CoachHints
- **AI:** 4 difficulty levels with minimax + alpha-beta pruning, move prioritization

## Neon Theme System

All neon styling is in `neon_theme.dart`:
- `NeonTheme.neonBox()` - glowing container with double box-shadow
- `NeonTheme.neonTextShadow()` - triple-layer text glow
- `NeonTheme.neonGradient()` - diagonal gradients
- Color palette: neonCyan, neonPink, neonGreen, neonBlue, neonOrange, neonYellow, neonPurple, neonRed
- Dark backgrounds: darkBg (#0A0A1A), darkSurface (#12122A), darkCard (#1A1A3E)
- Font: Orbitron (futuristic monospace)
- Dynamic accent color via SettingsProvider

## Key Design Decisions

- Board uses `CustomPainter` for grid rendering (performance) with `InteractiveViewer` for pinch-to-zoom
- Stones use `RadialGradient` + multi-layer `BoxShadow` for neon glow effect
- AI runs asynchronously via `Future` to avoid blocking UI
- Training puzzles are static data (no network required)
- Move notation uses chess-style: column letter (A-S) + row number (19-1)

## Development Guidelines

- Keep game engine (`pente_engine.dart`) free of Flutter/UI dependencies
- All board mutations go through PenteEngine.makeMove() to ensure rule enforcement
- Test engine logic independently from UI
- Use `NeonTheme` helpers for consistent styling - never hardcode neon colors in widgets
- Prefer `const` constructors for stateless widgets

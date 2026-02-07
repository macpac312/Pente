# CLAUDE.md

## Project Overview

**Neon Pente** - A Flutter-based Pente board game with neon visual styling (matching Neon Chess), AI opponent, coach mode, and training puzzles.

Pente is a strategy board game played on a 19x19 grid. Win by getting 5 stones in a row or capturing 5 opponent pairs.

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Local StatefulWidget state (no external packages)
- **Minimum SDK:** Dart 3.0+
- **External packages:** None (Flutter SDK only)

## Project Structure

```
lib/
├── main.dart                  # Entry point, MaterialApp with NeonTheme
├── theme/
│   └── neon_theme.dart        # Neon colors, glows, ThemeData (matches Neon Chess)
├── models/
│   ├── position.dart          # Board coordinate model with Chebyshev distance
│   ├── game_state.dart        # Immutable game state (copyWith pattern)
│   ├── move_record.dart       # Move history record with chess-style notation
│   └── training_puzzle.dart   # Puzzle definition model
├── engine/
│   ├── pente_engine.dart      # Game rules, validation, captures, win detection, coach analysis
│   ├── ai_player.dart         # AI with 4 difficulty levels (minimax + alpha-beta)
│   └── training_data.dart     # 17 training puzzles across 4 categories
├── screens/
│   ├── home_screen.dart       # Main menu with animated glow title, difficulty selector
│   ├── game_screen.dart       # Game board with responsive layout, eval bar, coach, move history
│   ├── training_screen.dart   # Puzzle browser + interactive puzzle solver
│   ├── coach_screen.dart      # Coach feature explanation + coached game launcher
│   ├── settings_screen.dart   # Color pickers, toggles, difficulty selector
│   └── rules_screen.dart      # How-to-play guide with all Pente rules
├── widgets/
│   ├── neon_board.dart        # 19x19 board with alternating cells, star points, labels
│   ├── neon_stone.dart        # Glowing stones with RadialGradient + BoxShadow
│   ├── neon_button.dart       # Neon-styled ElevatedButton wrapper
│   ├── eval_bar_widget.dart   # Position evaluation bar (vertical/horizontal)
│   ├── game_info_panel.dart   # CaptureDisplay widget with dot indicators
│   ├── coach_panel.dart       # CoachPanelWidget with Tip/Hint/Learn buttons
│   └── move_history.dart      # MoveHistoryWidget with paired move display
└── utils/
    ├── constants.dart         # Board size, rules, enums (StoneType, GameMode, etc.)
    └── sound_manager.dart     # Audio stub (no-op singleton)

test/
└── pente_engine_test.dart     # Engine tests: validation, captures, wins, coach
```

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter run -d linux         # Run on Linux desktop
flutter run -d chrome        # Run as web app
flutter test                 # Run all tests
flutter test test/pente_engine_test.dart  # Run engine tests only
flutter build apk            # Build Android APK
flutter build web            # Build web app
flutter build linux          # Build Linux desktop app
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

- **Local state management:** All screens use StatefulWidget with local state (no Provider/Bloc)
- **Immutable state:** GameState uses `copyWith()` for all mutations
- **Engine is stateless:** All PenteEngine methods are static, take state as input
- **Responsive layout:** Wide (>900px) shows side panel; narrow uses bottom tabs
- **Coach integration:** PenteEngine.analyzePosition() returns prioritized CoachHints
- **AI:** 4 difficulty levels with minimax + alpha-beta pruning, async via Future
- **Pente Academy:** Modal bottom sheet with expandable learning topics

## Neon Theme System

All neon styling is in `neon_theme.dart` (matches Neon Chess exactly):
- `NeonTheme.neonGlow(color)` - single BoxShadow with configurable blur/spread
- `NeonTheme.neonGlowMultiple(color)` - triple-layer glow (4px, 12px, 24px blur)
- `NeonTheme.themeData` - full ThemeData with styled buttons, cards, dialogs, snackbars
- Color palette: neonCyan, neonMagenta, neonGreen, neonBlue, neonOrange, neonYellow, neonPurple, neonRed, neonPink
- Dark backgrounds: darkBg (#0A0A0F), darkerBg (#050508), cardBg (#12121A), surfaceBg (#1A1A25)
- Player colors: player1 = neonCyan, player2 = FF80FF (with neonMagenta glow)
- System fonts with letterSpacing (no custom fonts)
- Uses `withAlpha()` instead of `withOpacity()`

## Key Design Decisions

- Board uses Column/Row of Container cells (not CustomPainter) for simplicity
- Stones use `RadialGradient` + multi-layer `BoxShadow` for neon glow effect
- AI runs asynchronously via `Future` to avoid blocking UI
- Training puzzles are static data (no network required)
- Move notation uses chess-style: column letter (A-S) + row number (19-1)
- Game screen has tabbed bottom panels (MOVES/COACH) in narrow mode
- Eval bar: vertical in wide layout, horizontal in narrow layout

## Development Guidelines

- Keep game engine (`pente_engine.dart`) free of Flutter/UI dependencies
- All board mutations go through PenteEngine.makeMove() to ensure rule enforcement
- Test engine logic independently from UI
- Use `NeonTheme` helpers for consistent styling - never hardcode neon colors in widgets
- Use `withAlpha()` not `withOpacity()` for color transparency
- Prefer `const` constructors for stateless widgets
- No external state management packages - use local StatefulWidget state

class Constants {
  static const int boardSize = 19;
  static const int boardCenter = 9; // 0-indexed center of 19x19
  static const int capturesNeededToWin = 5; // 5 pairs = 10 stones
  static const int stonesInRowToWin = 5;
  static const int tournamentRuleDistance = 3;

  // AI difficulty levels
  static const int aiEasy = 1;
  static const int aiMedium = 2;
  static const int aiHard = 3;
  static const int aiExpert = 4;

  // Directions for line checks: (dr, dc) pairs
  static const List<List<int>> directions = [
    [0, 1],   // horizontal
    [1, 0],   // vertical
    [1, 1],   // diagonal down-right
    [1, -1],  // diagonal down-left
  ];

  // Training puzzle categories
  static const String puzzleCapture = 'capture';
  static const String puzzleDefend = 'defend';
  static const String puzzleWin = 'win';
  static const String puzzleThreat = 'threat';

  // LAN networking
  static const int lanUdpPort = 41234;
  static const int lanTcpPort = 41235;
  static const int lanBeaconIntervalMs = 2000;
  static const int lanHeartbeatIntervalMs = 5000;
  static const int lanHeartbeatTimeoutMs = 10000;
  static const String lanProtocolVersion = '1';
}

enum StoneType { none, player1, player2 }

enum GameMode { pvp, pvAI, training, lan }

enum GamePhase { playing, paused, finished }

enum AIDifficulty { easy, medium, hard, expert }

enum TimeControl {
  none,      // unlimited
  min5,      // 5 minutes
  min10,     // 10 minutes
  min15,     // 15 minutes
  min30,     // 30 minutes
  min60,     // 60 minutes
}

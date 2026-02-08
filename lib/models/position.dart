class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position operator +(Position other) => Position(row + other.row, col + other.col);
  Position operator *(int scalar) => Position(row * scalar, col * scalar);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row * 31 + col;

  @override
  String toString() => '($row, $col)';

  /// Check bounds against the maximum board size (19×19).
  bool get isValid => row >= 0 && row < 19 && col >= 0 && col < 19;

  /// Check bounds against an arbitrary board size.
  bool isValidFor(int boardSize) =>
      row >= 0 && row < boardSize && col >= 0 && col < boardSize;

  int distanceTo(Position other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
    return dr > dc ? dr : dc; // Chebyshev distance
  }
}

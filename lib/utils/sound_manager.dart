/// Manages sound effects for the game.
/// Stub implementation - add audioplayers package to enable sounds.
class SoundManager {
  static final SoundManager _instance = SoundManager._();
  factory SoundManager() => _instance;
  SoundManager._();

  bool _enabled = true;

  set enabled(bool value) => _enabled = value;

  Future<void> playPlaceStone() async {}
  Future<void> playCapture() async {}
  Future<void> playWin() async {}
  Future<void> playLose() async {}
  Future<void> playClick() async {}
  void dispose() {}
}

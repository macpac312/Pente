import 'package:audioplayers/audioplayers.dart';

/// Manages sound effects for the game.
/// Sound files should be placed in assets/sounds/.
class SoundManager {
  static final SoundManager _instance = SoundManager._();
  factory SoundManager() => _instance;
  SoundManager._();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  set enabled(bool value) => _enabled = value;

  Future<void> playPlaceStone() async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('sounds/place.mp3'));
    } catch (_) {}
  }

  Future<void> playCapture() async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('sounds/capture.mp3'));
    } catch (_) {}
  }

  Future<void> playWin() async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('sounds/win.mp3'));
    } catch (_) {}
  }

  Future<void> playLose() async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('sounds/lose.mp3'));
    } catch (_) {}
  }

  Future<void> playClick() async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('sounds/click.mp3'));
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}

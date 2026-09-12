import '../models/audio_player_state.dart';

/// Abstract contract for local, offline audio playback in Fluentia.
/// Decouples the presentation layer from any third-party audio package.
abstract class AudioPlayerService {
  /// Initializes background audio session and dependencies.
  Future<void> initialize();

  /// Loads a bundled offline asset file (e.g. `assets/audio/listening/a1/...wav`).
  Future<void> loadAsset(String assetPath);

  /// Starts playback of the loaded asset.
  Future<void> play();

  /// Pauses current playback.
  Future<void> pause();

  /// Resumes playback from the current position.
  Future<void> resume();

  /// Seeks to the start (0:00) and resumes playback.
  Future<void> replay();

  /// Seeks to a specific [position] within the current track.
  Future<void> seek(Duration position);

  /// Sets the playback rate/speed (e.g. 0.75, 1.0, 1.25, 1.5).
  Future<void> setSpeed(double speed);

  /// Halts playback and resets playhead.
  Future<void> stop();

  /// Disposes underlying audio resources.
  void dispose();

  /// Returns current synchronous snapshot of player state.
  AudioPlayerSnapshot get snapshot;

  /// Stream of player state updates for UI reactivity.
  Stream<AudioPlayerSnapshot> get stateStream;
}

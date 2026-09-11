/// Contract for local text-to-speech audio pronunciation.
abstract class TtsService {
  /// Initializes the TTS engine.
  Future<bool> initialize();

  /// Speaks the given [text] in English.
  Future<void> speak(String text);

  /// Stops any currently playing speech.
  Future<void> stop();

  /// Whether speech is actively playing.
  bool get isPlaying;

  /// Stream of playback state changes (true = playing, false = stopped).
  Stream<bool> get isPlayingStream;

  /// Disposes resources.
  void dispose();
}

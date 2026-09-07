/// Abstraction for audio playback, speech-to-text, and speech synthesis.
/// Ensures future speaking and listening features are decoupled from concrete audio packages.
abstract class AudioServiceInterface {
  /// Plays an audio asset or local file at [pathOrAsset].
  Future<void> playAudio(String pathOrAsset);

  /// Pauses currently playing audio.
  Future<void> pauseAudio();

  /// Stops currently playing audio.
  Future<void> stopAudio();

  /// Speaks text using offline Text-To-Speech (TTS).
  Future<void> speakText(
    String text, {
    String language = 'en-US',
    double speechRate = 1.0,
    double pitch = 1.0,
  });

  /// Starts recording microphone input for pronunciation assessment.
  Future<void> startRecording();

  /// Stops recording and returns the path to the recorded audio file.
  Future<String?> stopRecording();

  /// Releases audio resources.
  Future<void> dispose();
}

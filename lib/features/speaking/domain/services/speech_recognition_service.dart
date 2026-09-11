import '../models/speech_recognition_state.dart';

/// Contract abstracting device platform speech recognition engines.
abstract class SpeechRecognitionService {
  /// Current state of the recognition engine.
  SpeechRecordingState get state;

  /// Stream of state changes.
  Stream<SpeechRecordingState> get stateStream;

  /// Current accumulated transcript text.
  String get currentTranscript;

  /// Stream of recognized transcript text updates.
  Stream<String> get transcriptStream;

  /// Normalized audio input sound level (0.0 to 1.0) for visual feedback.
  double get soundLevel;

  /// Stream of audio input sound levels.
  Stream<double> get soundLevelStream;

  /// Initializes the speech recognition engine. Returns true if operational.
  Future<bool> initialize();

  /// Checks if speech recognition is available on the current device/platform.
  Future<bool> isAvailable();

  /// Checks current microphone permission status without prompting.
  Future<MicrophonePermissionStatus> checkPermission();

  /// Requests microphone permission from the operating system.
  Future<MicrophonePermissionStatus> requestPermission();

  /// Begins listening to the microphone and streaming recognition results.
  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    void Function(double soundLevel)? onSoundLevelChange,
    Duration? listenFor,
    Duration? pauseFor,
    String localeId = 'en_US',
  });

  /// Gracefully stops listening and finalizes the recognized speech.
  Future<void> stopListening();

  /// Cancels listening immediately and clears temporary buffers.
  Future<void> cancelListening();

  /// Cleans up streams and releases native resources.
  void dispose();
}

/// Recording lifecycle states for the Speaking Lab.
enum SpeechRecordingState {
  idle('Ready', 'Tap the microphone to speak.'),
  preparing('Preparing', 'Get ready to speak.'),
  listening('Listening...', 'Speak clearly into your microphone.'),
  processing('Analyzing...', 'Processing your speech response.'),
  completed('Completed', 'Speaking practice completed.'),
  error('Error', 'An error occurred during speech recognition.'),
  permissionDenied(
    'Microphone Denied',
    'Microphone access is required to recognize speech.',
  ),
  unavailable(
    'Unavailable',
    'Speech recognition is not supported on this platform.',
  );

  const SpeechRecordingState(this.label, this.description);

  final String label;
  final String description;

  bool get isIdle => this == SpeechRecordingState.idle;
  bool get isPreparing => this == SpeechRecordingState.preparing;
  bool get isListening => this == SpeechRecordingState.listening;
  bool get isProcessing => this == SpeechRecordingState.processing;
  bool get isCompleted => this == SpeechRecordingState.completed;
  bool get isError => this == SpeechRecordingState.error;
  bool get isPermissionDenied => this == SpeechRecordingState.permissionDenied;
  bool get isUnavailable => this == SpeechRecordingState.unavailable;
}

/// Microphone permission evaluation statuses.
enum MicrophonePermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  undetermined,
  unavailable;

  bool get isGranted => this == MicrophonePermissionStatus.granted;
  bool get isDenied => this == MicrophonePermissionStatus.denied;
  bool get isPermanentlyDenied =>
      this == MicrophonePermissionStatus.permanentlyDenied;
}

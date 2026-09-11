import 'dart:async';
import '../../domain/models/speech_recognition_state.dart';
import '../../domain/services/speech_recognition_service.dart';

/// Mock speech recognition service for deterministic unit and widget testing.
class MockSpeechRecognitionService implements SpeechRecognitionService {
  MockSpeechRecognitionService({
    bool initialAvailable = true,
    MicrophonePermissionStatus initialPermission =
        MicrophonePermissionStatus.granted,
    String mockTranscript = '',
  }) : _isAvailable = initialAvailable,
       _permission = initialPermission,
       _currentTranscript = mockTranscript;

  bool _isAvailable;
  MicrophonePermissionStatus _permission;
  SpeechRecordingState _state = SpeechRecordingState.idle;
  String _currentTranscript;
  double _soundLevel = 0.0;
  void Function(String words, bool isFinal)? _activeResultCallback;

  final StreamController<SpeechRecordingState> _stateController =
      StreamController<SpeechRecordingState>.broadcast();
  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();
  final StreamController<double> _soundLevelController =
      StreamController<double>.broadcast();

  void setAvailability(bool available) {
    _isAvailable = available;
    if (!available) {
      setState(SpeechRecordingState.unavailable);
    }
  }

  void setPermission(MicrophonePermissionStatus status) {
    _permission = status;
    if (status != MicrophonePermissionStatus.granted) {
      setState(SpeechRecordingState.permissionDenied);
    }
  }

  void setState(SpeechRecordingState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void emitTranscript(String words) {
    _currentTranscript = words;
    _activeResultCallback?.call(words, true);
    if (!_transcriptController.isClosed) {
      _transcriptController.add(words);
    }
  }

  void emitSoundLevel(double level) {
    _soundLevel = level;
    if (!_soundLevelController.isClosed) {
      _soundLevelController.add(level);
    }
  }

  @override
  SpeechRecordingState get state => _state;

  @override
  Stream<SpeechRecordingState> get stateStream => _stateController.stream;

  @override
  String get currentTranscript => _currentTranscript;

  @override
  Stream<String> get transcriptStream => _transcriptController.stream;

  @override
  double get soundLevel => _soundLevel;

  @override
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  @override
  Future<bool> initialize() async {
    if (!_isAvailable) {
      setState(SpeechRecordingState.unavailable);
      return false;
    }
    setState(SpeechRecordingState.idle);
    return true;
  }

  @override
  Future<bool> isAvailable() async => _isAvailable;

  @override
  Future<MicrophonePermissionStatus> checkPermission() async => _permission;

  @override
  Future<MicrophonePermissionStatus> requestPermission() async {
    if (_permission == MicrophonePermissionStatus.granted) {
      return MicrophonePermissionStatus.granted;
    }
    setState(SpeechRecordingState.permissionDenied);
    return _permission;
  }

  @override
  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    void Function(double soundLevel)? onSoundLevelChange,
    Duration? listenFor,
    Duration? pauseFor,
    String localeId = 'en_US',
  }) async {
    if (!_isAvailable) {
      setState(SpeechRecordingState.unavailable);
      return;
    }
    if (_permission != MicrophonePermissionStatus.granted) {
      setState(SpeechRecordingState.permissionDenied);
      return;
    }

    _activeResultCallback = onResult;
    setState(SpeechRecordingState.listening);
    if (_currentTranscript.isNotEmpty) {
      onResult(_currentTranscript, true);
    }
  }

  @override
  Future<void> stopListening() async {
    setState(SpeechRecordingState.processing);
    await Future.delayed(const Duration(milliseconds: 10));
    setState(SpeechRecordingState.completed);
  }

  @override
  Future<void> cancelListening() async {
    _activeResultCallback = null;
    setState(SpeechRecordingState.idle);
  }

  @override
  void dispose() {
    _stateController.close();
    _transcriptController.close();
    _soundLevelController.close();
  }
}

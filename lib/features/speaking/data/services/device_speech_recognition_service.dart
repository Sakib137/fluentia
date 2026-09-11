import 'dart:async';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/models/speech_recognition_state.dart';
import '../../domain/services/speech_recognition_service.dart';

/// Device platform implementation of [SpeechRecognitionService] powered by `speech_to_text`.
class DeviceSpeechRecognitionService implements SpeechRecognitionService {
  DeviceSpeechRecognitionService({SpeechToText? speechToText})
    : _speech = speechToText ?? SpeechToText();

  final SpeechToText _speech;

  SpeechRecordingState _state = SpeechRecordingState.idle;
  String _currentTranscript = '';
  double _soundLevel = 0.0;
  bool _isInitialized = false;

  final StreamController<SpeechRecordingState> _stateController =
      StreamController<SpeechRecordingState>.broadcast();
  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();
  final StreamController<double> _soundLevelController =
      StreamController<double>.broadcast();

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

  void _setState(SpeechRecordingState newState) {
    if (_state != newState) {
      _state = newState;
      if (!_stateController.isClosed) {
        _stateController.add(newState);
      }
    }
  }

  void _setTranscript(String text) {
    _currentTranscript = text;
    if (!_transcriptController.isClosed) {
      _transcriptController.add(text);
    }
  }

  void _setSoundLevel(double level) {
    // Normalize level to roughly 0.0 - 1.0
    final normalized = ((level + 10.0) / 20.0).clamp(0.0, 1.0);
    _soundLevel = normalized;
    if (!_soundLevelController.isClosed) {
      _soundLevelController.add(normalized);
    }
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final available = await _speech.initialize(
        onError: _handleSpeechError,
        onStatus: _handleSpeechStatus,
        debugLogging: false,
      );

      _isInitialized = available;
      if (!available) {
        _setState(SpeechRecordingState.unavailable);
      } else {
        _setState(SpeechRecordingState.idle);
      }
      return available;
    } catch (_) {
      _isInitialized = false;
      _setState(SpeechRecordingState.unavailable);
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      if (!_isInitialized) {
        return await initialize();
      }
      return _speech.isAvailable;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<MicrophonePermissionStatus> checkPermission() async {
    try {
      final hasPermission = await _speech.hasPermission;
      if (hasPermission) return MicrophonePermissionStatus.granted;
      return MicrophonePermissionStatus.undetermined;
    } catch (_) {
      return MicrophonePermissionStatus.unavailable;
    }
  }

  @override
  Future<MicrophonePermissionStatus> requestPermission() async {
    try {
      final available = await initialize();
      if (available) {
        return MicrophonePermissionStatus.granted;
      }
      final hasPerm = await _speech.hasPermission;
      if (hasPerm) {
        return MicrophonePermissionStatus.granted;
      }
      _setState(SpeechRecordingState.permissionDenied);
      return MicrophonePermissionStatus.denied;
    } catch (_) {
      _setState(SpeechRecordingState.unavailable);
      return MicrophonePermissionStatus.unavailable;
    }
  }

  @override
  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    void Function(double soundLevel)? onSoundLevelChange,
    Duration? listenFor,
    Duration? pauseFor,
    String localeId = 'en_US',
  }) async {
    final available = await isAvailable();
    if (!available) {
      _setState(SpeechRecordingState.unavailable);
      return;
    }

    _setTranscript('');
    _setState(SpeechRecordingState.listening);

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          final words = result.recognizedWords;
          _setTranscript(words);
          onResult(words, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true,
          listenFor: listenFor ?? const Duration(seconds: 90),
          pauseFor: pauseFor ?? const Duration(seconds: 4),
          localeId: localeId,
        ),
        onSoundLevelChange: (level) {
          _setSoundLevel(level);
          onSoundLevelChange?.call(_soundLevel);
        },
      );
    } catch (e) {
      _setState(SpeechRecordingState.error);
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      _setState(SpeechRecordingState.processing);
      await _speech.stop();
      _setSoundLevel(0.0);
    } catch (_) {
      _setState(SpeechRecordingState.completed);
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
      _setSoundLevel(0.0);
      _setState(SpeechRecordingState.idle);
    } catch (_) {
      _setState(SpeechRecordingState.idle);
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (error.errorMsg == 'error_speech_timeout' ||
        error.errorMsg == 'error_no_match') {
      // Graceful completion when silence occurs
      _setState(SpeechRecordingState.completed);
      return;
    }

    if (error.errorMsg.contains('permission')) {
      _setState(SpeechRecordingState.permissionDenied);
    } else {
      _setState(SpeechRecordingState.error);
    }
  }

  void _handleSpeechStatus(String status) {
    switch (status) {
      case 'listening':
        _setState(SpeechRecordingState.listening);
        break;
      case 'notListening':
      case 'done':
        if (_state == SpeechRecordingState.listening) {
          _setState(SpeechRecordingState.processing);
        }
        break;
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _stateController.close();
    _transcriptController.close();
    _soundLevelController.close();
  }
}

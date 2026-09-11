import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/services/tts_service.dart';

/// Device platform text-to-speech service powered by `flutter_tts`.
class DeviceTtsService implements TtsService {
  DeviceTtsService({FlutterTts? tts}) : _flutterTts = tts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isPlaying = false;
  bool _isInitialized = false;

  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<bool> get isPlayingStream => _playingController.stream;

  void _setPlaying(bool playing) {
    if (_isPlaying != playing) {
      _isPlaying = playing;
      if (!_playingController.isClosed) {
        _playingController.add(playing);
      }
    }
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(
        0.45,
      ); // Slightly slower for language learners
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() => _setPlaying(true));
      _flutterTts.setCompletionHandler(() => _setPlaying(false));
      _flutterTts.setCancelHandler(() => _setPlaying(false));
      _flutterTts.setErrorHandler((_) => _setPlaying(false));

      _isInitialized = true;
      return true;
    } catch (_) {
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      if (_isPlaying) {
        await stop();
      }
      await _flutterTts.speak(text);
    } catch (_) {
      _setPlaying(false);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _setPlaying(false);
    } catch (_) {
      _setPlaying(false);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _playingController.close();
  }
}

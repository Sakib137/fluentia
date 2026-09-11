import 'dart:async';
import '../../domain/services/tts_service.dart';

/// Mock TTS service for testing.
class MockTtsService implements TtsService {
  bool _isPlaying = false;
  String? lastSpokenText;
  int speakCallCount = 0;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<bool> get isPlayingStream => _controller.stream;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> speak(String text) async {
    _isPlaying = true;
    lastSpokenText = text;
    speakCallCount++;
    _controller.add(true);
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _controller.add(false);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

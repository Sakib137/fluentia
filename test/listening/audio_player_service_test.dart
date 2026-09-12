import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/listening/domain/models/audio_player_state.dart';
import 'package:fluentia/features/listening/domain/services/audio_player_service.dart';

/// Predictable test double for [AudioPlayerService] to test state transitions.
class FakeAudioPlayerService implements AudioPlayerService {
  final _controller = StreamController<AudioPlayerSnapshot>.broadcast();
  AudioPlayerSnapshot _snapshot = const AudioPlayerSnapshot();

  bool isInitialized = false;
  bool isDisposed = false;

  void _emit(AudioPlayerSnapshot newSnapshot) {
    _snapshot = newSnapshot;
    if (!_controller.isClosed) {
      _controller.add(_snapshot);
    }
  }

  @override
  AudioPlayerSnapshot get snapshot => _snapshot;

  @override
  Stream<AudioPlayerSnapshot> get stateStream => _controller.stream;

  @override
  Future<void> initialize() async {
    isInitialized = true;
    _emit(_snapshot.copyWith(status: AudioPlaybackStatus.idle));
  }

  @override
  Future<void> loadAsset(String assetPath) async {
    if (assetPath == 'invalid_asset.wav') {
      _emit(
        _snapshot.copyWith(
          status: AudioPlaybackStatus.error,
          errorMessage: 'Audio asset unavailable.',
        ),
      );
      return;
    }

    _emit(
      _snapshot.copyWith(
        status: AudioPlaybackStatus.idle,
        currentAsset: assetPath,
        duration: const Duration(seconds: 45),
        position: Duration.zero,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<void> play() async {
    if (_snapshot.isError || _snapshot.currentAsset == null) return;
    _emit(_snapshot.copyWith(status: AudioPlaybackStatus.playing));
  }

  @override
  Future<void> pause() async {
    _emit(_snapshot.copyWith(status: AudioPlaybackStatus.paused));
  }

  @override
  Future<void> resume() async {
    _emit(_snapshot.copyWith(status: AudioPlaybackStatus.playing));
  }

  @override
  Future<void> replay() async {
    _emit(
      _snapshot.copyWith(
        status: AudioPlaybackStatus.playing,
        position: Duration.zero,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) async {
    _emit(_snapshot.copyWith(position: position));
  }

  @override
  Future<void> setSpeed(double speed) async {
    _emit(_snapshot.copyWith(speed: speed));
  }

  @override
  Future<void> stop() async {
    _emit(
      _snapshot.copyWith(
        status: AudioPlaybackStatus.idle,
        position: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    isDisposed = true;
    _controller.close();
  }
}

void main() {
  group('AudioPlayerSnapshot tests', () {
    test('Calculates progressFraction correctly', () {
      const snap = AudioPlayerSnapshot(
        duration: Duration(seconds: 100),
        position: Duration(seconds: 25),
      );
      expect(snap.progressFraction, equals(0.25));

      const emptySnap = AudioPlayerSnapshot();
      expect(emptySnap.progressFraction, equals(0.0));
    });

    test('Status flags map accurately', () {
      const snapPlaying = AudioPlayerSnapshot(
        status: AudioPlaybackStatus.playing,
      );
      expect(snapPlaying.isPlaying, isTrue);
      expect(snapPlaying.isPaused, isFalse);

      const snapError = AudioPlayerSnapshot(status: AudioPlaybackStatus.error);
      expect(snapError.isError, isTrue);
    });
  });

  group('FakeAudioPlayerService state transitions', () {
    late FakeAudioPlayerService service;

    setUp(() async {
      service = FakeAudioPlayerService();
      await service.initialize();
    });

    tearDown(() {
      service.dispose();
    });

    test('Initializes with idle status', () {
      expect(service.isInitialized, isTrue);
      expect(service.snapshot.status, equals(AudioPlaybackStatus.idle));
    });

    test('Loads asset and updates duration', () async {
      await service.loadAsset('assets/audio/test.wav');
      expect(service.snapshot.currentAsset, equals('assets/audio/test.wav'));
      expect(service.snapshot.duration, equals(const Duration(seconds: 45)));
      expect(service.snapshot.position, equals(Duration.zero));
    });

    test('Handles play, pause, resume, seek, and speed changes', () async {
      await service.loadAsset('assets/audio/test.wav');

      await service.play();
      expect(service.snapshot.status, equals(AudioPlaybackStatus.playing));

      await service.seek(const Duration(seconds: 15));
      expect(service.snapshot.position, equals(const Duration(seconds: 15)));

      await service.pause();
      expect(service.snapshot.status, equals(AudioPlaybackStatus.paused));

      await service.setSpeed(1.25);
      expect(service.snapshot.speed, equals(1.25));

      await service.replay();
      expect(service.snapshot.position, equals(Duration.zero));
      expect(service.snapshot.status, equals(AudioPlaybackStatus.playing));

      await service.stop();
      expect(service.snapshot.status, equals(AudioPlaybackStatus.idle));
    });

    test('Handles error gracefully when asset is invalid', () async {
      await service.loadAsset('invalid_asset.wav');
      expect(service.snapshot.status, equals(AudioPlaybackStatus.error));
      expect(service.snapshot.errorMessage, isNotNull);
    });
  });
}

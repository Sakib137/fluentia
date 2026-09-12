import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/models/audio_player_state.dart';
import '../../domain/services/audio_player_service.dart';

/// Concrete [AudioPlayerService] using the `audioplayers` package.
///
/// Encapsulates all package-specific audio calls, exposes an immutable
/// [AudioPlayerSnapshot] stream, and handles missing/unavailable audio gracefully.
class AudioplayerAudioService implements AudioPlayerService {
  AudioplayerAudioService({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _initSubscriptions();
  }

  final AudioPlayer _player;
  final _stateController = StreamController<AudioPlayerSnapshot>.broadcast();

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completeSub;

  AudioPlayerSnapshot _currentSnapshot = const AudioPlayerSnapshot();

  @override
  AudioPlayerSnapshot get snapshot => _currentSnapshot;

  @override
  Stream<AudioPlayerSnapshot> get stateStream => _stateController.stream;

  void _updateSnapshot(AudioPlayerSnapshot newSnapshot) {
    _currentSnapshot = newSnapshot;
    if (!_stateController.isClosed) {
      _stateController.add(_currentSnapshot);
    }
  }

  void _initSubscriptions() {
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      final newStatus = switch (state) {
        PlayerState.playing => AudioPlaybackStatus.playing,
        PlayerState.paused => AudioPlaybackStatus.paused,
        PlayerState.completed => AudioPlaybackStatus.completed,
        PlayerState.stopped => AudioPlaybackStatus.idle,
        PlayerState.disposed => AudioPlaybackStatus.idle,
      };

      _updateSnapshot(_currentSnapshot.copyWith(status: newStatus));
    });

    _durationSub = _player.onDurationChanged.listen((duration) {
      if (duration > Duration.zero) {
        _updateSnapshot(_currentSnapshot.copyWith(duration: duration));
      }
    });

    _positionSub = _player.onPositionChanged.listen((position) {
      _updateSnapshot(_currentSnapshot.copyWith(position: position));
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      _updateSnapshot(
        _currentSnapshot.copyWith(
          status: AudioPlaybackStatus.completed,
          position: _currentSnapshot.duration,
        ),
      );
    });
  }

  @override
  Future<void> initialize() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      AppLogger.warning(
        'AudioPlayer initialize notice: $e',
        tag: 'AudioPlayer',
      );
    }
  }

  @override
  Future<void> loadAsset(String assetPath) async {
    _updateSnapshot(
      _currentSnapshot.copyWith(
        status: AudioPlaybackStatus.loading,
        currentAsset: assetPath,
        errorMessage: null,
        position: Duration.zero,
      ),
    );

    try {
      // audioplayers AssetSource expects relative path from inside assets/
      final relativePath = assetPath.startsWith('assets/')
          ? assetPath.substring('assets/'.length)
          : assetPath;

      await _player.setSource(AssetSource(relativePath));

      // Attempt to retrieve preloaded duration
      final duration = await _player.getDuration();
      _updateSnapshot(
        _currentSnapshot.copyWith(
          status: AudioPlaybackStatus.idle,
          duration: duration ?? Duration.zero,
        ),
      );
    } catch (e) {
      AppLogger.warning(
        'Audio asset unavailable or failed to load: $assetPath. Error: $e',
        tag: 'AudioPlayer',
      );
      _updateSnapshot(
        _currentSnapshot.copyWith(
          status: AudioPlaybackStatus.error,
          errorMessage:
              'Audio file unavailable. You may retry or use the transcript.',
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    final asset = _currentSnapshot.currentAsset;
    if (asset == null || asset.isEmpty) {
      _updateSnapshot(
        _currentSnapshot.copyWith(
          status: AudioPlaybackStatus.error,
          errorMessage: 'No audio asset loaded.',
        ),
      );
      return;
    }

    try {
      if (_currentSnapshot.isCompleted) {
        await seek(Duration.zero);
      }
      final relativePath = asset.startsWith('assets/')
          ? asset.substring('assets/'.length)
          : asset;
      await _player.play(AssetSource(relativePath));
      await _player.setPlaybackRate(_currentSnapshot.speed);
    } catch (e) {
      AppLogger.warning('Audio playback failed: $e', tag: 'AudioPlayer');
      _updateSnapshot(
        _currentSnapshot.copyWith(
          status: AudioPlaybackStatus.error,
          errorMessage: 'Playback failed. Please retry.',
        ),
      );
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      AppLogger.warning('Audio pause notice: $e', tag: 'AudioPlayer');
    }
  }

  @override
  Future<void> resume() async {
    try {
      await _player.resume();
    } catch (e) {
      await play();
    }
  }

  @override
  Future<void> replay() async {
    try {
      await seek(Duration.zero);
      await resume();
    } catch (e) {
      await play();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      _updateSnapshot(_currentSnapshot.copyWith(position: position));
    } catch (e) {
      AppLogger.warning('Audio seek notice: $e', tag: 'AudioPlayer');
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    try {
      _updateSnapshot(_currentSnapshot.copyWith(speed: speed));
      await _player.setPlaybackRate(speed);
    } catch (e) {
      AppLogger.warning('Audio setPlaybackRate notice: $e', tag: 'AudioPlayer');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      _updateSnapshot(
        _currentSnapshot.copyWith(
          status: AudioPlaybackStatus.idle,
          position: Duration.zero,
        ),
      );
    } catch (e) {
      AppLogger.warning('Audio stop notice: $e', tag: 'AudioPlayer');
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    _stateController.close();
  }
}

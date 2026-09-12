/// Playback status for offline audio player.
enum AudioPlaybackStatus {
  idle,
  loading,
  playing,
  paused,
  completed,
  error;

  String get displayName => switch (this) {
    idle => 'Ready',
    loading => 'Loading Audio...',
    playing => 'Playing',
    paused => 'Paused',
    completed => 'Completed',
    error => 'Playback Error',
  };
}

/// Immutable snapshot of audio player state.
class AudioPlayerSnapshot {
  const AudioPlayerSnapshot({
    this.status = AudioPlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.currentAsset,
    this.errorMessage,
  });

  final AudioPlaybackStatus status;
  final Duration position;
  final Duration duration;
  final double speed;
  final String? currentAsset;
  final String? errorMessage;

  bool get isPlaying => status == AudioPlaybackStatus.playing;
  bool get isPaused => status == AudioPlaybackStatus.paused;
  bool get isLoading => status == AudioPlaybackStatus.loading;
  bool get isCompleted => status == AudioPlaybackStatus.completed;
  bool get isError => status == AudioPlaybackStatus.error;

  double get progressFraction {
    if (duration.inMilliseconds <= 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  AudioPlayerSnapshot copyWith({
    AudioPlaybackStatus? status,
    Duration? position,
    Duration? duration,
    double? speed,
    String? currentAsset,
    String? errorMessage,
  }) {
    return AudioPlayerSnapshot(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentAsset: currentAsset ?? this.currentAsset,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlayerSnapshot &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          position == other.position &&
          duration == other.duration &&
          speed == other.speed &&
          currentAsset == other.currentAsset &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
    status,
    position,
    duration,
    speed,
    currentAsset,
    errorMessage,
  );
}

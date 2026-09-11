import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../practice/data/repositories/practice_repository.dart';
import '../../../practice/domain/models/practice_models.dart';
import '../../../practice/presentation/providers/practice_providers.dart';
import '../../domain/models/speaking_activity.dart';
import '../../domain/models/speaking_metrics.dart';
import '../../domain/models/speech_recognition_state.dart';
import 'speaking_providers.dart';

/// State of an active speaking practice session.
class SpeakingSessionState {
  const SpeakingSessionState({
    this.activity,
    this.recordingState = SpeechRecordingState.idle,
    this.prepRemainingSeconds = 0,
    this.elapsedSeconds = 0,
    this.maxSpeakingSeconds = 60,
    this.transcript = '',
    this.soundLevel = 0.0,
    this.metrics,
    this.errorMessage,
    this.sessionId,
  });

  final SpeakingActivity? activity;
  final SpeechRecordingState recordingState;
  final int prepRemainingSeconds;
  final int elapsedSeconds;
  final int maxSpeakingSeconds;
  final String transcript;
  final double soundLevel;
  final SpeakingMetrics? metrics;
  final String? errorMessage;
  final String? sessionId;

  bool get isPreparing => recordingState.isPreparing;
  bool get isListening => recordingState.isListening;
  bool get isProcessing => recordingState.isProcessing;
  bool get isCompleted => recordingState.isCompleted;

  SpeakingSessionState copyWith({
    SpeakingActivity? activity,
    SpeechRecordingState? recordingState,
    int? prepRemainingSeconds,
    int? elapsedSeconds,
    int? maxSpeakingSeconds,
    String? transcript,
    double? soundLevel,
    SpeakingMetrics? metrics,
    String? errorMessage,
    String? sessionId,
  }) {
    return SpeakingSessionState(
      activity: activity ?? this.activity,
      recordingState: recordingState ?? this.recordingState,
      prepRemainingSeconds: prepRemainingSeconds ?? this.prepRemainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      maxSpeakingSeconds: maxSpeakingSeconds ?? this.maxSpeakingSeconds,
      transcript: transcript ?? this.transcript,
      soundLevel: soundLevel ?? this.soundLevel,
      metrics: metrics ?? this.metrics,
      errorMessage: errorMessage,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

/// State controller managing active speaking practice drill lifecycle.
class SpeakingSessionController extends Notifier<SpeakingSessionState> {
  Timer? _prepTimer;
  Timer? _speakingTimer;
  StreamSubscription<double>? _soundSubscription;

  PracticeRepository get _practiceRepository =>
      ref.read(practiceRepositoryProvider);

  @override
  SpeakingSessionState build() {
    ref.onDispose(() {
      _cleanupTimers();
    });
    return const SpeakingSessionState();
  }

  void _cleanupTimers() {
    _prepTimer?.cancel();
    _prepTimer = null;
    _speakingTimer?.cancel();
    _speakingTimer = null;
    _soundSubscription?.cancel();
    _soundSubscription = null;
  }

  /// Prepares a speaking activity for practice.
  void initializeActivity(SpeakingActivity activity) {
    _cleanupTimers();
    final newSessionId = 'spk_session_${DateTime.now().microsecondsSinceEpoch}';

    state = SpeakingSessionState(
      activity: activity,
      recordingState: SpeechRecordingState.idle,
      prepRemainingSeconds: activity.preparationSeconds,
      elapsedSeconds: 0,
      maxSpeakingSeconds: activity.speakingSeconds,
      transcript: '',
      soundLevel: 0.0,
      sessionId: newSessionId,
    );
  }

  /// Begins preparation countdown timer.
  void startPreparation() {
    final activity = state.activity;
    if (activity == null) return;

    _cleanupTimers();
    state = state.copyWith(
      recordingState: SpeechRecordingState.preparing,
      prepRemainingSeconds: activity.preparationSeconds,
    );

    _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.prepRemainingSeconds <= 1) {
        timer.cancel();
        _prepTimer = null;
        startSpeaking();
      } else {
        state = state.copyWith(
          prepRemainingSeconds: state.prepRemainingSeconds - 1,
        );
      }
    });
  }

  /// Starts listening and recording speech.
  Future<void> startSpeaking() async {
    _prepTimer?.cancel();
    _prepTimer = null;

    final speechService = ref.read(speechRecognitionServiceProvider);

    // Permission check
    final perm = await speechService.requestPermission();
    if (!perm.isGranted) {
      state = state.copyWith(
        recordingState: SpeechRecordingState.permissionDenied,
        errorMessage: 'Microphone access is required to practice speaking.',
      );
      return;
    }

    final available = await speechService.isAvailable();
    if (!available) {
      state = state.copyWith(
        recordingState: SpeechRecordingState.unavailable,
        errorMessage:
            'Speaking recognition isn\'t available on this device yet.',
      );
      return;
    }

    state = state.copyWith(
      recordingState: SpeechRecordingState.listening,
      elapsedSeconds: 0,
      transcript: '',
      errorMessage: null,
    );

    // Subscribe to sound levels
    _soundSubscription?.cancel();
    _soundSubscription = speechService.soundLevelStream.listen((level) {
      if (state.isListening) {
        state = state.copyWith(soundLevel: level);
      }
    });

    // Start native listening
    await speechService.startListening(
      onResult: (words, isFinal) {
        state = state.copyWith(transcript: words);
      },
      listenFor: Duration(seconds: state.maxSpeakingSeconds + 5),
    );

    // Speaking duration ticker
    _speakingTimer?.cancel();
    _speakingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nextElapsed = state.elapsedSeconds + 1;
      if (nextElapsed >= state.maxSpeakingSeconds) {
        timer.cancel();
        _speakingTimer = null;
        stopSpeaking();
      } else {
        state = state.copyWith(elapsedSeconds: nextElapsed);
      }
    });
  }

  /// Stops recording and processes speech for honest analysis.
  Future<void> stopSpeaking() async {
    _cleanupTimers();

    final speechService = ref.read(speechRecognitionServiceProvider);
    final analysisService = ref.read(speakingAnalysisServiceProvider);
    final activity = state.activity;

    state = state.copyWith(
      recordingState: SpeechRecordingState.processing,
      soundLevel: 0.0,
    );

    await speechService.stopListening();
    // Allow brief time for final native transcript delivery
    await Future.delayed(const Duration(milliseconds: 300));

    final finalTranscript = state.transcript.isNotEmpty
        ? state.transcript
        : speechService.currentTranscript;

    if (activity != null) {
      final metrics = await analysisService.analyze(
        activity: activity,
        recognizedText: finalTranscript,
        speakingDuration: Duration(seconds: math.max(state.elapsedSeconds, 1)),
      );

      state = state.copyWith(
        recordingState: SpeechRecordingState.completed,
        transcript: finalTranscript,
        metrics: metrics,
      );
    } else {
      state = state.copyWith(recordingState: SpeechRecordingState.completed);
    }
  }

  /// Cancels recording and resets to idle.
  Future<void> cancelSpeaking() async {
    _cleanupTimers();
    final speechService = ref.read(speechRecognitionServiceProvider);
    await speechService.cancelListening();

    if (ref.mounted) {
      state = state.copyWith(
        recordingState: SpeechRecordingState.idle,
        elapsedSeconds: 0,
        soundLevel: 0.0,
        transcript: '',
        errorMessage: null,
      );
    }
  }

  /// Synchronously cancels all active timers and subscriptions.
  void cleanup() {
    _cleanupTimers();
  }

  /// Retries the current speaking activity.
  void retry() {
    final activity = state.activity;
    if (activity != null) {
      initializeActivity(activity);
    }
  }

  /// Completes practice session and persists result into SQLite database.
  Future<PracticeSession?> completeSession() async {
    final activity = state.activity;
    if (activity == null) return null;

    final metrics = state.metrics;
    final now = DateTime.now();
    final elapsedSec = state.elapsedSeconds;
    // Credit at least the activity estimated duration (min 120s) or elapsed
    final durationSeconds = math.max(
      elapsedSec > 0 ? elapsedSec : 120,
      activity.estimatedDurationMinutes * 60,
    );
    final score = metrics?.matchPercentage ?? 85.0;

    final session = PracticeSession(
      id: state.sessionId ?? 'spk_${now.microsecondsSinceEpoch}',
      skill: PracticeSkill.speaking,
      activityIds: [activity.id],
      level: activity.level,
      startedAt: now.subtract(Duration(seconds: durationSeconds)),
      completedAt: now,
      durationSeconds: durationSeconds,
      score: score,
      status: PracticeSessionStatus.completed,
      currentActivityIndex: 1,
      totalActivities: 1,
    );

    await _practiceRepository.saveSession(session);
    return session;
  }

  /// Abandons current session upon user confirmation.
  Future<void> abandonSession() async {
    _cleanupTimers();
    final speechService = ref.read(speechRecognitionServiceProvider);
    await speechService.cancelListening();

    final activity = state.activity;
    if (activity == null) return;

    final now = DateTime.now();
    final session = PracticeSession(
      id: state.sessionId ?? 'spk_${now.microsecondsSinceEpoch}',
      skill: PracticeSkill.speaking,
      activityIds: [activity.id],
      level: activity.level,
      startedAt: now,
      completedAt: now,
      durationSeconds: state.elapsedSeconds,
      score: null,
      status: PracticeSessionStatus.abandoned,
      currentActivityIndex: 0,
      totalActivities: 1,
    );

    await _practiceRepository.saveSession(session);
    state = const SpeakingSessionState();
  }
}

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../practice/data/repositories/practice_repository.dart';
import '../../../practice/domain/models/practice_models.dart';
import '../../../practice/presentation/providers/practice_providers.dart';
import '../../domain/models/listening_activity.dart';
import '../../domain/models/listening_mode.dart';
import '../../domain/services/audio_player_service.dart';
import '../../domain/services/listening_scoring.dart';
import 'listening_providers.dart';

/// Active state snapshot for an ongoing listening drill.
class ListeningSessionState {
  const ListeningSessionState({
    this.activity,
    this.session,
    this.isSubmitted = false,
    this.isCorrect = false,
    this.scorePercentage = 0.0,
    this.selectedOption,
    this.dictationInput = '',
    this.dictationResult,
    this.missingWordsAnswers = const {},
    this.missingWordsResults,
    this.currentComprehensionIndex = 0,
    this.comprehensionAnswers = const {},
    this.comprehensionResults = const {},
    this.isCompleted = false,
    this.isLoading = false,
    this.errorMessage,
    this.startedAt,
  });

  final ListeningActivity? activity;
  final PracticeSession? session;
  final bool isSubmitted;
  final bool isCorrect;
  final double scorePercentage;
  final String? selectedOption;
  final String dictationInput;
  final DictationResult? dictationResult;
  final Map<int, String> missingWordsAnswers;
  final Map<int, bool>? missingWordsResults;
  final int currentComprehensionIndex;
  final Map<String, String> comprehensionAnswers;
  final Map<String, bool> comprehensionResults;
  final bool isCompleted;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? startedAt;

  bool get canSubmit {
    if (activity == null || isSubmitted) return false;
    return switch (activity!.mode) {
      ListeningMode.listenAndChoose || ListeningMode.trueFalse =>
        selectedOption != null && selectedOption!.isNotEmpty,
      ListeningMode.dictation => dictationInput.trim().isNotEmpty,
      ListeningMode.fillMissingWords => missingWordsAnswers.values.any(
        (val) => val.trim().isNotEmpty,
      ),
      ListeningMode.comprehension => () {
        final questions = activity!.comprehensionQuestions;
        if (questions.isEmpty) return false;
        final currentQ = questions[currentComprehensionIndex];
        return comprehensionAnswers[currentQ.id] != null;
      }(),
    };
  }

  ListeningSessionState copyWith({
    ListeningActivity? activity,
    PracticeSession? session,
    bool? isSubmitted,
    bool? isCorrect,
    double? scorePercentage,
    String? selectedOption,
    String? dictationInput,
    DictationResult? dictationResult,
    Map<int, String>? missingWordsAnswers,
    Map<int, bool>? missingWordsResults,
    int? currentComprehensionIndex,
    Map<String, String>? comprehensionAnswers,
    Map<String, bool>? comprehensionResults,
    bool? isCompleted,
    bool? isLoading,
    String? errorMessage,
    DateTime? startedAt,
  }) {
    return ListeningSessionState(
      activity: activity ?? this.activity,
      session: session ?? this.session,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isCorrect: isCorrect ?? this.isCorrect,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      selectedOption: selectedOption ?? this.selectedOption,
      dictationInput: dictationInput ?? this.dictationInput,
      dictationResult: dictationResult ?? this.dictationResult,
      missingWordsAnswers: missingWordsAnswers ?? this.missingWordsAnswers,
      missingWordsResults: missingWordsResults ?? this.missingWordsResults,
      currentComprehensionIndex:
          currentComprehensionIndex ?? this.currentComprehensionIndex,
      comprehensionAnswers: comprehensionAnswers ?? this.comprehensionAnswers,
      comprehensionResults: comprehensionResults ?? this.comprehensionResults,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

/// Controller coordinating the lifecycle, answering, scoring,
/// audio interruptions, and practice session persistence for Listening.
class ListeningSessionController extends Notifier<ListeningSessionState>
    with WidgetsBindingObserver {
  @override
  ListeningSessionState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });
    return const ListeningSessionState();
  }

  PracticeRepository get _practiceRepo => ref.read(practiceRepositoryProvider);
  AudioPlayerService get _audioPlayer => ref.read(audioPlayerServiceProvider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      // Pause playback to conserve battery and avoid unexpected audio
      _audioPlayer.pause();
    }
  }

  /// Prepares an activity and creates an in-progress PracticeSession.
  Future<void> initializeActivity(ListeningActivity activity) async {
    state = ListeningSessionState(
      activity: activity,
      isLoading: true,
      startedAt: DateTime.now(),
    );

    try {
      // Create PracticeSession representation
      final sessionId =
          'listening_session_${DateTime.now().millisecondsSinceEpoch}';
      final practiceActivity = activity.toPracticeActivity();
      final session = PracticeSession(
        id: sessionId,
        skill: PracticeSkill.listening,
        activityIds: [practiceActivity.id],
        level: activity.level,
        startedAt: DateTime.now(),
        status: PracticeSessionStatus.inProgress,
        currentActivityIndex: 0,
        totalActivities: 1,
      );

      // Save continue-listening hint in local preferences
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(kContinueListeningActivityIdKey, activity.id);

      // Preload audio asset
      await _audioPlayer.loadAsset(activity.audioAsset);

      state = state.copyWith(session: session, isLoading: false);
    } catch (e, st) {
      AppLogger.error(
        'Failed to initialize listening activity',
        error: e,
        stackTrace: st,
        tag: 'ListeningSession',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to prepare activity audio: $e',
      );
    }
  }

  /// Sets chosen option for Multiple Choice or True/False.
  void selectOption(String option) {
    if (state.isSubmitted) return;
    state = state.copyWith(selectedOption: option);
  }

  /// Updates dictation transcription text.
  void updateDictationInput(String text) {
    if (state.isSubmitted) return;
    state = state.copyWith(dictationInput: text);
  }

  /// Updates single blank in fill-in-the-missing-words mode.
  void updateMissingWord(int index, String word) {
    if (state.isSubmitted) return;
    final updated = Map<int, String>.from(state.missingWordsAnswers);
    updated[index] = word;
    state = state.copyWith(missingWordsAnswers: updated);
  }

  /// Sets answer for a specific question in multi-question comprehension.
  void selectComprehensionOption(String questionId, String option) {
    if (state.isSubmitted) return;
    final updated = Map<String, String>.from(state.comprehensionAnswers);
    updated[questionId] = option;
    state = state.copyWith(comprehensionAnswers: updated);
  }

  /// Submits and scores the current exercise.
  void submitAnswer() {
    final activity = state.activity;
    if (activity == null || state.isSubmitted) return;

    switch (activity.mode) {
      case ListeningMode.listenAndChoose:
        final userChoice = state.selectedOption ?? '';
        final isCorrect = ListeningScoring.evaluateTextAnswer(
          userAnswer: userChoice,
          expectedAnswer: activity.correctAnswer ?? '',
          acceptedAnswers: activity.acceptedAnswers,
        );
        state = state.copyWith(
          isSubmitted: true,
          isCorrect: isCorrect,
          scorePercentage: isCorrect ? 100.0 : 0.0,
        );

      case ListeningMode.trueFalse:
        final userChoice = state.selectedOption ?? '';
        final isCorrect =
            ListeningScoring.normalizeText(userChoice) ==
            ListeningScoring.normalizeText(activity.correctAnswer ?? '');
        state = state.copyWith(
          isSubmitted: true,
          isCorrect: isCorrect,
          scorePercentage: isCorrect ? 100.0 : 0.0,
        );

      case ListeningMode.dictation:
        final dictResult = ListeningScoring.evaluateDictation(
          userText: state.dictationInput,
          expectedTranscript: activity.transcript,
        );
        state = state.copyWith(
          isSubmitted: true,
          isCorrect: dictResult.accuracyPercentage >= 80.0,
          scorePercentage: dictResult.accuracyPercentage,
          dictationResult: dictResult,
        );

      case ListeningMode.fillMissingWords:
        final results = ListeningScoring.evaluateMissingWords(
          userAnswers: state.missingWordsAnswers,
          expectedWords: activity.missingWords,
        );
        final total = activity.missingWords.length;
        final correctCount = results.values.where((c) => c).length;
        final percentage = total > 0
            ? (correctCount / total * 100).clamp(0.0, 100.0)
            : 100.0;
        state = state.copyWith(
          isSubmitted: true,
          isCorrect: correctCount == total,
          scorePercentage: percentage,
          missingWordsResults: results,
        );

      case ListeningMode.comprehension:
        final questions = activity.comprehensionQuestions;
        final currentIdx = state.currentComprehensionIndex;
        if (currentIdx < questions.length) {
          final currentQ = questions[currentIdx];
          final answer = state.comprehensionAnswers[currentQ.id] ?? '';
          final isQCorrect =
              ListeningScoring.normalizeText(answer) ==
              ListeningScoring.normalizeText(currentQ.correctAnswer);

          final updatedResults = Map<String, bool>.from(
            state.comprehensionResults,
          );
          updatedResults[currentQ.id] = isQCorrect;

          state = state.copyWith(
            isSubmitted: true,
            isCorrect: isQCorrect,
            comprehensionResults: updatedResults,
          );
        }
    }
  }

  /// Advances to next question in a multi-question comprehension passage.
  void nextComprehensionQuestion() {
    final activity = state.activity;
    if (activity == null) return;
    final questions = activity.comprehensionQuestions;

    if (state.currentComprehensionIndex < questions.length - 1) {
      state = state.copyWith(
        currentComprehensionIndex: state.currentComprehensionIndex + 1,
        isSubmitted: false,
        isCorrect: false,
      );
    }
  }

  /// Finalizes the listening session, calculates durations, and persists to SQLite.
  Future<PracticeSession?> completeSession() async {
    final currentSession = state.session;
    final activity = state.activity;
    if (currentSession == null || activity == null) return null;

    // Halt audio playback
    await _audioPlayer.stop();

    final now = DateTime.now();
    final elapsedSec = state.startedAt != null
        ? now.difference(state.startedAt!).inSeconds
        : 180;

    // Credit at least the activity estimated duration (minimum 2 minutes / 120s)
    final minSec = activity.estimatedDurationMinutes * 60;
    final finalDurationSec = math.max(
      elapsedSec > 0 ? elapsedSec : 120,
      minSec,
    );

    // Compute aggregate score for comprehension or use single-drill score
    double finalScore = state.scorePercentage;
    if (activity.mode == ListeningMode.comprehension &&
        activity.comprehensionQuestions.isNotEmpty) {
      final total = activity.comprehensionQuestions.length;
      final correct = state.comprehensionResults.values.where((c) => c).length;
      finalScore = (correct / total * 100).clamp(0.0, 100.0);
    }

    final completedSession = currentSession.copyWith(
      status: PracticeSessionStatus.completed,
      completedAt: now,
      durationSeconds: finalDurationSec,
      score: finalScore,
      currentActivityIndex: currentSession.totalActivities,
    );

    state = state.copyWith(
      session: completedSession,
      isCompleted: true,
      scorePercentage: finalScore,
    );

    // Persist to SQLite UserProgressTable and PracticeSessionsTable
    await _practiceRepo.saveSession(completedSession);

    // Clean up continue-listening draft from preferences
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(kContinueListeningActivityIdKey);

    AppLogger.info(
      'Listening practice session completed: ${completedSession.id} (${finalDurationSec}s, Score: ${finalScore.toStringAsFixed(1)}%)',
      tag: 'ListeningSession',
    );

    return completedSession;
  }

  /// Resets controller state.
  void reset() {
    _audioPlayer.stop();
    state = const ListeningSessionState();
  }
}

/// Provider for the listening session controller.
final listeningSessionControllerProvider =
    NotifierProvider.autoDispose<
      ListeningSessionController,
      ListeningSessionState
    >(ListeningSessionController.new);

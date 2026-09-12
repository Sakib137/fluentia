import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../practice/domain/models/practice_models.dart';
import '../../../practice/presentation/providers/practice_providers.dart';
import '../../domain/models/reading_activity.dart';
import '../../domain/models/reading_question.dart';
import '../../domain/services/reading_scoring.dart';
import 'reading_providers.dart';

/// Immutable state for an active reading session.
class ReadingSessionState {
  const ReadingSessionState({
    this.activity,
    this.session,
    this.isLoading = false,
    this.isPassagePhase = true,
    this.currentQuestionIndex = 0,
    this.userAnswers = const {},
    this.questionResults = const {},
    this.isSubmitted = false,
    this.isCompleted = false,
    this.scorePercentage = 0.0,
    this.approxWpm = 0,
    this.startedAt,
    this.elapsedDuration = Duration.zero,
    this.fontSizeDelta = 0.0,
    this.errorMessage,
  });

  final ReadingActivity? activity;
  final PracticeSession? session;
  final bool isLoading;
  final bool isPassagePhase;
  final int currentQuestionIndex;
  final Map<String, String> userAnswers;
  final Map<String, bool> questionResults;
  final bool isSubmitted;
  final bool isCompleted;
  final double scorePercentage;
  final int approxWpm;
  final DateTime? startedAt;
  final Duration elapsedDuration;
  final double fontSizeDelta;
  final String? errorMessage;

  ReadingQuestion? get currentQuestion {
    if (activity == null || activity!.questions.isEmpty) return null;
    if (currentQuestionIndex < 0 ||
        currentQuestionIndex >= activity!.questions.length) {
      return null;
    }
    return activity!.questions[currentQuestionIndex];
  }

  String get currentAnswer {
    final q = currentQuestion;
    if (q == null) return '';
    return userAnswers[q.id] ?? '';
  }

  bool get canSubmit {
    final q = currentQuestion;
    if (q == null || isSubmitted || isCompleted) return false;
    final ans = userAnswers[q.id]?.trim() ?? '';
    return ans.isNotEmpty;
  }

  bool get isCurrentCorrect {
    final q = currentQuestion;
    if (q == null) return false;
    return questionResults[q.id] ?? false;
  }

  int get correctCount => questionResults.values.where((v) => v).length;
  int get totalQuestions => activity?.questions.length ?? 0;

  ReadingSessionState copyWith({
    ReadingActivity? activity,
    PracticeSession? session,
    bool? isLoading,
    bool? isPassagePhase,
    int? currentQuestionIndex,
    Map<String, String>? userAnswers,
    Map<String, bool>? questionResults,
    bool? isSubmitted,
    bool? isCompleted,
    double? scorePercentage,
    int? approxWpm,
    DateTime? startedAt,
    Duration? elapsedDuration,
    double? fontSizeDelta,
    String? errorMessage,
  }) {
    return ReadingSessionState(
      activity: activity ?? this.activity,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      isPassagePhase: isPassagePhase ?? this.isPassagePhase,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      questionResults: questionResults ?? this.questionResults,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isCompleted: isCompleted ?? this.isCompleted,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      approxWpm: approxWpm ?? this.approxWpm,
      startedAt: startedAt ?? this.startedAt,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      fontSizeDelta: fontSizeDelta ?? this.fontSizeDelta,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller managing reading activity state, passage display, scoring, and PracticeRepository persistence.
class ReadingSessionController extends Notifier<ReadingSessionState> {
  @override
  ReadingSessionState build() {
    return const ReadingSessionState();
  }

  /// Initializes an active reading activity.
  Future<void> initializeActivity(
    ReadingActivity activity, {
    int initialQuestionIndex = 0,
  }) async {
    state = state.copyWith(
      isLoading: true,
      activity: activity,
      isPassagePhase: true,
      currentQuestionIndex: initialQuestionIndex,
      userAnswers: {},
      questionResults: {},
      isSubmitted: false,
      isCompleted: false,
      scorePercentage: 0.0,
      approxWpm: 0,
      startedAt: DateTime.now(),
      elapsedDuration: Duration.zero,
    );

    try {
      final sessionId =
          'reading_session_${DateTime.now().millisecondsSinceEpoch}';
      final practiceActivity = activity.toPracticeActivity();
      final session = PracticeSession(
        id: sessionId,
        skill: PracticeSkill.reading,
        activityIds: [practiceActivity.id],
        level: activity.level,
        startedAt: DateTime.now(),
        durationSeconds: 0,
        status: PracticeSessionStatus.inProgress,
        totalActivities: 1,
        currentActivityIndex: 0,
        score: 0.0,
      );

      // Save continue-reading marker in local storage
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(kContinueReadingActivityIdKey, activity.id);
      await prefs.setInt(
        kContinueReadingQuestionIndexKey,
        initialQuestionIndex,
      );

      state = state.copyWith(session: session, isLoading: false);
    } catch (e, st) {
      AppLogger.error(
        'Failed to initialize reading activity',
        error: e,
        stackTrace: st,
        tag: 'ReadingSession',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to start reading session. Please try again.',
      );
    }
  }

  /// Adjusts text sizing for the reading passage (delta between -4 and +6).
  void setFontSizeDelta(double delta) {
    final clamped = delta.clamp(-4.0, 6.0);
    state = state.copyWith(fontSizeDelta: clamped);
  }

  /// Increases font size.
  void increaseFontSize() {
    setFontSizeDelta(state.fontSizeDelta + 2.0);
  }

  /// Decreases font size.
  void decreaseFontSize() {
    setFontSizeDelta(state.fontSizeDelta - 2.0);
  }

  /// Resets font size to default.
  void resetFontSize() {
    setFontSizeDelta(0.0);
  }

  /// Toggles between full-screen passage mode and interactive questions mode.
  void setPassagePhase(bool isPassage) {
    state = state.copyWith(isPassagePhase: isPassage);
  }

  /// Sets answer for the current question (multiple choice, true/false, or main idea).
  void selectOption(String option) {
    if (state.isSubmitted || state.isCompleted) return;
    final q = state.currentQuestion;
    if (q == null) return;

    final updated = Map<String, String>.from(state.userAnswers);
    updated[q.id] = option;
    state = state.copyWith(userAnswers: updated);
  }

  /// Sets answer for short answer questions.
  void updateShortAnswer(String text) {
    if (state.isSubmitted || state.isCompleted) return;
    final q = state.currentQuestion;
    if (q == null) return;

    final updated = Map<String, String>.from(state.userAnswers);
    updated[q.id] = text;
    state = state.copyWith(userAnswers: updated);
  }

  /// Submits the current question and evaluates correctness.
  void submitAnswer() {
    if (state.isSubmitted || state.isCompleted) return;
    final q = state.currentQuestion;
    if (q == null) return;

    final userAnswer = state.userAnswers[q.id] ?? '';
    final isCorrect = ReadingScoring.isAnswerCorrect(
      userAnswer,
      q.correctAnswer,
      q.acceptedAnswers,
    );

    final updatedResults = Map<String, bool>.from(state.questionResults);
    updatedResults[q.id] = isCorrect;

    final correctCount = updatedResults.values.where((v) => v).length;
    final total = state.totalQuestions;
    final currentScore = ReadingScoring.calculateScorePercentage(
      correctCount: correctCount,
      totalCount: total,
    );

    state = state.copyWith(
      isSubmitted: true,
      questionResults: updatedResults,
      scorePercentage: currentScore,
    );
  }

  /// Advances to the next question in the activity.
  void nextQuestion() {
    final activity = state.activity;
    if (activity == null) return;

    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex < activity.questions.length) {
      state = state.copyWith(
        currentQuestionIndex: nextIndex,
        isSubmitted: false,
      );

      final prefs = ref.read(sharedPreferencesProvider);
      prefs.setInt(kContinueReadingQuestionIndexKey, nextIndex);
    }
  }

  /// Finalizes the reading session and saves to the SQLite PracticeRepository.
  Future<void> completeSession() async {
    final activity = state.activity;
    final currentSession = state.session;
    if (activity == null || currentSession == null) return;

    final now = DateTime.now();
    final elapsedSec = state.startedAt != null
        ? now.difference(state.startedAt!).inSeconds
        : 180;
    final duration = Duration(seconds: elapsedSec > 0 ? elapsedSec : 180);

    // Credit at least the estimated duration (minimum 2 minutes / 120s)
    final minSec = activity.estimatedDurationMinutes * 60;
    final finalDurationSec = math.max(
      elapsedSec > 0 ? elapsedSec : 120,
      minSec,
    );

    // Calculate approximate WPM and score
    final wpm = ReadingScoring.calculateApproxWpm(
      wordCount: activity.wordCount,
      duration: duration,
    );

    final total = activity.questions.length;
    final correct = state.questionResults.values.where((v) => v).length;
    final finalScore = ReadingScoring.calculateScorePercentage(
      correctCount: correct,
      totalCount: total,
    );

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
      approxWpm: wpm,
      elapsedDuration: duration,
    );

    try {
      final practiceRepo = ref.read(practiceRepositoryProvider);
      await practiceRepo.saveSession(completedSession);

      // Clear continue-reading storage marker
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove(kContinueReadingActivityIdKey);
      await prefs.remove(kContinueReadingQuestionIndexKey);

      AppLogger.info(
        'Reading practice session completed: ${completedSession.id} '
        '(${finalDurationSec}s, WPM: $wpm, Score: $finalScore%)',
        tag: 'ReadingSession',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to save completed reading session',
        error: e,
        stackTrace: st,
        tag: 'ReadingSession',
      );
    }
  }

  /// Abandons the active reading session and cleans up local storage.
  Future<void> abandonSession() async {
    final currentSession = state.session;
    if (currentSession != null) {
      final abandonedSession = currentSession.copyWith(
        status: PracticeSessionStatus.abandoned,
        completedAt: DateTime.now(),
      );
      try {
        final practiceRepo = ref.read(practiceRepositoryProvider);
        await practiceRepo.saveSession(abandonedSession);
      } catch (_) {}
    }

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(kContinueReadingActivityIdKey);
    await prefs.remove(kContinueReadingQuestionIndexKey);
  }
}

/// Provider for the reading session controller.
final readingSessionControllerProvider =
    NotifierProvider.autoDispose<ReadingSessionController, ReadingSessionState>(
      ReadingSessionController.new,
    );

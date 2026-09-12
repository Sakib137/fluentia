import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../practice/domain/models/practice_models.dart';
import '../../../practice/presentation/providers/practice_providers.dart';
import '../../domain/models/writing_activity.dart';
import '../../domain/models/writing_mode.dart';
import '../../domain/services/writing_evaluation_service.dart';
import '../../domain/services/writing_scoring.dart';
import 'writing_providers.dart';

/// Immutable state for an active writing practice session.
class WritingSessionState {
  const WritingSessionState({
    this.activity,
    this.session,
    this.isLoading = false,
    this.currentText = '',
    this.wordCount = 0,
    this.sentenceCount = 0,
    this.characterCount = 0,
    this.lengthStatus = WritingLengthStatus.empty,
    this.availableTokens = const [],
    this.selectedTokens = const [],
    this.checkedChecklistIndices = const {},
    this.isSubmitted = false,
    this.isCompleted = false,
    this.evaluationResult,
    this.startedAt,
    this.elapsedDuration = Duration.zero,
    this.errorMessage,
  });

  final WritingActivity? activity;
  final PracticeSession? session;
  final bool isLoading;
  final String currentText;
  final int wordCount;
  final int sentenceCount;
  final int characterCount;
  final WritingLengthStatus lengthStatus;

  // Sentence Builder tokens
  final List<String> availableTokens;
  final List<String> selectedTokens;

  // Guided Writing checklist
  final Set<int> checkedChecklistIndices;

  // Evaluation & Results
  final bool isSubmitted;
  final bool isCompleted;
  final WritingEvaluationResult? evaluationResult;
  final DateTime? startedAt;
  final Duration elapsedDuration;
  final String? errorMessage;

  /// Effective user answer string across all modes (assembled tokens or typed text).
  String get effectiveAnswer {
    if (activity?.mode == WritingMode.sentenceBuilder) {
      return selectedTokens.join(' ');
    }
    return currentText.trim();
  }

  /// Whether the user can submit the current response.
  bool get canSubmit {
    if (activity == null || isSubmitted || isCompleted) return false;

    if (activity!.mode == WritingMode.sentenceBuilder) {
      return selectedTokens.isNotEmpty;
    }

    return currentText.trim().isNotEmpty;
  }

  WritingSessionState copyWith({
    WritingActivity? activity,
    PracticeSession? session,
    bool? isLoading,
    String? currentText,
    int? wordCount,
    int? sentenceCount,
    int? characterCount,
    WritingLengthStatus? lengthStatus,
    List<String>? availableTokens,
    List<String>? selectedTokens,
    Set<int>? checkedChecklistIndices,
    bool? isSubmitted,
    bool? isCompleted,
    WritingEvaluationResult? evaluationResult,
    DateTime? startedAt,
    Duration? elapsedDuration,
    String? errorMessage,
  }) {
    return WritingSessionState(
      activity: activity ?? this.activity,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      currentText: currentText ?? this.currentText,
      wordCount: wordCount ?? this.wordCount,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      characterCount: characterCount ?? this.characterCount,
      lengthStatus: lengthStatus ?? this.lengthStatus,
      availableTokens: availableTokens ?? this.availableTokens,
      selectedTokens: selectedTokens ?? this.selectedTokens,
      checkedChecklistIndices:
          checkedChecklistIndices ?? this.checkedChecklistIndices,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isCompleted: isCompleted ?? this.isCompleted,
      evaluationResult: evaluationResult ?? this.evaluationResult,
      startedAt: startedAt ?? this.startedAt,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller managing writing practice activities, draft persistence, and PracticeRepository saving.
class WritingSessionController extends Notifier<WritingSessionState> {
  @override
  WritingSessionState build() {
    return const WritingSessionState();
  }

  /// Initializes an active writing practice activity.
  Future<void> initializeActivity(
    WritingActivity activity, {
    String? initialDraft,
  }) async {
    state = state.copyWith(
      isLoading: true,
      activity: activity,
      isSubmitted: false,
      isCompleted: false,
      evaluationResult: null,
      startedAt: DateTime.now(),
      elapsedDuration: Duration.zero,
      checkedChecklistIndices: {},
    );

    try {
      final prefs = ref.read(sharedPreferencesProvider);

      // Load draft text if available
      String text = initialDraft ?? '';
      if (text.isEmpty) {
        final savedDraft = prefs.getString(
          '${StorageKeys.writingDraftPrefix}${activity.id}',
        );
        if (savedDraft != null && savedDraft.isNotEmpty) {
          text = savedDraft;
        }
      }

      // Prepare Sentence Builder tokens if applicable
      List<String> availableTokens = [];
      List<String> selectedTokens = [];
      if (activity.mode == WritingMode.sentenceBuilder) {
        if (activity.sentenceParts.isNotEmpty) {
          availableTokens = List<String>.from(activity.sentenceParts);
        } else if (activity.expectedAnswer != null) {
          availableTokens = activity.expectedAnswer!.split(RegExp(r'\s+'));
        }
        // Shuffle tokens for sentence building practice
        availableTokens.shuffle(math.Random());
      }

      final wordCount = WritingScoring.countWords(text);
      final sentenceCount = WritingScoring.countSentences(text);
      final characterCount = text.length;
      final lengthStatus = WritingScoring.checkWordCountRange(
        wordCount: wordCount,
        minWords: activity.minimumWords,
        maxWords: activity.maximumWords,
      );

      final sessionId =
          'writing_session_${DateTime.now().millisecondsSinceEpoch}';
      final practiceActivity = activity.toPracticeActivity();
      final session = PracticeSession(
        id: sessionId,
        skill: PracticeSkill.writing,
        activityIds: [practiceActivity.id],
        level: activity.level,
        startedAt: DateTime.now(),
        durationSeconds: 0,
        status: PracticeSessionStatus.inProgress,
        totalActivities: 1,
        currentActivityIndex: 0,
        score: 0.0,
      );

      state = state.copyWith(
        isLoading: false,
        session: session,
        currentText: text,
        wordCount: wordCount,
        sentenceCount: sentenceCount,
        characterCount: characterCount,
        lengthStatus: lengthStatus,
        availableTokens: availableTokens,
        selectedTokens: selectedTokens,
      );

      // Save unfinished session marker in local storage
      _persistDraftLocally(text, wordCount);
    } catch (e, st) {
      AppLogger.error(
        'Failed to initialize writing activity',
        error: e,
        stackTrace: st,
        tag: 'WritingSession',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to start writing session. Please try again.',
      );
    }
  }

  /// Updates free-form text input and refreshes live metrics & local draft.
  void updateText(String text) {
    if (state.isSubmitted || state.isCompleted) return;

    final activity = state.activity;
    final minWords = activity?.minimumWords ?? 0;
    final maxWords = activity?.maximumWords ?? 0;

    final wordCount = WritingScoring.countWords(text);
    final sentenceCount = WritingScoring.countSentences(text);
    final characterCount = text.length;
    final lengthStatus = WritingScoring.checkWordCountRange(
      wordCount: wordCount,
      minWords: minWords,
      maxWords: maxWords,
    );

    state = state.copyWith(
      currentText: text,
      wordCount: wordCount,
      sentenceCount: sentenceCount,
      characterCount: characterCount,
      lengthStatus: lengthStatus,
    );

    _persistDraftLocally(text, wordCount);
  }

  /// Sentence Builder: moves token from available pool to user sentence strip.
  void tapAvailableToken(int index) {
    if (state.isSubmitted || state.isCompleted) return;
    if (index < 0 || index >= state.availableTokens.length) return;

    final token = state.availableTokens[index];
    final updatedAvailable = List<String>.from(state.availableTokens)
      ..removeAt(index);
    final updatedSelected = List<String>.from(state.selectedTokens)..add(token);

    final assembled = updatedSelected.join(' ');
    final wordCount = updatedSelected.length;

    state = state.copyWith(
      availableTokens: updatedAvailable,
      selectedTokens: updatedSelected,
      currentText: assembled,
      wordCount: wordCount,
      sentenceCount: 1,
      characterCount: assembled.length,
    );
  }

  /// Sentence Builder: returns token from user sentence strip back to available pool.
  void tapSelectedToken(int index) {
    if (state.isSubmitted || state.isCompleted) return;
    if (index < 0 || index >= state.selectedTokens.length) return;

    final token = state.selectedTokens[index];
    final updatedSelected = List<String>.from(state.selectedTokens)
      ..removeAt(index);
    final updatedAvailable = List<String>.from(state.availableTokens)
      ..add(token);

    final assembled = updatedSelected.join(' ');
    final wordCount = updatedSelected.length;

    state = state.copyWith(
      availableTokens: updatedAvailable,
      selectedTokens: updatedSelected,
      currentText: assembled,
      wordCount: wordCount,
      sentenceCount: updatedSelected.isEmpty ? 0 : 1,
      characterCount: assembled.length,
    );
  }

  /// Sentence Builder: resets all tokens back to available pool.
  void resetSentenceBuilder() {
    if (state.isSubmitted || state.isCompleted) return;

    final allTokens = [...state.availableTokens, ...state.selectedTokens];
    allTokens.shuffle(math.Random());

    state = state.copyWith(
      availableTokens: allTokens,
      selectedTokens: const [],
      currentText: '',
      wordCount: 0,
      sentenceCount: 0,
      characterCount: 0,
    );
  }

  /// Guided Writing: toggles checklist requirement item.
  void toggleChecklistItem(int index) {
    final updated = Set<int>.from(state.checkedChecklistIndices);
    if (updated.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }
    state = state.copyWith(checkedChecklistIndices: updated);
  }

  /// Submits the current response and computes evaluation metrics.
  void submitWriting() {
    if (!state.canSubmit || state.isSubmitted || state.isCompleted) return;

    final activity = state.activity;
    if (activity == null) return;

    final evaluator = ref.read(writingEvaluationServiceProvider);
    final evaluation = evaluator.evaluate(
      activity: activity,
      userAnswer: state.effectiveAnswer,
      checkedChecklistIndices: state.checkedChecklistIndices,
    );

    state = state.copyWith(isSubmitted: true, evaluationResult: evaluation);
  }

  /// Finalizes the writing session and saves results to SQLite PracticeRepository.
  Future<void> completeSession() async {
    final activity = state.activity;
    final currentSession = state.session;
    final evaluation = state.evaluationResult;
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

    final finalScore = ((evaluation?.score ?? 1.0) * 100.0).clamp(0.0, 100.0);

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
      elapsedDuration: duration,
    );

    try {
      final practiceRepo = ref.read(practiceRepositoryProvider);
      await practiceRepo.saveSession(completedSession);

      // Clean up local draft markers
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove(StorageKeys.unfinishedWritingSession);
      await prefs.remove('${StorageKeys.writingDraftPrefix}${activity.id}');

      AppLogger.info(
        'Writing practice session completed: ${completedSession.id} '
        '(${finalDurationSec}s, Score: ${finalScore.toStringAsFixed(1)}%, '
        'Words: ${evaluation?.wordCount ?? state.wordCount})',
        tag: 'WritingSession',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to save completed writing session',
        error: e,
        stackTrace: st,
        tag: 'WritingSession',
      );
    }
  }

  /// Exits or abandons the writing session, optionally preserving the draft locally.
  Future<void> abandonSession({bool keepDraft = true}) async {
    final activity = state.activity;
    final currentSession = state.session;
    final prefs = ref.read(sharedPreferencesProvider);

    if (keepDraft && activity != null && state.currentText.isNotEmpty) {
      _persistDraftLocally(state.currentText, state.wordCount);
    } else {
      await prefs.remove(StorageKeys.unfinishedWritingSession);
      if (activity != null) {
        await prefs.remove('${StorageKeys.writingDraftPrefix}${activity.id}');
      }
    }

    if (currentSession != null && !keepDraft) {
      final abandonedSession = currentSession.copyWith(
        status: PracticeSessionStatus.abandoned,
        completedAt: DateTime.now(),
      );
      try {
        final practiceRepo = ref.read(practiceRepositoryProvider);
        await practiceRepo.saveSession(abandonedSession);
      } catch (_) {}
    }
  }

  void _persistDraftLocally(String text, int wordCount) {
    final activity = state.activity;
    if (activity == null) return;

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      // Save specific activity draft
      prefs.setString('${StorageKeys.writingDraftPrefix}${activity.id}', text);

      // Save global unfinished writing draft summary
      final draftData = jsonEncode({
        'activityId': activity.id,
        'draftText': text,
        'wordCount': wordCount,
        'lastSaved': DateTime.now().millisecondsSinceEpoch,
      });
      prefs.setString(StorageKeys.unfinishedWritingSession, draftData);
    } catch (_) {}
  }
}

/// Provider for the writing session controller.
final writingSessionControllerProvider =
    NotifierProvider.autoDispose<WritingSessionController, WritingSessionState>(
      WritingSessionController.new,
    );

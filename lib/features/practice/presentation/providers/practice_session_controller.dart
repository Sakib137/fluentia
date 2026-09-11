import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/practice_repository.dart';
import '../../domain/models/practice_models.dart';
import 'practice_providers.dart';

/// State snapshot for an active practice session runner.
class PracticeSessionState {
  const PracticeSessionState({
    this.session,
    this.activities = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final PracticeSession? session;
  final List<PracticeActivity> activities;
  final bool isLoading;
  final String? errorMessage;

  PracticeActivity? get currentActivity {
    if (session == null || activities.isEmpty) return null;
    final idx = session!.currentActivityIndex.clamp(0, activities.length - 1);
    return activities[idx];
  }

  bool get isLastActivity {
    if (session == null || activities.isEmpty) return true;
    return session!.currentActivityIndex >= activities.length - 1;
  }

  PracticeSessionState copyWith({
    PracticeSession? session,
    List<PracticeActivity>? activities,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PracticeSessionState(
      session: session ?? this.session,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller managing the practice session lifecycle.
class PracticeSessionController extends Notifier<PracticeSessionState> {
  @override
  PracticeSessionState build() {
    return const PracticeSessionState();
  }

  PracticeRepository get _repository => ref.read(practiceRepositoryProvider);

  /// Prepares a new practice session for [skill] and optional [level].
  Future<void> initializeSession({
    required PracticeSkill skill,
    String? level,
    String? specificActivityId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      List<PracticeActivity> selectedActivities = [];

      if (specificActivityId != null) {
        final activity = await _repository.getActivityById(specificActivityId);
        if (activity != null) {
          selectedActivities = [activity];
        }
      }

      if (selectedActivities.isEmpty) {
        final allSkillActivities = await _repository.getActivitiesBySkill(
          skill,
        );
        if (level != null && level.isNotEmpty) {
          final matched = allSkillActivities
              .where((a) => a.level.toUpperCase() == level.toUpperCase())
              .toList();
          selectedActivities = matched.isNotEmpty
              ? matched
              : allSkillActivities;
        } else {
          selectedActivities = allSkillActivities;
        }
      }

      if (selectedActivities.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No practice content found for ${skill.title}.',
        );
        return;
      }

      final sessionId = 'session_${DateTime.now().microsecondsSinceEpoch}';
      final newSession = PracticeSession(
        id: sessionId,
        skill: skill,
        activityIds: selectedActivities.map((a) => a.id).toList(),
        level: level ?? selectedActivities.first.level,
        startedAt: DateTime.now(),
        status: PracticeSessionStatus.notStarted,
        currentActivityIndex: 0,
        totalActivities: selectedActivities.length,
        durationSeconds: 0,
      );

      state = PracticeSessionState(
        session: newSession,
        activities: selectedActivities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize session: $e',
      );
    }
  }

  /// Begins active practice countdown and time tracking.
  void startSession() {
    final current = state.session;
    if (current == null) return;

    final updated = current.copyWith(
      status: PracticeSessionStatus.inProgress,
      startedAt: DateTime.now(),
    );
    state = state.copyWith(session: updated);
  }

  /// Advances to the next drill activity in the session.
  void nextActivity() {
    final current = state.session;
    if (current == null) return;

    if (current.currentActivityIndex < state.activities.length - 1) {
      final updated = current.copyWith(
        currentActivityIndex: current.currentActivityIndex + 1,
      );
      state = state.copyWith(session: updated);
    }
  }

  /// Marks session as completed, computes duration & score, and persists to SQLite.
  Future<PracticeSession?> completeSession({double? score}) async {
    final current = state.session;
    if (current == null) return null;

    final now = DateTime.now();
    final elapsedSec = now.difference(current.startedAt).inSeconds;
    // Ensure duration credits at least the activity estimated duration (minimum 5 minutes or 300 seconds)
    final estimatedSec = state.activities.fold<int>(
      0,
      (acc, a) => acc + (a.estimatedDurationMinutes * 60),
    );
    final durationSeconds = math.max(
      elapsedSec > 0 ? elapsedSec : 300,
      estimatedSec > 0 ? estimatedSec : 300,
    );

    // Calculated baseline score (or default 85.0% for placeholder engine)
    final calculatedScore = score ?? 85.0;

    final completedSession = current.copyWith(
      status: PracticeSessionStatus.completed,
      completedAt: now,
      durationSeconds: durationSeconds,
      score: calculatedScore,
      currentActivityIndex: state.activities.length,
    );

    state = state.copyWith(session: completedSession);
    await _repository.saveSession(completedSession);

    return completedSession;
  }

  /// Abandons current session upon user confirmation.
  Future<void> abandonSession() async {
    final current = state.session;
    if (current == null) return;

    final now = DateTime.now();
    final abandonedSession = current.copyWith(
      status: PracticeSessionStatus.abandoned,
      completedAt: now,
    );

    state = state.copyWith(session: abandonedSession);
    await _repository.saveSession(abandonedSession);
  }

  /// Resets the controller state.
  void reset() {
    state = const PracticeSessionState();
  }
}

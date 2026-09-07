import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/notification_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/onboarding_state_model.dart';
import '../../data/models/placement_question_model.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../domain/scoring/plan_generator.dart';

/// Notifier managing user choices during onboarding, plan generation, and persistence.
class OnboardingNotifier extends Notifier<OnboardingStateModel> {
  @override
  OnboardingStateModel build() {
    _loadInitialState();
    return const OnboardingStateModel();
  }

  OnboardingRepository get _repository => ref.read(onboardingRepositoryProvider);
  NotificationService get _notificationService => ref.read(notificationServiceProvider);

  Future<void> _loadInitialState() async {
    final savedState = await _repository.getOnboardingState();
    state = savedState;
  }

  /// Toggles selection of a learning goal.
  void toggleGoal(String goal) {
    final currentGoals = List<String>.from(state.selectedGoals);
    if (currentGoals.contains(goal)) {
      currentGoals.remove(goal);
    } else {
      currentGoals.add(goal);
    }
    state = state.copyWith(selectedGoals: currentGoals);
    _persistDraft();
  }

  /// Sets user's self-assessed CEFR level or 'not_sure'.
  void setLevel(String level) {
    state = state.copyWith(currentLevel: level);
    _persistDraft();
  }

  /// Sets daily target practice duration in minutes.
  void setDailyMinutes(int minutes) {
    state = state.copyWith(dailyPracticeMinutes: minutes);
    generateAndSetPlan();
    _persistDraft();
  }

  /// Enables or disables daily practice reminders.
  void setRemindersEnabled(bool enabled) {
    state = state.copyWith(remindersEnabled: enabled);
    _persistDraft();
  }

  /// Sets reminder count and automatically populates default sensible time slots.
  void setReminderCount(int count) {
    final newTimes = <ReminderTimeSlot>[];
    if (count == 1) {
      newTimes.add(const ReminderTimeSlot(hour: 20, minute: 0, label: 'Evening Practice'));
    } else if (count == 2) {
      newTimes.add(const ReminderTimeSlot(hour: 8, minute: 30, label: 'Morning Practice'));
      newTimes.add(const ReminderTimeSlot(hour: 20, minute: 0, label: 'Evening Review'));
    } else if (count == 3) {
      newTimes.add(const ReminderTimeSlot(hour: 8, minute: 30, label: 'Morning Kickoff'));
      newTimes.add(const ReminderTimeSlot(hour: 13, minute: 0, label: 'Midday Vocabulary'));
      newTimes.add(const ReminderTimeSlot(hour: 20, minute: 0, label: 'Evening Review'));
    } else {
      newTimes.add(const ReminderTimeSlot(hour: 8, minute: 0, label: 'Morning Drill'));
      newTimes.add(const ReminderTimeSlot(hour: 12, minute: 30, label: 'Lunch Break'));
      newTimes.add(const ReminderTimeSlot(hour: 17, minute: 30, label: 'Commute Session'));
      newTimes.add(const ReminderTimeSlot(hour: 21, minute: 0, label: 'Night Wrap-up'));
    }

    state = state.copyWith(
      reminderCount: count,
      reminderTimes: newTimes,
    );
    _persistDraft();
  }

  /// Updates a specific reminder slot's hour and minute.
  void updateReminderTime(int index, int hour, int minute) {
    if (index < 0 || index >= state.reminderTimes.length) return;
    final updated = List<ReminderTimeSlot>.from(state.reminderTimes);
    updated[index] = updated[index].copyWith(hour: hour, minute: minute);
    state = state.copyWith(reminderTimes: updated);
    _persistDraft();
  }

  /// Adds an extra custom reminder slot.
  void addCustomReminderSlot(int hour, int minute, String label) {
    final updated = List<ReminderTimeSlot>.from(state.reminderTimes)
      ..add(ReminderTimeSlot(hour: hour, minute: minute, label: label));
    state = state.copyWith(
      reminderCount: updated.length,
      reminderTimes: updated,
    );
    _persistDraft();
  }

  /// Removes a custom reminder slot.
  void removeReminderSlot(int index) {
    if (state.reminderTimes.length <= 1) return;
    final updated = List<ReminderTimeSlot>.from(state.reminderTimes)..removeAt(index);
    state = state.copyWith(
      reminderCount: updated.length,
      reminderTimes: updated,
    );
    _persistDraft();
  }

  /// Generates the personalized daily practice breakdown based on goals and minutes.
  void generateAndSetPlan() {
    final plan = PlanGenerator.generatePlan(
      dailyMinutes: state.dailyPracticeMinutes,
      selectedGoals: state.selectedGoals,
    );
    state = state.copyWith(personalizedPlan: plan);
  }

  /// Records placement test results and regenerates plan if appropriate.
  void recordPlacementResult(PlacementResultModel result) {
    final updatedLevel = (state.currentLevel == null || state.currentLevel == 'not_sure')
        ? result.estimatedLevel
        : state.currentLevel;

    state = state.copyWith(
      placementTestCompleted: true,
      placementTestScore: result.correctAnswers,
      estimatedLevel: result.estimatedLevel,
      currentLevel: updatedLevel,
    );
    generateAndSetPlan();
    _persistDraft();
  }

  /// Finalizes onboarding, schedules reminders if enabled, and persists to local database.
  Future<void> completeOnboarding() async {
    generateAndSetPlan();
    final completed = state.copyWith(onboardingCompleted: true);
    state = completed;

    await _repository.completeOnboarding(completed);

    if (state.remindersEnabled) {
      try {
        await _notificationService.initialize();
        await _notificationService.requestPermissions();
        await _notificationService.cancelAll();

        for (int i = 0; i < state.reminderTimes.length; i++) {
          final slot = state.reminderTimes[i];
          await _notificationService.scheduleDailyReminder(
            timeOfDay: TimeOfDay(hour: slot.hour, minute: slot.minute),
            title: 'Fluentia Practice Time',
            body: 'Keep your streak alive! Focused English practice today.',
            notificationId: AppConstants.dailyReminderNotificationId + i,
          );
        }
      } catch (e, st) {
        AppLogger.error(
          'Failed to schedule onboarding notifications',
          error: e,
          stackTrace: st,
          tag: 'OnboardingNotifier',
        );
      }
    }
  }

  void _persistDraft() {
    _repository.saveOnboardingState(state);
  }
}

/// Riverpod provider exposing the [OnboardingNotifier].
final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingStateModel>(OnboardingNotifier.new);

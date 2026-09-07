import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_system.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../data/models/onboarding_state_model.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/daily_goal_step.dart';
import 'widgets/goals_step.dart';
import 'widgets/level_step.dart';
import 'widgets/personalized_plan_step.dart';
import 'widgets/placement_prompt_step.dart';
import 'widgets/reminder_step.dart';
import 'widgets/welcome_step.dart';

/// Central host screen managing the multi-step first-time onboarding flow.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;
  static const int _totalSteps = 7;

  void _goToPage(int page) {
    if (page >= 0 && page < _totalSteps) {
      setState(() => _currentPage = page);
    }
  }

  void _nextPage() {
    _goToPage(_currentPage + 1);
  }

  void _previousPage() {
    _goToPage(_currentPage - 1);
  }

  Future<void> _finishOnboarding() async {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    await notifier.completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _openPlacementTest() async {
    await context.push(AppRoutes.placementTest);
    // If the placement test was completed while away, advance to Personalized Plan step
    final state = ref.read(onboardingNotifierProvider);
    if (state.placementTestCompleted && mounted) {
      _goToPage(6); // Go to PersonalizedPlanStep
    }
  }

  Widget _buildStep(
    int step,
    OnboardingStateModel state,
    OnboardingNotifier notifier,
  ) {
    switch (step) {
      case 0:
        return WelcomeStep(
          onGetStarted: _nextPage,
        );
      case 1:
        return GoalsStep(
          selectedGoals: state.selectedGoals,
          onGoalToggled: notifier.toggleGoal,
          onBack: _previousPage,
          onContinue: _nextPage,
        );
      case 2:
        return LevelStep(
          selectedLevel: state.currentLevel,
          onLevelSelected: notifier.setLevel,
          onBack: _previousPage,
          onContinue: _nextPage,
        );
      case 3:
        return DailyGoalStep(
          selectedMinutes: state.dailyPracticeMinutes,
          onMinutesSelected: notifier.setDailyMinutes,
          onBack: _previousPage,
          onContinue: _nextPage,
        );
      case 4:
        return ReminderStep(
          remindersEnabled: state.remindersEnabled,
          reminderCount: state.reminderCount,
          reminderTimes: state.reminderTimes,
          onRemindersEnabledChanged: notifier.setRemindersEnabled,
          onReminderCountChanged: notifier.setReminderCount,
          onTimeUpdated: notifier.updateReminderTime,
          onAddCustomSlot: notifier.addCustomReminderSlot,
          onRemoveSlot: notifier.removeReminderSlot,
          onBack: _previousPage,
          onContinue: _nextPage,
        );
      case 5:
        return PlacementPromptStep(
          onTakeTest: _openPlacementTest,
          onSkipTest: () {
            notifier.generateAndSetPlan();
            _goToPage(6);
          },
          onBack: _previousPage,
        );
      case 6:
      default:
        return PersonalizedPlanStep(
          dailyMinutes: state.dailyPracticeMinutes,
          plan: state.personalizedPlan.isNotEmpty
              ? state.personalizedPlan
              : {'Speaking': 4, 'Listening': 3, 'Vocabulary': 3, 'Grammar': 2, 'Reading': 3},
          selectedGoals: state.selectedGoals,
          estimatedLevel: state.estimatedLevel ?? state.currentLevel,
          onBack: _previousPage,
          onComplete: _finishOnboarding,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final isDark = context.isDarkMode;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        appBar: _currentPage > 0
            ? AppBar(
                backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  onPressed: _previousPage,
                  tooltip: 'Back',
                ),
                title: Text(
                  'Step $_currentPage of ${_totalSteps - 1}',
                  style: TextStyle(
                    fontSize: AppFontSizes.labelMedium,
                    fontWeight: AppFontWeights.medium,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _currentPage / (_totalSteps - 1),
                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.primary400 : AppColors.primary600,
                    ),
                    minHeight: 3,
                  ),
                ),
              )
            : null,
        body: _buildStep(_currentPage, state, notifier),
      ),
    );
  }
}

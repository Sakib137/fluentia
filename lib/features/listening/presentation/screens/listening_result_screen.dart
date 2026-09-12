import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/listening_mode.dart';
import '../providers/listening_providers.dart';
import '../providers/listening_session_controller.dart';

/// Polished, non-gamified completion screen for listening sessions.
class ListeningResultScreen extends ConsumerWidget {
  const ListeningResultScreen({super.key});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes == 0) {
      return '$seconds sec';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final state = ref.watch(listeningSessionControllerProvider);
    final activity = state.activity;
    final session = state.session;

    final score = session?.score ?? state.scorePercentage;
    final durationSeconds = session?.durationSeconds ?? 180;
    final isSuccess = score >= 75.0;

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Drill Complete',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Top Status Icon & Completion Badge
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? (isSuccess
                            ? AppColors.success900.withValues(alpha: 0.5)
                            : AppColors.primary900.withValues(alpha: 0.5))
                      : (isSuccess ? AppColors.success50 : AppColors.primary50),
                  border: Border.all(
                    color: isSuccess
                        ? (isDark ? AppColors.success700 : AppColors.success300)
                        : (isDark
                              ? AppColors.primary700
                              : AppColors.primary300),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.headphones_rounded,
                    size: 38,
                    color: isSuccess
                        ? (isDark ? AppColors.success400 : AppColors.success600)
                        : (isDark
                              ? AppColors.primary400
                              : AppColors.primary600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title and Level
            Center(
              child: Column(
                children: [
                  Text(
                    activity?.title ?? 'Listening Exercise',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSizes.headlineSmall,
                      fontWeight: AppFontWeights.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activity?.mode.title ?? 'Listening'} • Level ${activity?.level ?? 'B1'}',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      fontWeight: AppFontWeights.medium,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Metrics Grid: Score & Practice Time
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: AppRadii.roundedLg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCURACY',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: AppFontWeights.bold,
                            letterSpacing: 0.8,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${score.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: AppFontSizes.headlineMedium,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.primary300
                                : AppColors.primary700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: AppRadii.roundedLg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LISTENING TIME',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: AppFontWeights.bold,
                            letterSpacing: 0.8,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _formatDuration(durationSeconds),
                          style: TextStyle(
                            fontSize: AppFontSizes.headlineMedium,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Mode-Specific Detail Card (Dictation or Comprehension)
            if (activity?.mode == ListeningMode.dictation &&
                state.dictationResult != null) ...[
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : AppColors.slate50,
                  borderRadius: AppRadii.roundedLg,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DICTATION BREAKDOWN',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.bold,
                        letterSpacing: 0.9,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      state.dictationResult!.summaryText,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.semiBold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Matched ${state.dictationResult!.correctWords.length} words, '
                      'missed ${state.dictationResult!.missingWords.length} words.',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (activity?.mode == ListeningMode.comprehension &&
                activity!.comprehensionQuestions.isNotEmpty) ...[
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : AppColors.slate50,
                  borderRadius: AppRadii.roundedLg,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPREHENSION CHECK',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.bold,
                        letterSpacing: 0.9,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${state.comprehensionResults.values.where((c) => c).length} of ${activity.comprehensionQuestions.length} questions answered correctly.',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.semiBold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Educational Takeaway Card
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: AppRadii.roundedLg,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                    size: AppIconSizes.md,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comprehension Insight',
                          style: TextStyle(
                            fontSize: AppFontSizes.bodyMedium,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSuccess
                              ? 'Excellent ear decoding! Practicing with speed controls (1.25x) can build native conversation confidence.'
                              : 'Listening comprehension takes consistent repetition. Try listening to the passage once more with the transcript opened.',
                          style: TextStyle(
                            fontSize: AppFontSizes.bodySmall,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Actions: Retry, Return to Listening Hub, Go to Home
            PrimaryButton(
              label: 'Back to Listening Hub',
              onPressed: () {
                ref.read(listeningSessionControllerProvider.notifier).reset();
                context.go(AppRoutes.practiceListening);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'Practice Another Drill',
              onPressed: () {
                final all = ref.read(allListeningActivitiesProvider);
                if (activity != null) {
                  final currentIndex = all.indexWhere(
                    (a) => a.id == activity.id,
                  );
                  final nextIndex = (currentIndex + 1) % all.length;
                  final nextActivity = all[nextIndex];
                  ref
                      .read(listeningSessionControllerProvider.notifier)
                      .initializeActivity(nextActivity);
                  context.pushReplacement(
                    '/practice/listening/session?activityId=${nextActivity.id}',
                  );
                } else {
                  context.go(AppRoutes.practiceListening);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

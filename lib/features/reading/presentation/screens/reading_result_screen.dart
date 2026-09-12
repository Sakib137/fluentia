import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/services/reading_scoring.dart';
import '../providers/reading_providers.dart';
import '../providers/reading_session_controller.dart';

/// Screen presenting objective metrics, speed, and feedback following a reading activity.
class ReadingResultScreen extends ConsumerWidget {
  const ReadingResultScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final sessionState = ref.watch(readingSessionControllerProvider);
    final activity = sessionState.activity;

    if (activity == null) {
      return Scaffold(
        appBar: const FluentAppBar(title: 'Practice Results'),
        body: Center(
          child: EmptyState(
            icon: Icons.history_rounded,
            title: 'No Session Found',
            description:
                'Start a reading practice drill to see your performance results.',
            actionLabel: 'Go to Reading Lab',
            onAction: () => context.go('/practice/reading'),
          ),
        ),
      );
    }

    final scorePercentage = sessionState.scorePercentage;
    final correctCount = sessionState.correctCount;
    final totalQuestions = sessionState.totalQuestions;
    final approxWpm = sessionState.approxWpm;
    final duration = sessionState.elapsedDuration;

    final insightText = ReadingScoring.generateImprovementInsight(
      scorePercentage: scorePercentage,
      approxWpm: approxWpm,
      level: activity.level,
    );

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Practice Complete',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // 1. Completion Banner
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.teal900.withValues(alpha: 0.3)
                      : AppColors.teal50,
                  border: Border.all(
                    color: isDark ? AppColors.teal400 : AppColors.teal600,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 38,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Center(
              child: Text(
                'Reading Drill Completed',
                style: TextStyle(
                  fontSize: AppFontSizes.titleMedium,
                  fontWeight: AppFontWeights.bold,
                  letterSpacing: -0.3,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            Center(
              child: Text(
                '${activity.title} • Level ${activity.level}',
                style: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 2. Metrics Summary Grid
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accuracy Score',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${scorePercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: AppFontSizes.titleLarge,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.teal300
                                : AppColors.teal700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$correctCount of $totalQuestions correct',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: AppFontWeights.medium,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppCard(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reading Duration',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            fontSize: AppFontSizes.titleLarge,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${activity.wordCount} words',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: AppFontWeights.medium,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Approximate Reading Speed Card
            AppCard(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.teal900.withValues(alpha: 0.3)
                          : AppColors.teal50,
                      borderRadius: AppRadii.roundedMd,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.speed_rounded,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$approxWpm WPM',
                              style: TextStyle(
                                fontSize: AppFontSizes.titleSmall,
                                fontWeight: AppFontWeights.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '(Approx. reading speed)',
                              style: TextStyle(
                                fontSize: AppFontSizes.caption,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Calculated from passage length and time. Comprehension always takes priority.',
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
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 4. Performance Insight Card
            AppCard(
              padding: AppSpacing.cardPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Practice Insight',
                          style: TextStyle(
                            fontSize: AppFontSizes.bodyMedium,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insightText,
                          style: TextStyle(
                            fontSize: AppFontSizes.bodySmall,
                            height: 1.45,
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
            const SizedBox(height: AppSpacing.xl),

            // 5. Action Buttons
            PrimaryButton(
              label: 'Next Reading',
              onPressed: () {
                final all = ref.read(allReadingActivitiesProvider);
                final currentIndex = all.indexWhere((a) => a.id == activity.id);
                final nextActivity =
                    (currentIndex >= 0 && currentIndex < all.length - 1)
                    ? all[currentIndex + 1]
                    : all.first;

                ref
                    .read(readingSessionControllerProvider.notifier)
                    .initializeActivity(nextActivity);
                context.pushReplacement(
                  '/practice/reading/session?activityId=${nextActivity.id}',
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                ref
                    .read(readingSessionControllerProvider.notifier)
                    .initializeActivity(activity);
                context.pushReplacement(
                  '/practice/reading/session?activityId=${activity.id}',
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
              ),
              child: const Text('Practice Again'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.go('/practice/reading'),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Back to Reading Practice'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../practice/presentation/providers/practice_providers.dart';
import '../../domain/models/speaking_metrics.dart';
import '../../domain/models/speaking_mode.dart';
import '../providers/speaking_providers.dart';
import '../widgets/text_match_diff_view.dart';

/// Screen celebrating speaking practice completion, presenting honest metrics, diff, and recommendations.
class SpeakingResultScreen extends ConsumerWidget {
  const SpeakingResultScreen({super.key});

  Future<void> _handleContinue(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(speakingSessionControllerProvider.notifier);
    await controller.completeSession();

    // Invalidate home & practice history so daily minutes and streaks update immediately
    ref.invalidate(dailyProgressProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(progressSnapshotProvider);
    ref.invalidate(practiceHistoryProvider);

    if (context.mounted) {
      context.go(AppRoutes.practiceSpeaking);
    }
  }

  void _handleTryAgain(BuildContext context, WidgetRef ref) {
    final controller = ref.read(speakingSessionControllerProvider.notifier);
    final activity = ref.read(speakingSessionControllerProvider).activity;
    if (activity != null) {
      controller.retry();
      context.pushReplacement(
        '/practice/speaking/session?activityId=${activity.id}',
      );
    } else {
      context.go(AppRoutes.practiceSpeaking);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final sessionState = ref.watch(speakingSessionControllerProvider);
    final activity = sessionState.activity;
    final metrics = sessionState.metrics;

    if (activity == null || metrics == null) {
      return Scaffold(
        appBar: const FluentAppBar(
          title: 'Speaking Result',
          showBackButton: false,
        ),
        body: Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'No Result Available',
            description:
                'Please complete a speaking exercise from the speaking hub.',
            actionLabel: 'Go to Speaking Hub',
            onAction: () => context.go(AppRoutes.practiceSpeaking),
          ),
        ),
      );
    }

    final isReadAloud = activity.mode == SpeakingMode.readAloud;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleContinue(context, ref);
        }
      },
      child: Scaffold(
        appBar: const FluentAppBar(
          title: 'Speaking Result',
          showBackButton: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    // Celebration Header
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : AppColors.sage50,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.sage700
                                : AppColors.sage200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: AppIconSizes.xl,
                          color: isDark ? AppColors.sage400 : AppColors.sage600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Text(
                        'Speaking Practice Complete ✓',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFontSizes.headlineSmall,
                          fontWeight: AppFontWeights.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Center(
                      child: Text(
                        '${activity.mode.title} • ${activity.title}',
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.medium,
                          color: isDark
                              ? AppColors.primary300
                              : AppColors.primary700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Metrics Row Card
                    _SpeakingMetricsCard(
                      metrics: metrics,
                      isReadAloud: isReadAloud,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Feedback Note Card
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : AppColors.slate100,
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
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: AppIconSizes.sm,
                                color: isDark
                                    ? AppColors.primary300
                                    : AppColors.primary700,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Performance Feedback',
                                style: TextStyle(
                                  fontSize: AppFontSizes.labelMedium,
                                  fontWeight: AppFontWeights.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            metrics.feedbackMessage,
                            style: TextStyle(
                              fontSize: AppFontSizes.bodyMedium,
                              height: 1.45,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Read Aloud Token Comparison Diff OR Free Speaking Transcript
                    if (isReadAloud && activity.expectedText != null)
                      TextMatchDiffView(
                        expectedText: activity.expectedText!,
                        recognizedText: metrics.recognizedTranscript,
                        wordTokens: metrics.wordTokens,
                        matchPercentage: metrics.matchPercentage,
                        missingWords: metrics.missingWords,
                      )
                    else
                      _FreeSpeakingTranscriptCard(
                        transcript: metrics.recognizedTranscript,
                        isDark: isDark,
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // "What to Try Next" Card
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary900.withValues(alpha: 0.4)
                            : AppColors.primary50,
                        borderRadius: AppRadii.roundedLg,
                        border: Border.all(
                          color: isDark
                              ? AppColors.primary800
                              : AppColors.primary200,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: AppIconSizes.md,
                            color: isDark
                                ? AppColors.primary300
                                : AppColors.primary700,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What to try next',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.labelMedium,
                                    fontWeight: AppFontWeights.bold,
                                    color: isDark
                                        ? AppColors.primary300
                                        : AppColors.primary700,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  metrics.nextRecommendation,
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
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),

              // Bottom Actions Bar
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Continue',
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => _handleContinue(context, ref),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryButton(
                      label: 'Try Again',
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => _handleTryAgain(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeakingMetricsCard extends StatelessWidget {
  const _SpeakingMetricsCard({
    required this.metrics,
    required this.isReadAloud,
    required this.isDark,
  });

  final SpeakingMetrics metrics;
  final bool isReadAloud;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Duration',
            value: '${metrics.durationSeconds} sec',
            icon: Icons.timer_outlined,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          _StatItem(
            label: 'Words Heard',
            value: '${metrics.wordCount}',
            icon: Icons.mic_rounded,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          if (isReadAloud && metrics.matchPercentage != null)
            _StatItem(
              label: 'Speech Match',
              value: '${metrics.matchPercentage!.round()}%',
              icon: Icons.check_circle_outline_rounded,
              isDark: isDark,
            )
          else
            _StatItem(
              label: 'Approx. Pace',
              value: '${metrics.wordsPerMinute} wpm',
              icon: Icons.speed_rounded,
              isDark: isDark,
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: AppIconSizes.md,
          color: isDark ? AppColors.primary300 : AppColors.primary700,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.titleMedium,
            fontWeight: AppFontWeights.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.caption,
            color: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _FreeSpeakingTranscriptCard extends StatelessWidget {
  const _FreeSpeakingTranscriptCard({
    required this.transcript,
    required this.isDark,
  });

  final String transcript;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over_rounded,
                size: AppIconSizes.sm,
                color: isDark ? AppColors.primary300 : AppColors.primary700,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Your Recognized Response',
                style: TextStyle(
                  fontSize: AppFontSizes.labelSmall,
                  fontWeight: AppFontWeights.bold,
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            transcript.isNotEmpty ? '"$transcript"' : 'No speech recognized.',
            style: TextStyle(
              fontSize: AppFontSizes.bodyMedium,
              height: 1.5,
              fontStyle: transcript.isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
              color: transcript.isNotEmpty
                  ? (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary)
                  : (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

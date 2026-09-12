import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/writing_mode.dart';
import '../providers/writing_providers.dart';
import '../providers/writing_session_controller.dart';

/// Screen displaying final measurable results for a completed writing practice session.
class WritingResultScreen extends ConsumerWidget {
  const WritingResultScreen({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final state = ref.watch(writingSessionControllerProvider);
    final evaluation = state.evaluationResult;
    final all = ref.watch(allWritingActivitiesProvider);
    final activity =
        state.activity ??
        all.firstWhere((a) => a.id == activityId, orElse: () => all.first);

    final wordCount = evaluation?.wordCount ?? state.wordCount;
    final sentenceCount = evaluation?.sentenceCount ?? state.sentenceCount;
    final elapsed = state.elapsedDuration.inSeconds > 0
        ? state.elapsedDuration
        : Duration(minutes: activity.estimatedDurationMinutes);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final durationLabel = minutes > 0 ? '$minutes m $seconds s' : '$seconds s';

    final isObjective = activity.isObjective;
    final isCorrect = evaluation?.isCorrect ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Summary'),
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Celebratory Top Header Card
            AppCard(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isObjective
                          ? (isCorrect
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.warning.withValues(alpha: 0.15))
                          : (isDark
                                ? AppColors.teal900.withValues(alpha: 0.3)
                                : AppColors.teal50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isObjective
                          ? (isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.refresh_rounded)
                          : Icons.celebration_rounded,
                      color: isObjective
                          ? (isCorrect ? AppColors.success : AppColors.warning)
                          : (isDark ? AppColors.teal300 : AppColors.teal700),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isObjective
                        ? (isCorrect ? 'Well Done!' : 'Practice Complete!')
                        : 'Practice Completed!',
                    style: TextStyle(
                      fontSize: AppFontSizes.titleMedium,
                      fontWeight: AppFontWeights.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    activity.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Honest Measurable Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile(
                        context,
                        isDark,
                        icon: Icons.title_rounded,
                        value: '$wordCount',
                        label: 'Words',
                      ),
                      _buildMetricDivider(isDark),
                      _buildMetricTile(
                        context,
                        isDark,
                        icon: Icons.format_list_numbered_rounded,
                        value: '$sentenceCount',
                        label: 'Sentences',
                      ),
                      _buildMetricDivider(isDark),
                      _buildMetricTile(
                        context,
                        isDark,
                        icon: Icons.timer_outlined,
                        value: durationLabel,
                        label: 'Duration',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Feedback & Improvement Suggestion
            if (evaluation != null) ...[
              SectionHeader(title: 'Feedback & Notes'),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: AppSpacing.cardPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: isDark ? AppColors.teal300 : AppColors.teal700,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Practice Tip',
                            style: TextStyle(
                              fontSize: AppFontSizes.bodySmall,
                              fontWeight: AppFontWeights.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            evaluation.improvementSuggestion,
                            style: TextStyle(
                              fontSize: AppFontSizes.bodySmall,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextSecondary,
                              height: 1.4,
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

            // Your Submitted Response Card
            SectionHeader(title: 'Your Response'),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evaluation?.userAnswer ?? state.effectiveAnswer,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodyMedium,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Expected Answer Card (for objective drills)
            if (isObjective && activity.expectedAnswer != null) ...[
              SectionHeader(title: 'Target Sentence Order'),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: AppSpacing.cardPadding,
                child: Text(
                  activity.expectedAnswer!,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Guided Writing Checklist Recap (if applicable)
            if (activity.mode == WritingMode.guidedWriting &&
                activity.checklist.isNotEmpty) ...[
              SectionHeader(title: 'Checklist Compliance'),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: AppSpacing.cardPadding,
                child: Column(
                  children: List.generate(activity.checklist.length, (index) {
                    final item = activity.checklist[index];
                    final isChecked = state.checkedChecklistIndices.contains(
                      index,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isChecked
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: isChecked
                                ? AppColors.success
                                : (isDark
                                      ? AppColors.slate600
                                      : AppColors.slate400),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: AppFontSizes.bodySmall,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Sample Model Response (if available for open writing)
            if (activity.sampleAnswer != null && !isObjective) ...[
              SectionHeader(title: 'Sample Reference Response'),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.sampleAnswer!,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Action Buttons
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Practice Another',
              onPressed: () {
                context.pushReplacement('/practice/writing');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'Return to Practice Hub',
              onPressed: () {
                context.go('/practice');
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.teal300 : AppColors.teal700,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.titleSmall,
            fontWeight: AppFontWeights.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.caption - 1,
            color: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider(bool isDark) {
    return Container(
      height: 36,
      width: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}

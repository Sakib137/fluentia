import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/listening_activity.dart';
import '../providers/listening_session_controller.dart';

/// Interactive UI for Multi-Question Listening Comprehension passages.
class ComprehensionView extends ConsumerWidget {
  const ComprehensionView({super.key, required this.activity});

  final ListeningActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final state = ref.watch(listeningSessionControllerProvider);
    final controller = ref.read(listeningSessionControllerProvider.notifier);

    final questions = activity.comprehensionQuestions;
    if (questions.isEmpty) {
      return const Center(child: Text('No comprehension questions available.'));
    }

    final currentIdx = state.currentComprehensionIndex.clamp(
      0,
      questions.length - 1,
    );
    final currentQ = questions[currentIdx];
    final isSubmitted = state.isSubmitted;
    final selectedOption = state.comprehensionAnswers[currentQ.id];
    final letters = ['A', 'B', 'C', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Pagination Tracker Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentIdx + 1} of ${questions.length}',
              style: TextStyle(
                fontSize: AppFontSizes.caption,
                fontWeight: AppFontWeights.bold,
                letterSpacing: 0.8,
                color: isDark ? AppColors.primary300 : AppColors.primary700,
              ),
            ),
            Row(
              children: List.generate(questions.length, (idx) {
                final isDone = idx < currentIdx;
                final isCurrent = idx == currentIdx;
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: isCurrent ? 20 : 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (isDark ? AppColors.primary400 : AppColors.primary600)
                        : (isDone
                              ? (isDark
                                    ? AppColors.success400
                                    : AppColors.success600)
                              : (isDark
                                    ? AppColors.slate700
                                    : AppColors.slate300)),
                    borderRadius: AppRadii.roundedFull,
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Current Question Title
        Text(
          currentQ.question,
          style: TextStyle(
            fontSize: AppFontSizes.titleMedium,
            fontWeight: AppFontWeights.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Options List for Current Question
        ...List.generate(currentQ.options.length, (optIdx) {
          final option = currentQ.options[optIdx];
          final letter = optIdx < letters.length
              ? letters[optIdx]
              : '${optIdx + 1}';
          final isSelected = selectedOption == option;
          final isCorrectAnswer =
              currentQ.correctAnswer.toLowerCase() == option.toLowerCase();

          Color cardBg;
          Color borderColor;
          Color textColor;

          if (!isSubmitted) {
            if (isSelected) {
              cardBg = isDark
                  ? AppColors.primary900.withValues(alpha: 0.3)
                  : AppColors.primary50;
              borderColor = isDark
                  ? AppColors.primary400
                  : AppColors.primary600;
              textColor = isDark ? AppColors.primary300 : AppColors.primary800;
            } else {
              cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
              borderColor = isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder;
              textColor = isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary;
            }
          } else {
            if (isCorrectAnswer) {
              cardBg = isDark
                  ? AppColors.success900.withValues(alpha: 0.3)
                  : AppColors.success50;
              borderColor = isDark
                  ? AppColors.success400
                  : AppColors.success600;
              textColor = isDark ? AppColors.success300 : AppColors.success800;
            } else if (isSelected && !isCorrectAnswer) {
              cardBg = isDark
                  ? AppColors.danger900.withValues(alpha: 0.3)
                  : AppColors.danger50;
              borderColor = isDark ? AppColors.danger400 : AppColors.danger600;
              textColor = isDark ? AppColors.danger300 : AppColors.danger800;
            } else {
              cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
              borderColor = isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder;
              textColor = isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSubmitted
                    ? null
                    : () => controller.selectComprehensionOption(
                        currentQ.id,
                        option,
                      ),
                borderRadius: AppRadii.roundedLg,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppRadii.roundedLg,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected || (isSubmitted && isCorrectAnswer)
                              ? borderColor
                              : (isDark
                                    ? AppColors.slate800
                                    : AppColors.slate100),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: AppFontSizes.bodySmall,
                              fontWeight: AppFontWeights.bold,
                              color:
                                  isSelected || (isSubmitted && isCorrectAnswer)
                                  ? Colors.white
                                  : (isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: AppFontSizes.bodyMedium,
                            fontWeight: isSelected
                                ? AppFontWeights.semiBold
                                : AppFontWeights.regular,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (isSubmitted) ...[
                        const SizedBox(width: AppSpacing.xs),
                        if (isCorrectAnswer)
                          Icon(
                            Icons.check_circle_rounded,
                            color: isDark
                                ? AppColors.success400
                                : AppColors.success600,
                            size: 22,
                          )
                        else if (isSelected && !isCorrectAnswer)
                          Icon(
                            Icons.cancel_rounded,
                            color: isDark
                                ? AppColors.danger400
                                : AppColors.danger600,
                            size: 22,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        // Feedback Explanation Banner for Current Question
        if (isSubmitted && currentQ.explanation != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: isDark
                  ? (state.isCorrect
                        ? AppColors.success900.withValues(alpha: 0.2)
                        : AppColors.danger900.withValues(alpha: 0.2))
                  : (state.isCorrect
                        ? AppColors.success50
                        : AppColors.danger50),
              borderRadius: AppRadii.roundedLg,
              border: Border.all(
                color: state.isCorrect
                    ? (isDark ? AppColors.success800 : AppColors.success200)
                    : (isDark ? AppColors.danger800 : AppColors.danger200),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  state.isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: state.isCorrect
                      ? (isDark ? AppColors.success400 : AppColors.success600)
                      : (isDark ? AppColors.danger400 : AppColors.danger600),
                  size: AppIconSizes.md,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isCorrect ? 'Accurate!' : 'Explanation',
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.bold,
                          color: state.isCorrect
                              ? (isDark
                                    ? AppColors.success300
                                    : AppColors.success800)
                              : (isDark
                                    ? AppColors.danger300
                                    : AppColors.danger800),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentQ.explanation!,
                        style: TextStyle(
                          fontSize: AppFontSizes.bodySmall,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

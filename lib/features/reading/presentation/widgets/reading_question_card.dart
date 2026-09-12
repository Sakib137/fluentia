import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/reading_question.dart';
import '../providers/reading_session_controller.dart';

/// Card rendering an interactive reading question (Multiple-Choice, True/False, Main Idea, Vocabulary, Short Answer).
class ReadingQuestionCard extends ConsumerStatefulWidget {
  const ReadingQuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
  });

  final ReadingQuestion question;
  final int questionIndex;
  final int totalQuestions;

  @override
  ConsumerState<ReadingQuestionCard> createState() =>
      _ReadingQuestionCardState();
}

class _ReadingQuestionCardState extends ConsumerState<ReadingQuestionCard> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initial =
        ref
            .read(readingSessionControllerProvider)
            .userAnswers[widget.question.id] ??
        '';
    _textController = TextEditingController(text: initial);
  }

  @override
  void didUpdateWidget(covariant ReadingQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      final text =
          ref
              .read(readingSessionControllerProvider)
              .userAnswers[widget.question.id] ??
          '';
      _textController.text = text;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatQuestionType(ReadingQuestionType type) {
    return switch (type) {
      ReadingQuestionType.multipleChoice => 'Comprehension',
      ReadingQuestionType.mainIdea => 'Main Idea',
      ReadingQuestionType.vocabularyInContext => 'Vocabulary in Context',
      ReadingQuestionType.trueFalse => 'True or False',
      ReadingQuestionType.shortAnswer => 'Short Answer',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = ref.watch(readingSessionControllerProvider);
    final controller = ref.read(readingSessionControllerProvider.notifier);

    final isSubmitted = state.isSubmitted;
    final selectedAnswer = state.userAnswers[widget.question.id];
    final isCorrect = state.questionResults[widget.question.id] ?? false;

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question index + Type Badge
          Row(
            children: [
              Text(
                'Question ${widget.questionIndex + 1} of ${widget.totalQuestions}',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  fontWeight: AppFontWeights.bold,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Text(
                  _formatQuestionType(widget.question.type),
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: AppFontWeights.medium,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Question Prompt
          Text(
            widget.question.question,
            style: TextStyle(
              fontSize: AppFontSizes.titleSmall,
              fontWeight: AppFontWeights.semiBold,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Question Choices by Type
          if (widget.question.type == ReadingQuestionType.trueFalse)
            _buildTrueFalseOptions(
              context,
              controller,
              selectedAnswer,
              isSubmitted,
              isDark,
            )
          else if (widget.question.type == ReadingQuestionType.shortAnswer)
            _buildShortAnswerInput(
              context,
              controller,
              isSubmitted,
              isCorrect,
              isDark,
            )
          else
            _buildMultipleChoiceOptions(
              context,
              controller,
              selectedAnswer,
              isSubmitted,
              isDark,
            ),

          // Post-submission Feedback & Explanation Banner
          if (isSubmitted) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildExplanationBanner(isCorrect, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(
    BuildContext context,
    ReadingSessionController controller,
    String? selectedAnswer,
    bool isSubmitted,
    bool isDark,
  ) {
    return Column(
      children: widget.question.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final option = entry.value;
        final letter = String.fromCharCode(65 + idx); // A, B, C, D...
        final isSelected = selectedAnswer == option;
        final isCorrectOption = option == widget.question.correctAnswer;

        Color cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        Color borderColor = isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;
        Color textColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;

        if (isSelected && !isSubmitted) {
          cardBg = isDark
              ? AppColors.teal900.withValues(alpha: 0.3)
              : AppColors.teal50;
          borderColor = isDark ? AppColors.teal400 : AppColors.teal600;
          textColor = isDark ? AppColors.teal200 : AppColors.teal900;
        } else if (isSubmitted) {
          if (isCorrectOption) {
            cardBg = isDark
                ? AppColors.success900.withValues(alpha: 0.3)
                : AppColors.success50;
            borderColor = isDark ? AppColors.success400 : AppColors.success600;
            textColor = isDark ? AppColors.success300 : AppColors.success800;
          } else if (isSelected && !isCorrectOption) {
            cardBg = isDark
                ? AppColors.danger900.withValues(alpha: 0.3)
                : AppColors.danger50;
            borderColor = isDark ? AppColors.danger400 : AppColors.danger600;
            textColor = isDark ? AppColors.danger300 : AppColors.danger800;
          } else {
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
              onTap: isSubmitted ? null : () => controller.selectOption(option),
              borderRadius: AppRadii.roundedLg,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppRadii.roundedLg,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected || (isSubmitted && isCorrectOption)
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
                                isSelected || (isSubmitted && isCorrectOption)
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
                      if (isCorrectOption)
                        Icon(
                          Icons.check_circle_rounded,
                          color: isDark
                              ? AppColors.success400
                              : AppColors.success600,
                          size: 22,
                        )
                      else if (isSelected && !isCorrectOption)
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
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(
    BuildContext context,
    ReadingSessionController controller,
    String? selectedAnswer,
    bool isSubmitted,
    bool isDark,
  ) {
    final options = ['True', 'False'];

    return Row(
      children: options.map((option) {
        final isSelected = selectedAnswer == option;
        final isCorrectOption = option == widget.question.correctAnswer;

        Color cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        Color borderColor = isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;
        Color textColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;

        if (isSelected && !isSubmitted) {
          cardBg = isDark
              ? AppColors.teal900.withValues(alpha: 0.3)
              : AppColors.teal50;
          borderColor = isDark ? AppColors.teal400 : AppColors.teal600;
          textColor = isDark ? AppColors.teal200 : AppColors.teal900;
        } else if (isSubmitted) {
          if (isCorrectOption) {
            cardBg = isDark
                ? AppColors.success900.withValues(alpha: 0.3)
                : AppColors.success50;
            borderColor = isDark ? AppColors.success400 : AppColors.success600;
            textColor = isDark ? AppColors.success300 : AppColors.success800;
          } else if (isSelected && !isCorrectOption) {
            cardBg = isDark
                ? AppColors.danger900.withValues(alpha: 0.3)
                : AppColors.danger50;
            borderColor = isDark ? AppColors.danger400 : AppColors.danger600;
            textColor = isDark ? AppColors.danger300 : AppColors.danger800;
          }
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSubmitted
                    ? null
                    : () => controller.selectOption(option),
                borderRadius: AppRadii.roundedLg,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppRadii.roundedLg,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        option == 'True'
                            ? Icons.check_circle_outline_rounded
                            : Icons.highlight_off_rounded,
                        color: borderColor,
                        size: 30,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: AppFontSizes.bodyMedium,
                          fontWeight: AppFontWeights.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShortAnswerInput(
    BuildContext context,
    ReadingSessionController controller,
    bool isSubmitted,
    bool isCorrect,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(
              color: isSubmitted
                  ? (isCorrect
                        ? (isDark ? AppColors.success400 : AppColors.success600)
                        : (isDark ? AppColors.danger400 : AppColors.danger600))
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _textController,
            enabled: !isSubmitted,
            style: TextStyle(
              fontSize: AppFontSizes.bodyMedium,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
              contentPadding: AppSpacing.cardPadding,
              border: InputBorder.none,
            ),
            onChanged: (text) => controller.updateShortAnswer(text),
          ),
        ),
        if (isSubmitted && !isCorrect) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Accepted answer: ${widget.question.correctAnswer}',
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              fontWeight: AppFontWeights.medium,
              color: isDark ? AppColors.danger300 : AppColors.danger700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExplanationBanner(bool isCorrect, bool isDark) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? (isCorrect
                  ? AppColors.success900.withValues(alpha: 0.2)
                  : AppColors.danger900.withValues(alpha: 0.2))
            : (isCorrect ? AppColors.success50 : AppColors.danger50),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isCorrect
              ? (isDark ? AppColors.success800 : AppColors.success200)
              : (isDark ? AppColors.danger800 : AppColors.danger200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.lightbulb_rounded : Icons.info_outline_rounded,
            color: isCorrect
                ? (isDark ? AppColors.success300 : AppColors.success700)
                : (isDark ? AppColors.danger300 : AppColors.danger700),
            size: AppIconSizes.md,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Well Done!' : 'Explanation',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.bold,
                    color: isCorrect
                        ? (isDark ? AppColors.success300 : AppColors.success800)
                        : (isDark ? AppColors.danger300 : AppColors.danger800),
                  ),
                ),
                if (widget.question.explanation != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.question.explanation!,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      height: 1.45,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

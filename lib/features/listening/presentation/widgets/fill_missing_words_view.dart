import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/listening_activity.dart';
import '../providers/listening_session_controller.dart';

/// Interactive UI for Fill in the Missing Words listening activities.
class FillMissingWordsView extends ConsumerStatefulWidget {
  const FillMissingWordsView({super.key, required this.activity});

  final ListeningActivity activity;

  @override
  ConsumerState<FillMissingWordsView> createState() =>
      _FillMissingWordsViewState();
}

class _FillMissingWordsViewState extends ConsumerState<FillMissingWordsView> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final missingCount = widget.activity.missingWords.length;
    final savedAnswers = ref
        .read(listeningSessionControllerProvider)
        .missingWordsAnswers;

    for (var i = 0; i < missingCount; i++) {
      _controllers[i] = TextEditingController(text: savedAnswers[i] ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = ref.watch(listeningSessionControllerProvider);
    final controller = ref.read(listeningSessionControllerProvider.notifier);
    final isSubmitted = state.isSubmitted;
    final missingWords = widget.activity.missingWords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sentence Prompt Card with Blanks
        Container(
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
              Text(
                'SENTENCE GAP',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  fontWeight: AppFontWeights.bold,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.primary300 : AppColors.primary700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.activity.question ??
                    'Listen to the audio and fill in the missing word(s).',
                style: TextStyle(
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.medium,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Blank Input Fields
        Text(
          missingWords.length == 1
              ? 'Enter the missing word:'
              : 'Enter the missing words:',
          style: TextStyle(
            fontSize: AppFontSizes.bodyMedium,
            fontWeight: AppFontWeights.semiBold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ...List.generate(missingWords.length, (index) {
          final isBlankCorrect = state.missingWordsResults?[index];
          final expectedWord = missingWords[index];

          Color borderColor;
          if (!isSubmitted) {
            borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
          } else {
            borderColor = isBlankCorrect == true
                ? (isDark ? AppColors.success400 : AppColors.success600)
                : (isDark ? AppColors.danger400 : AppColors.danger600);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (missingWords.length > 1) ...[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.slate800
                              : AppColors.slate200,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: AppFontSizes.caption,
                              fontWeight: AppFontWeights.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: AppRadii.roundedMd,
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          enabled: !isSubmitted,
                          style: TextStyle(
                            fontSize: AppFontSizes.bodyMedium,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Missing word ${index + 1}...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextSecondary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            border: InputBorder.none,
                            suffixIcon: isSubmitted
                                ? Icon(
                                    isBlankCorrect == true
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: isBlankCorrect == true
                                        ? (isDark
                                              ? AppColors.success400
                                              : AppColors.success600)
                                        : (isDark
                                              ? AppColors.danger400
                                              : AppColors.danger600),
                                  )
                                : null,
                          ),
                          onChanged: (text) =>
                              controller.updateMissingWord(index, text),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isSubmitted && isBlankCorrect != true) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Correct answer: $expectedWord',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.success400
                            : AppColors.success700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),

        // Feedback Explanation Banner
        if (isSubmitted && widget.activity.explanation != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate900 : AppColors.slate50,
              borderRadius: AppRadii.roundedLg,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? AppColors.primary300 : AppColors.primary700,
                  size: AppIconSizes.md,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Transcript',
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
                        widget.activity.transcript,
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
        ],
      ],
    );
  }
}

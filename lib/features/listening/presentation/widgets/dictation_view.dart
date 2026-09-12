import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/listening_activity.dart';
import '../../domain/services/listening_scoring.dart';
import '../providers/listening_session_controller.dart';

/// Interactive UI for Dictation activities.
class DictationView extends ConsumerStatefulWidget {
  const DictationView({super.key, required this.activity});

  final ListeningActivity activity;

  @override
  ConsumerState<DictationView> createState() => _DictationViewState();
}

class _DictationViewState extends ConsumerState<DictationView> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(listeningSessionControllerProvider).dictationInput;
    _textController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = ref.watch(listeningSessionControllerProvider);
    final controller = ref.read(listeningSessionControllerProvider.notifier);
    final isSubmitted = state.isSubmitted;
    final dictResult = state.dictationResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction Header
        Text(
          widget.activity.question ?? 'Listen and type what you hear:',
          style: TextStyle(
            fontSize: AppFontSizes.titleSmall,
            fontWeight: AppFontWeights.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Dictation Input Field
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadii.roundedLg,
            border: Border.all(
              color: isSubmitted
                  ? (state.isCorrect
                        ? (isDark ? AppColors.success400 : AppColors.success600)
                        : (isDark ? AppColors.danger400 : AppColors.danger600))
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSubmitted ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: _textController,
            enabled: !isSubmitted,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              fontSize: AppFontSizes.bodyMedium,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Type the sentence here...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
              contentPadding: AppSpacing.cardPadding,
              border: InputBorder.none,
            ),
            onChanged: (text) => controller.updateDictationInput(text),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Measures text comprehension only, not pronunciation.',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Measurable Result Breakdown Card (Post-submission)
        if (isSubmitted && dictResult != null) ...[
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate900 : AppColors.slate50,
              borderRadius: AppRadii.roundedLg,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Metric & Percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Word Match Accuracy',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.bold,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: dictResult.accuracyPercentage >= 80.0
                            ? (isDark
                                  ? AppColors.success900.withValues(alpha: 0.4)
                                  : AppColors.success50)
                            : (isDark
                                  ? AppColors.danger900.withValues(alpha: 0.4)
                                  : AppColors.danger50),
                        borderRadius: AppRadii.roundedFull,
                      ),
                      child: Text(
                        '${dictResult.accuracyPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: AppFontSizes.bodySmall,
                          fontWeight: AppFontWeights.bold,
                          color: dictResult.accuracyPercentage >= 80.0
                              ? (isDark
                                    ? AppColors.success300
                                    : AppColors.success700)
                              : (isDark
                                    ? AppColors.danger300
                                    : AppColors.danger700),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dictResult.summaryText,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Aligned Word Token Visual Breakdown
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: dictResult.wordItems.map((item) {
                    Color tokenBg;
                    Color tokenBorder;
                    Color tokenText;
                    IconData? tokenIcon;

                    switch (item.status) {
                      case DictationWordStatus.correct:
                        tokenBg = isDark
                            ? AppColors.success900.withValues(alpha: 0.35)
                            : AppColors.success50;
                        tokenBorder = isDark
                            ? AppColors.success500
                            : AppColors.success500;
                        tokenText = isDark
                            ? AppColors.success300
                            : AppColors.success800;
                        tokenIcon = Icons.check_rounded;

                      case DictationWordStatus.missing:
                        tokenBg = isDark
                            ? AppColors.warning900.withValues(alpha: 0.3)
                            : AppColors.warning50;
                        tokenBorder = isDark
                            ? AppColors.warning500
                            : AppColors.warning500;
                        tokenText = isDark
                            ? AppColors.warning300
                            : AppColors.warning800;
                        tokenIcon = Icons.remove_rounded;

                      case DictationWordStatus.extra:
                        tokenBg = isDark
                            ? AppColors.danger900.withValues(alpha: 0.3)
                            : AppColors.danger50;
                        tokenBorder = isDark
                            ? AppColors.danger500
                            : AppColors.danger500;
                        tokenText = isDark
                            ? AppColors.danger300
                            : AppColors.danger800;
                        tokenIcon = Icons.close_rounded;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: AppSpacing.xxs + 1,
                      ),
                      decoration: BoxDecoration(
                        color: tokenBg,
                        borderRadius: AppRadii.roundedMd,
                        border: Border.all(color: tokenBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tokenIcon, size: 12, color: tokenText),
                          const SizedBox(width: 3),
                          Text(
                            item.word,
                            style: TextStyle(
                              fontSize: AppFontSizes.bodySmall,
                              fontWeight: AppFontWeights.medium,
                              decoration:
                                  item.status == DictationWordStatus.extra
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: tokenText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Expected Transcript Reference
                const Divider(height: 16),
                Text(
                  'Expected Transcript:',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: AppFontWeights.bold,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  widget.activity.transcript,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodySmall,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Transparency Measurement Note
                Text(
                  dictResult.measurementNote,
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
          ),
        ],
      ],
    );
  }
}

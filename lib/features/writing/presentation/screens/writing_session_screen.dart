import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/writing_mode.dart';
import '../providers/writing_providers.dart';
import '../providers/writing_session_controller.dart';
import '../widgets/guided_checklist_widget.dart';
import '../widgets/sentence_builder_widget.dart';
import '../widgets/writing_editor.dart';

/// Screen managing an active writing practice session (/practice/writing/session).
class WritingSessionScreen extends ConsumerStatefulWidget {
  const WritingSessionScreen({super.key, required this.activityId});

  final String activityId;

  @override
  ConsumerState<WritingSessionScreen> createState() =>
      _WritingSessionScreenState();
}

class _WritingSessionScreenState extends ConsumerState<WritingSessionScreen> {
  late final TextEditingController _textController;
  bool _showHints = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    // Ensure session is initialized if not already active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(writingSessionControllerProvider);
      if (state.activity == null || state.activity!.id != widget.activityId) {
        final all = ref.read(allWritingActivitiesProvider);
        final match = all.where((a) => a.id == widget.activityId);
        if (match.isNotEmpty) {
          ref
              .read(writingSessionControllerProvider.notifier)
              .initializeActivity(match.first);
        }
      } else {
        _textController.text = state.currentText;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(writingSessionControllerProvider);
    if (state.isCompleted) return true;

    final hasDraft =
        state.currentText.trim().isNotEmpty || state.selectedTokens.isNotEmpty;

    if (!hasDraft) {
      await ref
          .read(writingSessionControllerProvider.notifier)
          .abandonSession(keepDraft: false);
      return true;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final isDark = ctx.isDarkMode;
        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
          title: Text(
            'Save your draft?',
            style: TextStyle(
              fontSize: AppFontSizes.titleSmall,
              fontWeight: AppFontWeights.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          content: Text(
            'You have progress in this writing exercise. Would you like to keep your draft to finish later?',
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'discard'),
              child: Text(
                'Discard',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: AppFontWeights.medium,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'keep'),
              child: Text(
                'Keep Writing',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            PrimaryButton(
              label: 'Save & Exit',
              onPressed: () => Navigator.pop(ctx, 'save'),
            ),
          ],
        );
      },
    );

    if (result == 'save') {
      await ref
          .read(writingSessionControllerProvider.notifier)
          .abandonSession(keepDraft: true);
      return true;
    } else if (result == 'discard') {
      await ref
          .read(writingSessionControllerProvider.notifier)
          .abandonSession(keepDraft: false);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = ref.watch(writingSessionControllerProvider);
    final activity = state.activity;

    if (state.isLoading || activity == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.teal300 : AppColors.teal700,
          ),
        ),
      );
    }

    // Sync text controller when draft is loaded
    if (_textController.text != state.currentText &&
        activity.mode != WritingMode.sentenceBuilder) {
      _textController.text = state.currentText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }

    final evaluation = state.evaluationResult;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: TextStyle(
                  fontSize: AppFontSizes.bodyMedium,
                  fontWeight: AppFontWeights.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.teal900 : AppColors.teal50,
                      borderRadius: AppRadii.roundedFull,
                    ),
                    child: Text(
                      activity.level,
                      style: TextStyle(
                        fontSize: AppFontSizes.caption - 2,
                        fontWeight: AppFontWeights.bold,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '•  ${activity.mode.title}',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption - 1,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable practice content
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    // Prompt and Instructions Card
                    AppCard(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (activity.instruction.isNotEmpty) ...[
                            Text(
                              activity.instruction,
                              style: TextStyle(
                                fontSize: AppFontSizes.caption,
                                fontWeight: AppFontWeights.semiBold,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? AppColors.teal300
                                    : AppColors.teal700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                          ],
                          Text(
                            activity.prompt,
                            style: TextStyle(
                              fontSize: AppFontSizes.bodyLarge,
                              fontWeight: AppFontWeights.semiBold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              height: 1.5,
                            ),
                          ),
                          if (activity.context != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Context: ${activity.context!}',
                              style: TextStyle(
                                fontSize: AppFontSizes.bodySmall,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                          if (activity.hints.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showHints = !_showHints;
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_outlined,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.teal300
                                        : AppColors.teal700,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    _showHints ? 'Hide Hints' : 'Show Hints',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.caption,
                                      fontWeight: AppFontWeights.semiBold,
                                      color: isDark
                                          ? AppColors.teal300
                                          : AppColors.teal700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_showHints) ...[
                              const SizedBox(height: AppSpacing.xs),
                              ...activity.hints.map(
                                (h) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.sm,
                                    top: 2,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.teal300
                                              : AppColors.teal700,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          h,
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
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Exercise Input Section (Adapts by Mode)
                    if (activity.mode == WritingMode.sentenceBuilder)
                      SentenceBuilderWidget(
                        selectedTokens: state.selectedTokens,
                        availableTokens: state.availableTokens,
                        onTapAvailableToken: (index) {
                          ref
                              .read(writingSessionControllerProvider.notifier)
                              .tapAvailableToken(index);
                        },
                        onTapSelectedToken: (index) {
                          ref
                              .read(writingSessionControllerProvider.notifier)
                              .tapSelectedToken(index);
                        },
                        onReset: () {
                          ref
                              .read(writingSessionControllerProvider.notifier)
                              .resetSentenceBuilder();
                        },
                        isSubmitted: state.isSubmitted,
                        isCorrect: evaluation?.isCorrect,
                        expectedAnswer: activity.expectedAnswer,
                      )
                    else ...[
                      // Guided Writing Checklist (if applicable)
                      if (activity.mode == WritingMode.guidedWriting &&
                          activity.checklist.isNotEmpty) ...[
                        GuidedChecklistWidget(
                          checklist: activity.checklist,
                          checkedIndices: state.checkedChecklistIndices,
                          onToggleItem: (index) {
                            ref
                                .read(writingSessionControllerProvider.notifier)
                                .toggleChecklistItem(index);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Freeform Writing Editor
                      WritingEditor(
                        controller: _textController,
                        enabled: !state.isSubmitted,
                        minWords: activity.minimumWords,
                        maxWords: activity.maximumWords,
                        wordCount: state.wordCount,
                        sentenceCount: state.sentenceCount,
                        characterCount: state.characterCount,
                        minLines: activity.mode == WritingMode.completeSentence
                            ? 3
                            : (activity.mode == WritingMode.shortWriting
                                  ? 7
                                  : 5),
                        hintText: activity.mode == WritingMode.completeSentence
                            ? 'Complete the sentence with the missing word or phrase...'
                            : 'Write your response clearly...',
                        onChanged: (val) {
                          ref
                              .read(writingSessionControllerProvider.notifier)
                              .updateText(val);
                        },
                      ),
                    ],

                    // Post-submission feedback banner
                    if (state.isSubmitted && evaluation != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: AppRadii.roundedLg,
                          border: Border.all(
                            color: evaluation.isObjective
                                ? (evaluation.isCorrect == true
                                      ? AppColors.success
                                      : AppColors.warning)
                                : AppColors.teal500,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  evaluation.isObjective
                                      ? (evaluation.isCorrect == true
                                            ? Icons.check_circle_rounded
                                            : Icons.info_rounded)
                                      : Icons.fact_check_rounded,
                                  color: evaluation.isObjective
                                      ? (evaluation.isCorrect == true
                                            ? AppColors.success
                                            : AppColors.warning)
                                      : (isDark
                                            ? AppColors.teal300
                                            : AppColors.teal700),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  evaluation.isObjective
                                      ? (evaluation.isCorrect == true
                                            ? 'Correct!'
                                            : 'Needs Adjustment')
                                      : 'Response Feedback',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.bodyMedium,
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
                              evaluation.improvementSuggestion,
                              style: TextStyle(
                                fontSize: AppFontSizes.bodySmall,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextSecondary,
                                height: 1.4,
                              ),
                            ),
                            if (activity.sampleAnswer != null &&
                                !evaluation.isObjective) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Sample Response:',
                                style: TextStyle(
                                  fontSize: AppFontSizes.caption,
                                  fontWeight: AppFontWeights.bold,
                                  color: isDark
                                      ? AppColors.teal300
                                      : AppColors.teal700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activity.sampleAnswer!,
                                style: TextStyle(
                                  fontSize: AppFontSizes.bodySmall,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (!state.isSubmitted) ...[
                      Text(
                        '${state.wordCount} words',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.semiBold,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(
                        label: 'Submit Response',
                        onPressed: state.canSubmit
                            ? () {
                                ref
                                    .read(
                                      writingSessionControllerProvider.notifier,
                                    )
                                    .submitWriting();
                              }
                            : null,
                      ),
                    ] else ...[
                      const Spacer(),
                      PrimaryButton(
                        label: 'View Summary',
                        onPressed: () async {
                          await ref
                              .read(writingSessionControllerProvider.notifier)
                              .completeSession();
                          if (context.mounted) {
                            context.pushReplacement(
                              '/practice/writing/result?activityId=${activity.id}',
                            );
                          }
                        },
                      ),
                    ],
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

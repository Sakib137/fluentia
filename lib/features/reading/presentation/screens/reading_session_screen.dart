import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/reading_activity.dart';
import '../../domain/models/reading_mode.dart';
import '../providers/reading_providers.dart';
import '../providers/reading_session_controller.dart';
import '../widgets/passage_bottom_sheet.dart';
import '../widgets/reading_passage_card.dart';
import '../widgets/reading_question_card.dart';

/// Active reading session screen hosting the passage and interactive comprehension drills.
class ReadingSessionScreen extends ConsumerStatefulWidget {
  const ReadingSessionScreen({
    super.key,
    this.activity,
    this.activityId,
    this.modeId,
  });

  final ReadingActivity? activity;
  final String? activityId;
  final String? modeId;

  @override
  ConsumerState<ReadingSessionScreen> createState() =>
      _ReadingSessionScreenState();
}

class _ReadingSessionScreenState extends ConsumerState<ReadingSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentActivity = ref
          .read(readingSessionControllerProvider)
          .activity;
      if (currentActivity == null ||
          (widget.activity != null &&
              currentActivity.id != widget.activity!.id) ||
          (widget.activityId != null &&
              currentActivity.id != widget.activityId)) {
        final all = ref.read(allReadingActivitiesProvider);
        ReadingActivity? target = widget.activity;

        if (target == null && widget.activityId != null) {
          target = all.cast<ReadingActivity?>().firstWhere(
            (a) => a?.id == widget.activityId,
            orElse: () => null,
          );
        } else if (target == null && widget.modeId != null) {
          final mode = ReadingMode.fromId(widget.modeId!);
          final modeList = all.where((a) => a.mode == mode).toList();
          if (modeList.isNotEmpty) target = modeList.first;
        }

        target ??= all.first;
        ref
            .read(readingSessionControllerProvider.notifier)
            .initializeActivity(target);
      }
    });
  }

  Future<bool> _confirmExit() async {
    final state = ref.read(readingSessionControllerProvider);
    if (state.isCompleted) return true;

    final isDark = context.isDarkMode;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
          title: const Text('Leave Reading Practice?'),
          content: const Text(
            'Your progress will be saved so you can resume this passage later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Stay'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.slate800
                    : AppColors.slate200,
                foregroundColor: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _handleContinue() async {
    final state = ref.read(readingSessionControllerProvider);
    final controller = ref.read(readingSessionControllerProvider.notifier);
    final activity = state.activity;

    if (activity == null) return;

    if (state.currentQuestionIndex < activity.questions.length - 1) {
      controller.nextQuestion();
    } else {
      await controller.completeSession();
      if (mounted) {
        context.pushReplacement('/practice/reading/result');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = ref.watch(readingSessionControllerProvider);
    final controller = ref.read(readingSessionControllerProvider.notifier);
    final activity = state.activity;

    if (state.isLoading || activity == null) {
      return Scaffold(
        appBar: const FluentAppBar(title: 'Reading Session'),
        body: const Center(
          child: LoadingState(message: 'Preparing reading passage...'),
        ),
      );
    }

    final isPassagePhase = state.isPassagePhase;
    final currentQ = state.currentQuestion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _confirmExit();
        if (shouldLeave && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: FluentAppBar(
          title: activity.title,
          subtitle: '${activity.mode.title} • Level ${activity.level}',
          showBackButton: true,
          onBackPressed: () async {
            final shouldLeave = await _confirmExit();
            if (shouldLeave && context.mounted) {
              context.pop();
            }
          },
          actions: [
            // Font size toggle action
            IconButton(
              tooltip: 'Adjust font size',
              icon: const Icon(Icons.format_size_rounded),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) {
                    return Container(
                      padding: AppSpacing.screenPadding,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Passage Text Size',
                              style: TextStyle(
                                fontSize: AppFontSizes.bodyMedium,
                                fontWeight: AppFontWeights.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () =>
                                      controller.decreaseFontSize(),
                                  child: const Text('A - Small'),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                OutlinedButton(
                                  onPressed: () => controller.resetFontSize(),
                                  child: const Text('A Default'),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                OutlinedButton(
                                  onPressed: () =>
                                      controller.increaseFontSize(),
                                  child: const Text('A + Large'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Passage drawer button (when in questions mode)
            if (!isPassagePhase)
              IconButton(
                tooltip: 'View Passage',
                icon: const Icon(Icons.menu_book_rounded),
                onPressed: () =>
                    PassageBottomSheet.show(context, activity: activity),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Linear Progress Bar (when answering questions)
              if (!isPassagePhase && activity.questions.isNotEmpty)
                LinearProgressIndicator(
                  value:
                      (state.currentQuestionIndex + 1) /
                      activity.questions.length,
                  backgroundColor: isDark
                      ? AppColors.slate800
                      : AppColors.slate100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.teal400 : AppColors.teal600,
                  ),
                  minHeight: 3.5,
                ),

              // Main Body Content
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    if (isPassagePhase) ...[
                      // Phase 1: Focused Passage Reading
                      ReadingPassageCard(
                        activity: activity,
                        showActionToQuestions: true,
                        onProceedToQuestions: () {
                          controller.setPassagePhase(false);
                        },
                      ),
                    ] else ...[
                      // Phase 2: Questions Progression
                      if (currentQ != null)
                        ReadingQuestionCard(
                          question: currentQ,
                          questionIndex: state.currentQuestionIndex,
                          totalQuestions: activity.questions.length,
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ),
              ),

              // Bottom Submission & Progression Bar
              if (!isPassagePhase)
                _buildBottomBar(context, state, controller, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ReadingSessionState state,
    ReadingSessionController controller,
    bool isDark,
  ) {
    final activity = state.activity;
    final isSubmitted = state.isSubmitted;
    final canSubmit = state.canSubmit;
    final isLastQuestion =
        activity != null &&
        state.currentQuestionIndex >= activity.questions.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // View Passage Reference Sheet Button
          TextButton.icon(
            onPressed: activity != null
                ? () => PassageBottomSheet.show(context, activity: activity)
                : null,
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: const Text('Passage'),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const Spacer(),

          // Check Answer or Next/Complete Button
          if (!isSubmitted)
            PrimaryButton(
              label: 'Check Answer',
              onPressed: canSubmit ? () => controller.submitAnswer() : null,
            )
          else
            PrimaryButton(
              label: isLastQuestion ? 'Complete Reading' : 'Next Question',
              onPressed: _handleContinue,
            ),
        ],
      ),
    );
  }
}

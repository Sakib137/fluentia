import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/listening_activity.dart';
import '../../domain/models/listening_mode.dart';
import '../providers/listening_providers.dart';
import '../providers/listening_session_controller.dart';
import '../widgets/audio_player_card.dart';
import '../widgets/comprehension_view.dart';
import '../widgets/dictation_view.dart';
import '../widgets/fill_missing_words_view.dart';
import '../widgets/listen_and_choose_view.dart';
import '../widgets/transcript_sheet.dart';
import '../widgets/true_false_view.dart';

/// Active practice drill screen hosting the audio player and interactive mode exercise.
class ListeningSessionScreen extends ConsumerStatefulWidget {
  const ListeningSessionScreen({super.key, this.activityId, this.modeId});

  final String? activityId;
  final String? modeId;

  @override
  ConsumerState<ListeningSessionScreen> createState() =>
      _ListeningSessionScreenState();
}

class _ListeningSessionScreenState
    extends ConsumerState<ListeningSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentActivity = ref
          .read(listeningSessionControllerProvider)
          .activity;
      if (currentActivity == null ||
          (widget.activityId != null &&
              currentActivity.id != widget.activityId)) {
        final all = ref.read(allListeningActivitiesProvider);
        ListeningActivity? target;

        if (widget.activityId != null) {
          target = all.cast<ListeningActivity?>().firstWhere(
            (a) => a?.id == widget.activityId,
            orElse: () => null,
          );
        } else if (widget.modeId != null) {
          final mode = ListeningMode.fromId(widget.modeId!);
          final modeList = all.where((a) => a.mode == mode).toList();
          if (modeList.isNotEmpty) target = modeList.first;
        }

        target ??= all.first;
        ref
            .read(listeningSessionControllerProvider.notifier)
            .initializeActivity(target);
      }
    });
  }

  Future<bool> _confirmExit() async {
    final state = ref.read(listeningSessionControllerProvider);
    if (state.isSubmitted || state.isCompleted) return true;

    final isDark = context.isDarkMode;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
          title: const Text('Leave Practice?'),
          content: const Text(
            'Your current listening drill progress will be saved so you can resume later.',
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
    final state = ref.read(listeningSessionControllerProvider);
    final controller = ref.read(listeningSessionControllerProvider.notifier);
    final activity = state.activity;

    if (activity == null) return;

    // Check if comprehension has more questions
    if (activity.mode == ListeningMode.comprehension &&
        state.currentComprehensionIndex <
            activity.comprehensionQuestions.length - 1) {
      controller.nextComprehensionQuestion();
      return;
    }

    // Otherwise finalize session and navigate to result screen
    await controller.completeSession();
    if (mounted) {
      context.pushReplacement('/practice/listening/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = ref.watch(listeningSessionControllerProvider);
    final controller = ref.read(listeningSessionControllerProvider.notifier);
    final activity = state.activity;

    if (state.isLoading || activity == null) {
      return Scaffold(
        appBar: const FluentAppBar(title: 'Listening Session'),
        body: const Center(child: LoadingState(message: 'Preparing audio...')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _confirmExit();
        if (shouldLeave && context.mounted) {
          ref.read(audioPlayerServiceProvider).stop();
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
              ref.read(audioPlayerServiceProvider).stop();
              context.pop();
            }
          },
          actions: [
            // Transcript action button in app bar
            IconButton(
              tooltip: 'Show transcript',
              icon: const Icon(Icons.subtitles_rounded),
              onPressed: () {
                TranscriptSheet.show(context, transcript: activity.transcript);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    // 1. Audio Player Card
                    AudioPlayerCard(
                      audioAsset: activity.audioAsset,
                      title: 'Listen to the passage',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 2. Interactive Exercise Mode UI
                    switch (activity.mode) {
                      ListeningMode.listenAndChoose => ListenAndChooseView(
                        activity: activity,
                      ),
                      ListeningMode.trueFalse => TrueFalseView(
                        activity: activity,
                      ),
                      ListeningMode.dictation => DictationView(
                        activity: activity,
                      ),
                      ListeningMode.fillMissingWords => FillMissingWordsView(
                        activity: activity,
                      ),
                      ListeningMode.comprehension => ComprehensionView(
                        activity: activity,
                      ),
                    },
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),

              // Bottom Submission & Progression Bar
              _buildBottomBar(context, state, controller, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ListeningSessionState state,
    ListeningSessionController controller,
    bool isDark,
  ) {
    final activity = state.activity;
    final isSubmitted = state.isSubmitted;
    final canSubmit = state.canSubmit;

    final isLastStep =
        activity == null ||
        activity.mode != ListeningMode.comprehension ||
        state.currentComprehensionIndex >=
            activity.comprehensionQuestions.length - 1;

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
          // Optional Transcript Peek Button
          TextButton.icon(
            onPressed: activity != null
                ? () {
                    TranscriptSheet.show(
                      context,
                      transcript: activity.transcript,
                    );
                  }
                : null,
            icon: const Icon(Icons.subtitles_outlined, size: 18),
            label: const Text('Transcript'),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const Spacer(),

          // Check Answer or Continue Button
          if (!isSubmitted)
            PrimaryButton(
              label: 'Check Answer',
              onPressed: canSubmit ? () => controller.submitAnswer() : null,
            )
          else
            PrimaryButton(
              label: isLastStep ? 'Complete Drill' : 'Next Question',
              onPressed: _handleContinue,
            ),
        ],
      ),
    );
  }
}

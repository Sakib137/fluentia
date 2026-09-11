import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/speaking_activity.dart';
import '../../domain/models/speaking_mode.dart';
import '../providers/speaking_providers.dart';
import '../providers/speaking_session_controller.dart';
import '../widgets/leave_speaking_dialog.dart';
import '../widgets/microphone_button.dart';
import '../widgets/speaking_timer_widget.dart';

/// Screen executing the active speaking practice flow.
class SpeakingPracticeScreen extends ConsumerStatefulWidget {
  const SpeakingPracticeScreen({super.key, this.activityId});

  final String? activityId;

  @override
  ConsumerState<SpeakingPracticeScreen> createState() =>
      _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState
    extends ConsumerState<SpeakingPracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureActivityLoaded();
    });
  }

  void _ensureActivityLoaded() {
    final current = ref.read(speakingSessionControllerProvider).activity;
    if (current == null) {
      final all = ref.read(allSpeakingActivitiesProvider);
      SpeakingActivity? target;
      if (widget.activityId != null) {
        target = all.where((a) => a.id == widget.activityId).firstOrNull;
      }
      target ??= all.first;
      ref
          .read(speakingSessionControllerProvider.notifier)
          .initializeActivity(target);
    }
  }

  Future<bool> _handleExitAttempt() async {
    final controller = ref.read(speakingSessionControllerProvider.notifier);
    final state = ref.read(speakingSessionControllerProvider);

    if (state.isListening || state.isPreparing) {
      final shouldLeave = await LeaveSpeakingDialog.show(context);
      if (shouldLeave && mounted) {
        await controller.abandonSession();
        if (mounted) {
          context.pop();
        }
      }
      return false;
    }

    await controller.abandonSession();
    if (mounted) {
      context.pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final sessionState = ref.watch(speakingSessionControllerProvider);
    final activity = sessionState.activity;

    // Auto-navigate to result when complete
    ref.listen(speakingSessionControllerProvider, (prev, next) {
      if (next.isCompleted && next.metrics != null && mounted) {
        context.pushReplacement('/practice/speaking/result');
      }
    });

    if (activity == null) {
      return const Scaffold(
        body: Center(
          child: LoadingState(message: 'Preparing speaking activity...'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleExitAttempt();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Exit practice',
                      onPressed: _handleExitAttempt,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs + 1,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.slate800
                                : AppColors.primary50,
                            borderRadius: AppRadii.roundedFull,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.primary100,
                            ),
                          ),
                          child: Text(
                            activity.mode.title,
                            style: TextStyle(
                              fontSize: AppFontSizes.caption,
                              fontWeight: AppFontWeights.semiBold,
                              color: isDark
                                  ? AppColors.primary300
                                  : AppColors.primary700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs + 1,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.slate800
                                : AppColors.slate100,
                            borderRadius: AppRadii.roundedFull,
                          ),
                          child: Text(
                            activity.level,
                            style: TextStyle(
                              fontSize: AppFontSizes.caption,
                              fontWeight: AppFontWeights.bold,
                              color: isDark
                                  ? AppColors.slate300
                                  : AppColors.slate700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48), // Balance close button
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable Drill Content
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    // Activity Title
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: AppFontSizes.headlineSmall,
                        fontWeight: AppFontWeights.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Instruction Card
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: AppIconSizes.md,
                            color: isDark
                                ? AppColors.primary300
                                : AppColors.primary700,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              activity.instruction,
                              style: TextStyle(
                                fontSize: AppFontSizes.bodyMedium,
                                height: 1.45,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Mode Specific Prompt Area
                    if (activity.mode == SpeakingMode.readAloud)
                      _ReadAloudPromptCard(activity: activity, isDark: isDark)
                    else
                      _FreeSpeakingPromptCard(
                        activity: activity,
                        isDark: isDark,
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // Preparation countdown or Live Recording
                    if (sessionState.isPreparing) ...[
                      _PreparationBanner(
                        remainingSeconds: sessionState.prepRemainingSeconds,
                        isDark: isDark,
                        onSkip: () => ref
                            .read(speakingSessionControllerProvider.notifier)
                            .startSpeaking(),
                      ),
                    ] else ...[
                      // Speaking Timer
                      SpeakingTimerWidget(
                        elapsedSeconds: sessionState.elapsedSeconds,
                        maxSeconds: sessionState.maxSpeakingSeconds,
                        isListening: sessionState.isListening,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Live Speech Transcript Box
                      _TranscriptBox(
                        transcript: sessionState.transcript,
                        isListening: sessionState.isListening,
                        isProcessing: sessionState.isProcessing,
                        isDark: isDark,
                      ),
                    ],

                    // Error or Permission Warning
                    if (sessionState.recordingState.isPermissionDenied) ...[
                      const SizedBox(height: AppSpacing.md),
                      _PermissionDeniedCard(isDark: isDark),
                    ],

                    if (sessionState.recordingState.isUnavailable) ...[
                      const SizedBox(height: AppSpacing.md),
                      _UnavailableCard(isDark: isDark),
                    ],
                  ],
                ),
              ),

              // Bottom Interaction Area
              Padding(
                padding: AppSpacing.screenPadding,
                child: _buildBottomControls(sessionState, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(SpeakingSessionState state, bool isDark) {
    final controller = ref.read(speakingSessionControllerProvider.notifier);

    if (state.recordingState.isPermissionDenied ||
        state.recordingState.isUnavailable) {
      return SecondaryButton(
        label: 'Try Again',
        icon: const Icon(Icons.refresh_rounded),
        onPressed: () => controller.startSpeaking(),
      );
    }

    if (state.isPreparing) {
      return PrimaryButton(
        label: 'Start Speaking Now',
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        onPressed: () => controller.startSpeaking(),
      );
    }

    if (state.recordingState.isIdle) {
      return PrimaryButton(
        label: 'Ready to Speak',
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        onPressed: () => controller.startPreparation(),
      );
    }

    // While recording or processing, show interactive microphone
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MicrophoneButton(
          state: state.recordingState,
          soundLevel: state.soundLevel,
          onTap: () {
            if (state.isListening) {
              controller.stopSpeaking();
            } else if (state.recordingState.isIdle) {
              controller.startSpeaking();
            }
          },
        ),
      ],
    );
  }
}

class _ReadAloudPromptCard extends ConsumerWidget {
  const _ReadAloudPromptCard({required this.activity, required this.isDark});

  final SpeakingActivity activity;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(ttsServiceProvider);

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sentence to Read',
                style: TextStyle(
                  fontSize: AppFontSizes.labelSmall,
                  fontWeight: AppFontWeights.bold,
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                ),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.volume_up_rounded,
                  size: AppIconSizes.sm,
                ),
                label: const Text('Listen'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  if (activity.expectedText != null) {
                    tts.speak(activity.expectedText!);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '"${activity.expectedText ?? activity.prompt}"',
            style: TextStyle(
              fontSize: AppFontSizes.headlineSmall,
              fontWeight: AppFontWeights.bold,
              height: 1.4,
              color: isDark ? AppColors.primary300 : AppColors.primary800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeSpeakingPromptCard extends StatelessWidget {
  const _FreeSpeakingPromptCard({required this.activity, required this.isDark});

  final SpeakingActivity activity;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Speaking Topic',
            style: TextStyle(
              fontSize: AppFontSizes.labelSmall,
              fontWeight: AppFontWeights.bold,
              color: isDark ? AppColors.slate400 : AppColors.slate600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            activity.prompt,
            style: TextStyle(
              fontSize: AppFontSizes.titleLarge,
              fontWeight: AppFontWeights.bold,
              height: 1.35,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          if (activity.starter != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.primary50,
                borderRadius: AppRadii.roundedMd,
              ),
              child: Text(
                'Starter: "${activity.starter}"',
                style: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.primary300 : AppColors.primary700,
                ),
              ),
            ),
          ],
          if (activity.keyPhrases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: activity.keyPhrases.map((phrase) {
                return Chip(
                  label: Text(
                    phrase,
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                    ),
                  ),
                  backgroundColor: isDark
                      ? AppColors.slate800
                      : AppColors.slate100,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreparationBanner extends StatelessWidget {
  const _PreparationBanner({
    required this.remainingSeconds,
    required this.isDark,
    required this.onSkip,
  });

  final int remainingSeconds;
  final bool isDark;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary900.withValues(alpha: 0.4)
            : AppColors.primary50,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isDark ? AppColors.primary800 : AppColors.primary200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.primary900 : AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$remainingSeconds',
              style: TextStyle(
                fontSize: AppFontSizes.titleLarge,
                fontWeight: AppFontWeights.bold,
                color: isDark ? AppColors.primary300 : AppColors.primary700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preparation Time',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Take a moment to collect your thoughts.',
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
    );
  }
}

class _TranscriptBox extends StatelessWidget {
  const _TranscriptBox({
    required this.transcript,
    required this.isListening,
    required this.isProcessing,
    required this.isDark,
  });

  final String transcript;
  final bool isListening;
  final bool isProcessing;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isListening
              ? (isDark ? AppColors.primary400 : AppColors.primary600)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isListening ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Transcript',
                style: TextStyle(
                  fontSize: AppFontSizes.labelSmall,
                  fontWeight: AppFontWeights.bold,
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                ),
              ),
              if (isListening)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Listening...',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        color: isDark ? AppColors.error400 : AppColors.error600,
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                  ],
                )
              else if (isProcessing)
                Text(
                  'Finalizing...',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            transcript.isNotEmpty
                ? transcript
                : (isListening
                      ? 'Start speaking into your microphone...'
                      : 'Your speech will be transcribed here.'),
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

class _PermissionDeniedCard extends StatelessWidget {
  const _PermissionDeniedCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: AppRadii.roundedLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic_off_rounded,
                size: AppIconSizes.md,
                color: isDark ? AppColors.warning400 : AppColors.warning600,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Microphone access is unavailable.',
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
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Fluentia uses your microphone to recognize your speech during speaking practice. You can enable microphone permissions in your system settings or choose non-recording activities.',
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
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: AppRadii.roundedLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.phonelink_erase_rounded,
                size: AppIconSizes.md,
                color: isDark ? AppColors.warning400 : AppColors.warning600,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Speech recognition unavailable',
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
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Speaking recognition isn\'t available on this device yet. You can still use other Fluentia practice modes.',
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
    );
  }
}

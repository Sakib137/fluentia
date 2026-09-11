import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/practice_models.dart';
import '../providers/practice_providers.dart';
import '../widgets/leave_session_dialog.dart';

/// Screen executing an active practice session with progress tracking and back interception.
class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key, required this.skillId});

  final String skillId;

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  late PracticeSkill _skill;

  @override
  void initState() {
    super.initState();
    _skill = PracticeSkill.fromId(widget.skillId);
  }

  Future<bool> _handleExitAttempt() async {
    final shouldLeave = await LeaveSessionDialog.show(context);
    if (shouldLeave && mounted) {
      await ref
          .read(practiceSessionControllerProvider.notifier)
          .abandonSession();
      if (mounted) {
        context.pop();
      }
    }
    return false;
  }

  Future<void> _handleNextOrComplete() async {
    final controller = ref.read(practiceSessionControllerProvider.notifier);
    final sessionState = ref.read(practiceSessionControllerProvider);

    if (sessionState.isLastActivity) {
      await controller.completeSession();
      if (mounted) {
        context.pushReplacement('/practice/${_skill.id}/result');
      }
    } else {
      controller.nextActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final sessionState = ref.watch(practiceSessionControllerProvider);
    final session = sessionState.session;
    final currentActivity = sessionState.currentActivity;

    if (session == null || currentActivity == null) {
      return Scaffold(
        appBar: const FluentAppBar(
          title: 'Practice Session',
          showBackButton: true,
        ),
        body: Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'No Active Session',
            description: 'Please start a session from the practice hub.',
            actionLabel: 'Return to Practice',
            onAction: () => context.pop(),
          ),
        ),
      );
    }

    final currentIndex = session.currentActivityIndex + 1;
    final total = session.totalActivities;
    final progressFraction = total > 0 ? (currentIndex / total) : 0.0;

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
              // Reusable Progress Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Exit practice',
                          onPressed: _handleExitAttempt,
                        ),
                        Text(
                          _skill.title,
                          style: TextStyle(
                            fontSize: AppFontSizes.titleMedium,
                            fontWeight: AppFontWeights.semiBold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Activity $currentIndex of $total',
                          style: TextStyle(
                            fontSize: AppFontSizes.labelMedium,
                            fontWeight: AppFontWeights.medium,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: AppRadii.roundedFull,
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.slate800
                            : AppColors.slate200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.primary400 : AppColors.primary600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Activity Content Area
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    // Type Tag + Difficulty Row
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
                            currentActivity.type.displayName,
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
                            '${currentActivity.level} • ${currentActivity.difficulty}',
                            style: TextStyle(
                              fontSize: AppFontSizes.caption,
                              color: isDark
                                  ? AppColors.slate300
                                  : AppColors.slate700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Activity Title
                    Text(
                      currentActivity.title,
                      style: TextStyle(
                        fontSize: AppFontSizes.headlineSmall,
                        fontWeight: AppFontWeights.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Instruction Banner
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
                              currentActivity.instruction,
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
                    // Drill Content Box
                    _buildContentPayload(currentActivity, isDark),
                    const SizedBox(height: AppSpacing.xl),
                    // Scope Notice Card
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.slate900
                            : AppColors.primary50.withValues(alpha: 0.5),
                        borderRadius: AppRadii.roundedLg,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.primary100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: AppIconSizes.sm,
                                color: isDark
                                    ? AppColors.primary300
                                    : AppColors.primary700,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Practice Engine Prototype',
                                style: TextStyle(
                                  fontSize: AppFontSizes.labelMedium,
                                  fontWeight: AppFontWeights.semiBold,
                                  color: isDark
                                      ? AppColors.primary300
                                      : AppColors.primary700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Activity coming in the next feature implementation. Session flow, timing, and local SQLite persistence are actively functioning.',
                            style: TextStyle(
                              fontSize: AppFontSizes.caption,
                              height: 1.4,
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
              // Action Bottom Bar
              Padding(
                padding: AppSpacing.screenPadding,
                child: PrimaryButton(
                  label: sessionState.isLastActivity
                      ? 'Complete Practice ✓'
                      : 'Next Activity →',
                  icon: Icon(
                    sessionState.isLastActivity
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                  onPressed: _handleNextOrComplete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentPayload(PracticeActivity activity, bool isDark) {
    final content = activity.content;
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
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
          if (content.containsKey('passage')) ...[
            Text(
              'Passage',
              style: TextStyle(
                fontSize: AppFontSizes.labelSmall,
                fontWeight: AppFontWeights.bold,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              content['passage'] as String,
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (content.containsKey('prompt')) ...[
            Text(
              'Prompt',
              style: TextStyle(
                fontSize: AppFontSizes.labelSmall,
                fontWeight: AppFontWeights.bold,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              content['prompt'] as String,
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                height: 1.45,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
          if (content.containsKey('starter')) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sentence Starter: "${content['starter']}"',
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                color: isDark ? AppColors.primary300 : AppColors.primary700,
              ),
            ),
          ],
          if (content.containsKey('audioScript')) ...[
            Text(
              'Transcript Excerpt',
              style: TextStyle(
                fontSize: AppFontSizes.labelSmall,
                fontWeight: AppFontWeights.bold,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"${content['audioScript']}"',
              style: TextStyle(
                fontSize: AppFontSizes.bodyMedium,
                height: 1.45,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

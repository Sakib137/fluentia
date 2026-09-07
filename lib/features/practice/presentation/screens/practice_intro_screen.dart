import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/practice_models.dart';
import '../providers/practice_providers.dart';

/// Screen introducing a practice session before starting exercises.
class PracticeIntroScreen extends ConsumerStatefulWidget {
  const PracticeIntroScreen({
    super.key,
    required this.skillId,
  });

  final String skillId;

  @override
  ConsumerState<PracticeIntroScreen> createState() => _PracticeIntroScreenState();
}

class _PracticeIntroScreenState extends ConsumerState<PracticeIntroScreen> {
  late PracticeSkill _skill;

  @override
  void initState() {
    super.initState();
    _skill = PracticeSkill.fromId(widget.skillId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(practiceSessionControllerProvider.notifier).initializeSession(
            skill: _skill,
          );
    });
  }

  void _startPractice() {
    ref.read(practiceSessionControllerProvider.notifier).startSession();
    context.pushReplacement('/practice/${_skill.id}/session');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final sessionState = ref.watch(practiceSessionControllerProvider);

    return Scaffold(
      appBar: FluentAppBar(
        title: _skill.title,
        subtitle: 'Session Overview',
        showBackButton: true,
      ),
      body: SafeArea(
        child: sessionState.isLoading
            ? const Center(child: LoadingState(message: 'Preparing session...'))
            : sessionState.errorMessage != null
                ? Padding(
                    padding: AppSpacing.screenPadding,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Practice content unavailable',
                        description: sessionState.errorMessage!,
                        actionLabel: 'Back',
                        onAction: () => context.pop(),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: AppSpacing.screenPadding,
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            // Header Icon
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.slate800 : AppColors.primary50,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.primary100,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  _skill.icon,
                                  size: AppIconSizes.xxl,
                                  color: isDark ? AppColors.primary300 : AppColors.primary700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Center(
                              child: Text(
                                _skill.title,
                                style: TextStyle(
                                  fontSize: AppFontSizes.headlineSmall,
                                  fontWeight: AppFontWeights.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                child: Text(
                                  _skill.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.bodyMedium,
                                    height: 1.5,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Badges row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                                    borderRadius: AppRadii.roundedFull,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: AppIconSizes.sm,
                                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        '5 minutes',
                                        style: TextStyle(
                                          fontSize: AppFontSizes.labelMedium,
                                          fontWeight: AppFontWeights.medium,
                                          color: isDark ? AppColors.slate300 : AppColors.slate700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.slate800 : AppColors.primary50,
                                    borderRadius: AppRadii.roundedFull,
                                    border: Border.all(
                                      color: isDark ? AppColors.darkBorder : AppColors.primary100,
                                    ),
                                  ),
                                  child: Text(
                                    _skill.badgeText,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.labelMedium,
                                      fontWeight: AppFontWeights.semiBold,
                                      color: isDark ? AppColors.primary300 : AppColors.primary700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            // Section: You'll complete
                            Text(
                              "You'll complete:",
                              style: TextStyle(
                                fontSize: AppFontSizes.titleMedium,
                                fontWeight: AppFontWeights.semiBold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${sessionState.activities.length} focused activities',
                              style: TextStyle(
                                fontSize: AppFontSizes.bodySmall,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Activity preview list
                            ...sessionState.activities.asMap().entries.map((entry) {
                              final idx = entry.key + 1;
                              final activity = entry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                padding: AppSpacing.cardPadding,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                  borderRadius: AppRadii.roundedLg,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.slate800 : AppColors.primary50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$idx',
                                        style: TextStyle(
                                          fontSize: AppFontSizes.labelSmall,
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
                                            activity.title,
                                            style: TextStyle(
                                              fontSize: AppFontSizes.bodyMedium,
                                              fontWeight: AppFontWeights.semiBold,
                                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xxs),
                                          Text(
                                            activity.type.displayName,
                                            style: TextStyle(
                                              fontSize: AppFontSizes.caption,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${activity.estimatedDurationMinutes}m',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.caption,
                                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      // Bottom CTA bar
                      Padding(
                        padding: AppSpacing.screenPadding,
                        child: PrimaryButton(
                          label: 'Start Practice',
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                          onPressed: _startPractice,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

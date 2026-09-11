import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/speaking_activity.dart';
import '../../domain/models/speaking_mode.dart';
import '../providers/speaking_providers.dart';
import '../widgets/mode_selection_card.dart';

/// Flagship Speaking Hub screen (/practice/speaking).
class SpeakingHubScreen extends ConsumerWidget {
  const SpeakingHubScreen({super.key});

  void _openActivity(
    BuildContext context,
    WidgetRef ref,
    SpeakingActivity activity,
  ) {
    ref
        .read(speakingSessionControllerProvider.notifier)
        .initializeActivity(activity);
    context.push('/practice/speaking/session?activityId=${activity.id}');
  }

  void _showModeActivityPicker(
    BuildContext context,
    WidgetRef ref,
    SpeakingMode mode,
    List<SpeakingActivity> activities,
  ) {
    final isDark = context.isDarkMode;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Modal Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate700 : AppColors.slate300,
                      borderRadius: AppRadii.roundedFull,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        mode.icon,
                        color: isDark
                            ? AppColors.primary300
                            : AppColors.primary700,
                        size: AppIconSizes.md,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        mode.title,
                        style: TextStyle(
                          fontSize: AppFontSizes.titleLarge,
                          fontWeight: AppFontWeights.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: AppSpacing.screenPadding,
                    itemCount: activities.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _openActivity(bottomSheetContext, ref, activity);
                        },
                        borderRadius: AppRadii.roundedLg,
                        child: Container(
                          padding: AppSpacing.cardPadding,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.slate900
                                : AppColors.slate50,
                            borderRadius: AppRadii.roundedLg,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
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
                                  activity.level,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.caption,
                                    fontWeight: AppFontWeights.bold,
                                    color: isDark
                                        ? AppColors.primary300
                                        : AppColors.primary700,
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
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxs),
                                    Text(
                                      activity.expectedText ?? activity.prompt,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                Icons.play_arrow_rounded,
                                color: isDark
                                    ? AppColors.primary300
                                    : AppColors.primary700,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final dailyChallenge = ref.watch(dailySpeakingChallengeProvider);

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Speaking',
        subtitle: 'Practice speaking English with real-world prompts.',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // 1. Today's Speaking Challenge Banner
            _DailySpeakingBanner(
              activity: dailyChallenge,
              isDark: isDark,
              onStart: () => _openActivity(context, ref, dailyChallenge),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Practice Modes Header
            const SectionHeader(
              title: 'Practice Modes',
              subtitle: 'Choose a format to develop targeted speaking skills',
            ),
            const SizedBox(height: AppSpacing.sm),

            // 3. Mode Cards
            ...SpeakingMode.values.map((mode) {
              final modeActivities = ref.watch(
                speakingActivitiesByModeProvider(mode),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ModeSelectionCard(
                  mode: mode,
                  activityCount: modeActivities.length,
                  badge: mode == SpeakingMode.readAloud ? 'Popular' : null,
                  onTap: () {
                    if (modeActivities.isNotEmpty) {
                      _showModeActivityPicker(
                        context,
                        ref,
                        mode,
                        modeActivities,
                      );
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DailySpeakingBanner extends StatelessWidget {
  const _DailySpeakingBanner({
    required this.activity,
    required this.isDark,
    required this.onStart,
  });

  final SpeakingActivity activity;
  final bool isDark;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary900.withValues(alpha: 0.5)
                          : AppColors.primary50,
                      borderRadius: AppRadii.roundedMd,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: AppIconSizes.md,
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "Today's Speaking Challenge",
                    style: TextStyle(
                      fontSize: AppFontSizes.titleMedium,
                      fontWeight: AppFontWeights.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
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
                  '1 minute',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: AppFontWeights.medium,
                    color: isDark ? AppColors.slate300 : AppColors.slate700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"${activity.prompt}"',
            style: TextStyle(
              fontSize: AppFontSizes.bodyMedium,
              fontWeight: AppFontWeights.semiBold,
              color: isDark ? AppColors.primary300 : AppColors.primary700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            activity.instruction,
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Start Challenge',
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

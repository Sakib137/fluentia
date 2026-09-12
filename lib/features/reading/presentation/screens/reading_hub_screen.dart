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
import '../widgets/reading_mode_card.dart';

/// Dedicated Hub screen for Reading practice (/practice/reading).
class ReadingHubScreen extends ConsumerWidget {
  const ReadingHubScreen({super.key});

  void _startActivity(
    BuildContext context,
    WidgetRef ref,
    ReadingActivity activity,
  ) {
    ref
        .read(readingSessionControllerProvider.notifier)
        .initializeActivity(activity);
    context.push('/practice/reading/session?activityId=${activity.id}');
  }

  void _showModeActivityPicker(
    BuildContext context,
    WidgetRef ref,
    ReadingMode mode,
    List<ReadingActivity> activities,
    bool isDark,
  ) {
    final modeActivities = activities.where((a) => a.mode == mode).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.40,
          maxChildSize: 0.90,
          builder: (sheetCtx, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate700 : AppColors.slate300,
                        borderRadius: AppRadii.roundedFull,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          mode.icon,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.title,
                                style: TextStyle(
                                  fontSize: AppFontSizes.titleSmall,
                                  fontWeight: AppFontWeights.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                '${modeActivities.length} practice passages available',
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
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: AppSpacing.screenPadding,
                      itemCount: modeActivities.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (itemCtx, index) {
                        final act = modeActivities[index];
                        return AppCard(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _startActivity(context, ref, act);
                          },
                          padding: AppSpacing.cardPadding,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.teal900.withValues(alpha: 0.3)
                                      : AppColors.teal50,
                                  borderRadius: AppRadii.roundedFull,
                                ),
                                child: Text(
                                  act.level,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.caption,
                                    fontWeight: AppFontWeights.bold,
                                    color: isDark
                                        ? AppColors.teal300
                                        : AppColors.teal700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      act.title,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.bodyMedium,
                                        fontWeight: AppFontWeights.semiBold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${act.category} • ~${act.estimatedDurationMinutes} min • ${act.wordCount} words',
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
                              Icon(
                                Icons.play_circle_fill_rounded,
                                color: isDark
                                    ? AppColors.teal300
                                    : AppColors.teal700,
                                size: 28,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final allActivities = ref.watch(allReadingActivitiesProvider);
    final selectedLevel = ref.watch(selectedReadingLevelFilterProvider);
    final filteredActivities = ref.watch(filteredReadingActivitiesProvider);
    final dailyChallenge = ref.watch(dailyReadingChallengeProvider);
    final unfinishedSession = ref.watch(unfinishedReadingSessionProvider);
    final recommended = ref.watch(recommendedReadingActivityProvider);

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Reading Lab',
        subtitle:
            'Read naturally, expand vocabulary, and master comprehension.',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // 1. Recommended Activity Card
            if (recommended != null) ...[
              AppCard(
                onTap: () => _startActivity(context, ref, recommended),
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.teal900.withValues(alpha: 0.3)
                                : AppColors.teal50,
                            borderRadius: AppRadii.roundedFull,
                          ),
                          child: Text(
                            'RECOMMENDED • LEVEL ${recommended.level}',
                            style: TextStyle(
                              fontSize: AppFontSizes.caption,
                              fontWeight: AppFontWeights.bold,
                              letterSpacing: 0.8,
                              color: isDark
                                  ? AppColors.teal300
                                  : AppColors.teal700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '~${recommended.estimatedDurationMinutes} min',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      recommended.title,
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSmall,
                        fontWeight: AppFontWeights.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${recommended.category} • ${recommended.mode.title} • ${recommended.wordCount} words',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryButton(
                        label: 'Start Recommended',
                        onPressed: () =>
                            _startActivity(context, ref, recommended),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 2. Daily Reading Challenge Banner
            AppCard(
              onTap: () => _startActivity(context, ref, dailyChallenge),
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.teal900.withValues(alpha: 0.3)
                              : AppColors.teal50,
                          borderRadius: AppRadii.roundedFull,
                        ),
                        child: Text(
                          'DAILY READING',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: AppFontWeights.bold,
                            letterSpacing: 0.8,
                            color: isDark
                                ? AppColors.teal300
                                : AppColors.teal700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Level ${dailyChallenge.level}',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.medium,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    dailyChallenge.title,
                    style: TextStyle(
                      fontSize: AppFontSizes.titleSmall,
                      fontWeight: AppFontWeights.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${dailyChallenge.category} • ${dailyChallenge.mode.title} • ~${dailyChallenge.estimatedDurationMinutes} min',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PrimaryButton(
                      label: 'Start Daily Drill',
                      onPressed: () =>
                          _startActivity(context, ref, dailyChallenge),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. Continue Reading Section
            Text(
              'Continue Reading',
              style: TextStyle(
                fontSize: AppFontSizes.titleSmall,
                fontWeight: AppFontWeights.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (unfinishedSession != null)
              AppCard(
                onTap: () => _startActivity(context, ref, unfinishedSession),
                padding: AppSpacing.cardPadding,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.teal900.withValues(alpha: 0.3)
                            : AppColors.teal50,
                        borderRadius: AppRadii.roundedMd,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unfinishedSession.title,
                            style: TextStyle(
                              fontSize: AppFontSizes.bodyMedium,
                              fontWeight: AppFontWeights.semiBold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Level ${unfinishedSession.level} • ${unfinishedSession.mode.title}',
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
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: AppRadii.roundedLg,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'No unfinished sessions',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Level Filter Chips
            Row(
              children: [
                Text(
                  'Reading Modes',
                  style: TextStyle(
                    fontSize: AppFontSizes.titleSmall,
                    fontWeight: AppFontWeights.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Filter Level:',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'A1', 'A2', 'B1', 'B2', 'C1'].map((lvl) {
                  final isSelected =
                      selectedLevel.toUpperCase() == lvl.toUpperCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(lvl),
                      onSelected: (_) {
                        ref
                                .read(
                                  selectedReadingLevelFilterProvider.notifier,
                                )
                                .state =
                            lvl;
                      },
                      selectedColor: isDark
                          ? AppColors.teal900.withValues(alpha: 0.4)
                          : AppColors.teal50,
                      checkmarkColor: isDark
                          ? AppColors.teal300
                          : AppColors.teal700,
                      labelStyle: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: isSelected
                            ? AppFontWeights.bold
                            : AppFontWeights.medium,
                        color: isSelected
                            ? (isDark ? AppColors.teal300 : AppColors.teal700)
                            : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 5. 5 Practice Modes Grid
            ...ReadingMode.values.map((mode) {
              final modeActivities = filteredActivities
                  .where((a) => a.mode == mode)
                  .toList();
              final count = modeActivities.isNotEmpty
                  ? modeActivities.length
                  : allActivities.where((a) => a.mode == mode).length;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ReadingModeCard(
                  mode: mode,
                  activityCount: count,
                  onTap: () => _showModeActivityPicker(
                    context,
                    ref,
                    mode,
                    selectedLevel == 'All' ? allActivities : filteredActivities,
                    isDark,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

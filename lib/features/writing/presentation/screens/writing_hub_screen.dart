import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/models/writing_activity.dart';
import '../../domain/models/writing_mode.dart';
import '../providers/writing_providers.dart';
import '../providers/writing_session_controller.dart';
import '../widgets/writing_mode_card.dart';
import '../widgets/writing_prompt_card.dart';

/// Dedicated Hub screen for Writing practice (/practice/writing).
class WritingHubScreen extends ConsumerWidget {
  const WritingHubScreen({super.key});

  void _startActivity(
    BuildContext context,
    WidgetRef ref,
    WritingActivity activity, {
    String? initialDraft,
  }) {
    ref
        .read(writingSessionControllerProvider.notifier)
        .initializeActivity(activity, initialDraft: initialDraft);
    context.push('/practice/writing/session?activityId=${activity.id}');
  }

  void _showModeActivityPicker(
    BuildContext context,
    WidgetRef ref,
    WritingMode mode,
    List<WritingActivity> activities,
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
                                '${modeActivities.length} practice drills available',
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
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: modeActivities.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final act = modeActivities[index];
                        return AppCard(
                          onTap: () {
                            Navigator.pop(ctx);
                            _startActivity(context, ref, act);
                          },
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs + 2,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.teal900.withValues(alpha: 0.3)
                                      : AppColors.teal50,
                                  borderRadius: AppRadii.roundedSm,
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
                                      '${act.category} • ~${act.estimatedDurationMinutes} min',
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
    final allActivities = ref.watch(allWritingActivitiesProvider);
    final selectedLevel = ref.watch(selectedWritingLevelFilterProvider);
    final filteredActivities = ref.watch(filteredWritingActivitiesProvider);
    final dailyChallenge = ref.watch(dailyWritingChallengeProvider);
    final unfinishedDraft = ref.watch(unfinishedWritingSessionProvider);
    final recommended = ref.watch(recommendedWritingActivityProvider);

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Writing Lab',
        subtitle:
            'Construct natural sentences, build vocabulary, and practice writing.',
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
                      '${recommended.category} • ${recommended.mode.title}${recommended.minimumWords > 0 ? " • Min ${recommended.minimumWords} words" : ""}',
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

            // 2. Daily Writing Challenge Banner
            AppCard(
              onTap: () => _startActivity(context, ref, dailyChallenge),
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.teal900.withValues(alpha: 0.3)
                              : AppColors.teal50,
                          borderRadius: AppRadii.roundedSm,
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          size: AppIconSizes.sm,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'DAILY WRITING CHALLENGE',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.bold,
                          letterSpacing: 0.8,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 2,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.slate800
                              : AppColors.slate100,
                          borderRadius: AppRadii.roundedFull,
                        ),
                        child: Text(
                          dailyChallenge.level,
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
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
                    dailyChallenge.prompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        '~${dailyChallenge.estimatedDurationMinutes} min practice',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(
                        label: 'Start Challenge',
                        onPressed: () =>
                            _startActivity(context, ref, dailyChallenge),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. Continue Writing Card (Draft in Progress)
            if (unfinishedDraft != null) ...[
              AppCard(
                onTap: () => _startActivity(
                  context,
                  ref,
                  unfinishedDraft.activity,
                  initialDraft: unfinishedDraft.draftText,
                ),
                padding: AppSpacing.cardPadding,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.teal900.withValues(alpha: 0.3)
                            : AppColors.teal50,
                        borderRadius: AppRadii.roundedMd,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'CONTINUE WRITING',
                                style: TextStyle(
                                  fontSize: AppFontSizes.caption - 1,
                                  fontWeight: AppFontWeights.bold,
                                  letterSpacing: 0.8,
                                  color: isDark
                                      ? AppColors.teal300
                                      : AppColors.teal700,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: AppRadii.roundedFull,
                                ),
                                child: Text(
                                  'Draft',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.caption - 2,
                                    fontWeight: AppFontWeights.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            unfinishedDraft.activity.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppFontSizes.bodyMedium,
                              fontWeight: AppFontWeights.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '${unfinishedDraft.wordCount} words drafted',
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
                    const SizedBox(width: AppSpacing.sm),
                    SecondaryButton(
                      label: 'Resume',
                      onPressed: () => _startActivity(
                        context,
                        ref,
                        unfinishedDraft.activity,
                        initialDraft: unfinishedDraft.draftText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 4. Practice Modes Section
            SectionHeader(
              title: 'Practice Modes',
              trailingWidget: Text(
                '5 modes',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: WritingMode.values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final mode = WritingMode.values[index];
                  final count = allActivities
                      .where((a) => a.mode == mode)
                      .length;
                  return SizedBox(
                    width: 240,
                    child: WritingModeCard(
                      mode: mode,
                      activityCount: count,
                      onTap: () => _showModeActivityPicker(
                        context,
                        ref,
                        mode,
                        allActivities,
                        isDark,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 5. Level Filter Chips & Activities List
            SectionHeader(
              title: 'All Writing Practice',
              trailingWidget: Text(
                '${filteredActivities.length} available',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Level Filter Chips Row
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
                      labelStyle: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: isSelected
                            ? AppFontWeights.bold
                            : AppFontWeights.medium,
                        color: isSelected
                            ? (isDark ? AppColors.teal200 : AppColors.teal800)
                            : (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextSecondary),
                      ),
                      selectedColor: isDark
                          ? AppColors.teal900.withValues(alpha: 0.4)
                          : AppColors.teal50,
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      side: BorderSide(
                        color: isSelected
                            ? (isDark ? AppColors.teal500 : AppColors.teal600)
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.roundedFull,
                      ),
                      onSelected: (_) {
                        ref
                            .read(selectedWritingLevelFilterProvider.notifier)
                            .setLevel(lvl);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Filtered Exercises List
            if (filteredActivities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: FluentEmptyState(
                  icon: Icons.edit_off_rounded,
                  title: 'No writing activities found',
                  description:
                      'Try selecting a different CEFR level filter above.',
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredActivities.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final activity = filteredActivities[index];
                  return WritingPromptCard(
                    activity: activity,
                    onTap: () => _startActivity(context, ref, activity),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

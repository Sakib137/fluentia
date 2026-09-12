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
import '../widgets/listening_mode_card.dart';

/// Flagship Listening Hub screen (/practice/listening).
class ListeningHubScreen extends ConsumerWidget {
  const ListeningHubScreen({super.key});

  void _openActivity(
    BuildContext context,
    WidgetRef ref,
    ListeningActivity activity,
  ) {
    ref
        .read(listeningSessionControllerProvider.notifier)
        .initializeActivity(activity);
    context.push('/practice/listening/session?activityId=${activity.id}');
  }

  void _showModeActivityPicker(
    BuildContext context,
    WidgetRef ref,
    ListeningMode mode,
    List<ListeningActivity> activities,
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
                                    const SizedBox(height: 2),
                                    Text(
                                      activity.instruction,
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
                                Icons.headphones_rounded,
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
    final dailyActivity = ref.watch(dailyListeningChallengeProvider);
    final continueActivity = ref.watch(continueListeningProvider);

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Listening Lab',
        subtitle: 'Train real native ear comprehension through active drills.',
        showBackButton: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allListeningActivitiesProvider);
            ref.invalidate(dailyListeningChallengeProvider);
            ref.invalidate(continueListeningProvider);
          },
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              // 1. Continue Listening Card (or empty starter state)
              _ContinueListeningSection(
                activity: continueActivity,
                isDark: isDark,
                onResume: continueActivity != null
                    ? () => _openActivity(context, ref, continueActivity)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Today's Daily Listening Challenge Banner
              _DailyListeningBanner(
                activity: dailyActivity,
                isDark: isDark,
                onStart: () => _openActivity(context, ref, dailyActivity),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Core Listening Modes Header
              const SectionHeader(
                title: 'Listening Modes',
                subtitle:
                    'Select a format to target specific comprehension skills',
              ),
              const SizedBox(height: AppSpacing.sm),

              // 4. Mode Cards
              ...ListeningMode.values.map((mode) {
                final modeActivities = ref.watch(
                  listeningActivitiesByModeProvider(mode),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListeningModeCard(
                    mode: mode,
                    activityCount: modeActivities.length,
                    badge: mode == ListeningMode.listenAndChoose
                        ? 'Popular'
                        : (mode == ListeningMode.dictation
                              ? 'Precision'
                              : null),
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
      ),
    );
  }
}

class _ContinueListeningSection extends StatelessWidget {
  const _ContinueListeningSection({
    required this.activity,
    required this.isDark,
    required this.onResume,
  });

  final ListeningActivity? activity;
  final bool isDark;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    if (activity != null) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: AppRadii.roundedXl,
          border: Border.all(
            color: isDark ? AppColors.primary700 : AppColors.primary300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary900.withValues(alpha: 0.5)
                    : AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: isDark ? AppColors.primary300 : AppColors.primary700,
                size: AppIconSizes.lg,
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
                        'CONTINUE LISTENING',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.bold,
                          letterSpacing: 0.9,
                          color: isDark
                              ? AppColors.primary300
                              : AppColors.primary700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '• ${activity!.level}',
                        style: TextStyle(
                          fontSize: AppFontSizes.caption,
                          fontWeight: AppFontWeights.bold,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity!.title,
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
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.primary400
                    : AppColors.primary600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.roundedFull,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
              child: const Text('Resume'),
            ),
          ],
        ),
      );
    }

    // Clean empty/starter state encouraging engagement
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.headphones_outlined,
              size: 22,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No unfinished sessions',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Pick a mode below to start a quick 3-minute listening drill.',
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

class _DailyListeningBanner extends StatelessWidget {
  const _DailyListeningBanner({
    required this.activity,
    required this.isDark,
    required this.onStart,
  });

  final ListeningActivity activity;
  final bool isDark;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary900.withValues(alpha: 0.6),
                  AppColors.slate900,
                ]
              : [
                  AppColors.primary50,
                  AppColors.primary100.withValues(alpha: 0.5),
                ],
        ),
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: isDark ? AppColors.primary700 : AppColors.primary200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary800 : AppColors.primary200,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.primary200
                          : AppColors.primary900,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DAILY LISTENING',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        fontWeight: AppFontWeights.bold,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.primary200
                            : AppColors.primary900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${activity.estimatedDurationMinutes} min drill',
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
            activity.title,
            style: TextStyle(
              fontSize: AppFontSizes.titleMedium,
              fontWeight: AppFontWeights.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            activity.instruction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    activity.mode.icon,
                    size: 14,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activity.mode.title,
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      fontWeight: AppFontWeights.medium,
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '• Level ${activity.level}',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      fontWeight: AppFontWeights.bold,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Start Daily Drill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primary400
                      : AppColors.primary600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.roundedFull,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

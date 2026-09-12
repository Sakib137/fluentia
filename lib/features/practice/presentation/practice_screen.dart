import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/models/practice_models.dart';
import 'providers/practice_providers.dart';

/// Production Practice Hub screen organizing quick practice and core skill modules.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final modules = ref.watch(practiceModulesProvider);
    final quickPracticeAsync = ref.watch(quickPracticeRecommendationProvider);

    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.practiceTitle,
        subtitle: 'Choose a skill and start improving.',
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(practiceModulesProvider);
            ref.invalidate(quickPracticeRecommendationProvider);
            ref.invalidate(practiceHistoryProvider);
          },
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              // 1. Quick Practice Card
              _QuickPracticeCard(
                quickActivityAsync: quickPracticeAsync,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Core Skills Header
              const SectionHeader(
                title: 'Core Skills',
                subtitle: 'Select a competency to begin a 5-minute drill',
              ),
              const SizedBox(height: AppSpacing.sm),

              // 3. Reusable Practice Module Cards
              ...modules.map((module) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: PracticeCard(
                    title: module.title,
                    description: module.description,
                    icon: module.icon,
                    durationMinutes: module.durationMinutes,
                    badge: module.badge,
                    metadata: module.metadata,
                    actionLabel: 'Start Practice',
                    isEnabled: module.isEnabled,
                    onStart: () {
                      if (module.skill == PracticeSkill.speaking) {
                        context.push(AppRoutes.practiceSpeaking);
                      } else if (module.skill == PracticeSkill.listening) {
                        context.push(AppRoutes.practiceListening);
                      } else if (module.skill == PracticeSkill.reading) {
                        context.push(AppRoutes.practiceReading);
                      } else {
                        context.push('/practice/${module.skill.id}/intro');
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

class _QuickPracticeCard extends StatelessWidget {
  const _QuickPracticeCard({
    required this.quickActivityAsync,
    required this.isDark,
  });

  final AsyncValue<dynamic> quickActivityAsync;
  final bool isDark;

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
                          ? AppColors.primary900.withValues(alpha: 0.4)
                          : AppColors.primary50,
                      borderRadius: AppRadii.roundedMd,
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      size: AppIconSizes.md,
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Quick Practice',
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
                  vertical: AppSpacing.xxs + 1,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Text(
                  '5-minute session',
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
          quickActivityAsync.when(
            data: (activity) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended: ${activity.skill.title} • ${activity.title}',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.medium,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
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
                PrimaryButton(
                  label: 'Start Quick Practice',
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                      context.push('/practice/${activity.skill.id}/intro'),
                ),
              ],
            ),
            loading: () => const SizedBox(
              height: 70,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, st) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jump straight into a focused 5-minute daily practice drill.',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodySmall,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Start Quick Practice',
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => context.push('/practice/speaking/intro'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

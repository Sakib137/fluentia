import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/models/home_models.dart';
import '../providers/home_providers.dart';

/// Quick Practice section presenting goal-prioritized skill cards.
class QuickPracticeSection extends ConsumerWidget {
  const QuickPracticeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(quickPracticeRecommendationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(
            title: 'Quick Practice',
            subtitle:
                'Targeted micro-drills adapted to your learning priorities',
            leadingIcon: Icons.bolt_rounded,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 2 columns if width allows, else 1 column
              final isTablet = constraints.maxWidth >= 600;
              if (isTablet) {
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: recommendations.map((item) {
                    return SizedBox(
                      width: (constraints.maxWidth - AppSpacing.md) / 2,
                      child: _QuickPracticeCard(item: item),
                    );
                  }).toList(),
                );
              }

              return Column(
                children: recommendations.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _QuickPracticeCard(item: item),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickPracticeCard extends StatelessWidget {
  const _QuickPracticeCard({required this.item});

  final QuickPracticeItem item;

  IconData _getSkillIcon(String skill) {
    return switch (skill.toLowerCase()) {
      'speaking' => Icons.mic_rounded,
      'listening' => Icons.headphones_rounded,
      'reading' => Icons.menu_book_rounded,
      'writing' => Icons.edit_note_rounded,
      _ => Icons.school_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppCard(
      onTap: () {
        context.go(item.route);
      },
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary900 : AppColors.primary50,
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Icon(
                  _getSkillIcon(item.skillType),
                  size: AppIconSizes.md,
                  color: isDark ? AppColors.primary300 : AppColors.primary600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.skillType,
                          style: TextStyle(
                            fontSize: AppFontSizes.titleSmall,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (item.isPrimaryGoal) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs + 2,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.sage700.withValues(alpha: 0.2)
                                  : AppColors.sage50,
                              borderRadius: AppRadii.roundedFull,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.sage700
                                    : AppColors.sage200,
                              ),
                            ),
                            child: Text(
                              'Goal Focus',
                              style: TextStyle(
                                fontSize: AppFontSizes.caption - 1,
                                fontWeight: AppFontWeights.semiBold,
                                color: isDark
                                    ? AppColors.sage400
                                    : AppColors.sage700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                  borderRadius: AppRadii.roundedXs,
                ),
                child: Text(
                  '${item.estimatedMinutes} min',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: AppFontWeights.medium,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.description,
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Start Practice',
                style: TextStyle(
                  fontSize: AppFontSizes.labelMedium,
                  fontWeight: AppFontWeights.semiBold,
                  color: isDark ? AppColors.primary300 : AppColors.primary600,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.arrow_forward_rounded,
                size: AppIconSizes.xs,
                color: isDark ? AppColors.primary300 : AppColors.primary600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

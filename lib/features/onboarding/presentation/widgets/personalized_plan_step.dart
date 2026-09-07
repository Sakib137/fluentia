import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

/// Step displaying the final generated personalized daily practice curriculum.
class PersonalizedPlanStep extends StatelessWidget {
  const PersonalizedPlanStep({
    super.key,
    required this.dailyMinutes,
    required this.plan,
    required this.selectedGoals,
    required this.estimatedLevel,
    this.onRetakeTest,
    required this.onBack,
    required this.onComplete,
  });

  final int dailyMinutes;
  final Map<String, int> plan;
  final List<String> selectedGoals;
  final String? estimatedLevel;
  final VoidCallback? onRetakeTest;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  IconData _skillIcon(String skill) {
    switch (skill.toLowerCase()) {
      case 'speaking':
        return Icons.record_voice_over_rounded;
      case 'listening':
        return Icons.headphones_rounded;
      case 'vocabulary':
        return Icons.spellcheck_rounded;
      case 'grammar':
        return Icons.rule_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      default:
        return Icons.psychology_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Your daily plan is ready',
                    subtitle: 'Customized based on your goals and assessment',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Daily commitment banner
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primary900.withValues(alpha: 0.4) : AppColors.primary50,
                            borderRadius: AppRadii.roundedLg,
                          ),
                          child: Icon(
                            Icons.timer_outlined,
                            size: AppIconSizes.lg,
                            color: isDark ? AppColors.primary400 : AppColors.primary600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$dailyMinutes Minutes Daily',
                                style: TextStyle(
                                  fontSize: AppFontSizes.titleMedium,
                                  fontWeight: AppFontWeights.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Aligned with your ${estimatedLevel ?? "B1"} starting benchmark',
                                style: TextStyle(
                                  fontSize: AppFontSizes.bodySmall,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Focus Distribution Breakdown
                  Text(
                    'Daily Practice Allocation',
                    style: TextStyle(
                      fontSize: AppFontSizes.titleSmall,
                      fontWeight: AppFontWeights.semiBold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: plan.entries.map((entry) {
                        final skill = entry.key;
                        final minutes = entry.value;
                        final percent = dailyMinutes > 0 ? (minutes / dailyMinutes) : 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                                  borderRadius: AppRadii.roundedSm,
                                ),
                                child: Icon(
                                  _skillIcon(skill),
                                  size: 18,
                                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          skill,
                                          style: TextStyle(
                                            fontSize: AppFontSizes.bodyMedium,
                                            fontWeight: AppFontWeights.medium,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          '$minutes min',
                                          style: TextStyle(
                                            fontSize: AppFontSizes.bodySmall,
                                            fontWeight: AppFontWeights.semiBold,
                                            color: isDark ? AppColors.primary300 : AppColors.primary700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ProgressBar(
                                      value: percent,
                                      height: 6,
                                      color: isDark ? AppColors.primary400 : AppColors.primary600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (onRetakeTest != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton.icon(
                        onPressed: onRetakeTest,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Retake assessment or adjust benchmark'),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppColors.primary400 : AppColors.primary600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  // Offline Guarantee Note
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: AppIconSizes.md,
                          color: isDark ? AppColors.sage400 : AppColors.sage600,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Your study streak starts today. All your lessons and progress are stored 100% offline on your device.',
                            style: TextStyle(
                              fontSize: AppFontSizes.bodySmall,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Persistent Navigation Controls
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                SecondaryButton(
                  label: AppStrings.back,
                  onPressed: onBack,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: 'Start Your Journey',
                    icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                    onPressed: onComplete,
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

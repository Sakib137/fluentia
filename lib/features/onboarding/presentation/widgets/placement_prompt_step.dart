import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

/// Step offering an optional 5-minute placement test before finalizing the plan.
class PlacementPromptStep extends StatelessWidget {
  const PlacementPromptStep({
    super.key,
    required this.onTakeTest,
    required this.onSkipTest,
    required this.onBack,
  });

  final VoidCallback onTakeTest;
  final VoidCallback onSkipTest;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Benchmark your starting ability',
                    subtitle: 'An optional, calm assessment to tailor your initial lessons',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Assessment Feature Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary900.withValues(alpha: 0.4) : AppColors.primary50,
                                borderRadius: AppRadii.roundedMd,
                              ),
                              child: Icon(
                                Icons.quiz_outlined,
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
                                    '12 Practical Questions',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.bodyLarge,
                                      fontWeight: AppFontWeights.semiBold,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Takes about 5 minutes. No time pressure.',
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
                        const SizedBox(height: AppSpacing.lg),
                        _buildFeatureRow(
                          icon: Icons.check_circle_outline_rounded,
                          text: 'Estimates your CEFR proficiency level (A1 – B2)',
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildFeatureRow(
                          icon: Icons.check_circle_outline_rounded,
                          text: 'Pinpoints strengths in vocabulary, grammar, and reading',
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildFeatureRow(
                          icon: Icons.check_circle_outline_rounded,
                          text: 'Calibrates starting difficulty of your daily exercises',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Informative Disclaimer
                  Center(
                    child: Text(
                      'You can always retake this assessment anytime from your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: isDark ? AppColors.slate500 : AppColors.slate400,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: 'Start 5-Minute Assessment',
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  expand: true,
                  onPressed: onTakeTest,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    SecondaryButton(
                      label: AppStrings.back,
                      onPressed: onBack,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Skip to My Plan',
                        isOutlined: true,
                        onPressed: onSkipTest,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSizes.sm,
          color: isDark ? AppColors.sage400 : AppColors.sage600,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

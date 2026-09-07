import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

/// First onboarding step introducing Fluentia's core educational philosophy.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            // Minimalist Brand Emblem
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.primary50,
                borderRadius: AppRadii.roundedLg,
                border: Border.all(
                  color: isDark ? AppColors.primary700 : AppColors.primary200,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: AppIconSizes.xl,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // App Name
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: AppFontSizes.labelLarge,
                fontWeight: AppFontWeights.semiBold,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Primary Headline
            Text(
              'Practice English.\nBuild confidence.\nEvery day.',
              style: TextStyle(
                fontSize: AppFontSizes.displaySmall,
                fontWeight: AppFontWeights.bold,
                height: 1.2,
                letterSpacing: -0.8,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Educational Value Proposition
            Text(
              'Fluentia is your focused offline companion for developing real-world fluency across speaking, listening, reading, writing, vocabulary, and grammar.',
              style: TextStyle(
                fontSize: AppFontSizes.bodyLarge,
                height: 1.5,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Calm Offline Badge Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.sage50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.offline_bolt_rounded,
                      size: AppIconSizes.md,
                      color: isDark ? AppColors.sage400 : AppColors.sage600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Offline by Design',
                          style: TextStyle(
                            fontSize: AppFontSizes.labelLarge,
                            fontWeight: AppFontWeights.semiBold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Zero accounts required. Lessons, word banks, and progress stay on your device.',
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
            const Spacer(flex: 3),
            // Primary CTA
            PrimaryButton(
              label: AppStrings.getStarted,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              expand: true,
              onPressed: onGetStarted,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

class DailyGoalOption {
  const DailyGoalOption({
    required this.minutes,
    required this.label,
    required this.description,
    this.isRecommended = false,
  });

  final int minutes;
  final String label;
  final String description;
  final bool isRecommended;
}

const List<DailyGoalOption> kDailyGoalOptions = [
  DailyGoalOption(
    minutes: 5,
    label: '5 Minutes',
    description: 'Casual pace — Quick review during a short break',
  ),
  DailyGoalOption(
    minutes: 10,
    label: '10 Minutes',
    description: 'Steady pace — One focused skill drill every day',
  ),
  DailyGoalOption(
    minutes: 15,
    label: '15 Minutes',
    description:
        'Optimal balance — Recommended for steady progress without burnout',
    isRecommended: true,
  ),
  DailyGoalOption(
    minutes: 20,
    label: '20 Minutes',
    description: 'Accelerated pace — Multi-skill daily practice',
  ),
  DailyGoalOption(
    minutes: 30,
    label: '30 Minutes',
    description:
        'Intensive pace — Deep daily immersion across speaking & grammar',
  ),
];

/// Step allowing the user to select their daily practice duration commitment.
class DailyGoalStep extends StatelessWidget {
  const DailyGoalStep({
    super.key,
    required this.selectedMinutes,
    required this.onMinutesSelected,
    required this.onBack,
    required this.onContinue,
  });

  final int selectedMinutes;
  final ValueChanged<int> onMinutesSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

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
                    title: 'How much time can you practice each day?',
                    subtitle: 'Consistency matters more than long sessions',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: isDark
                              ? AppColors.warning400
                              : AppColors.warning600,
                          size: AppIconSizes.md,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Just 15 minutes of daily practice produces better long-term retention than a 2-hour weekly cram session.',
                            style: TextStyle(
                              fontSize: AppFontSizes.bodySmall,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...kDailyGoalOptions.map((opt) {
                    final isSelected = selectedMinutes == opt.minutes;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onMinutesSelected(opt.minutes),
                          borderRadius: AppRadii.roundedLg,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.primary900.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.primary50)
                                  : (isDark
                                        ? AppColors.darkSurface
                                        : AppColors.lightSurface),
                              borderRadius: AppRadii.roundedLg,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.primary500
                                          : AppColors.primary600)
                                    : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark
                                              ? AppColors.primary800
                                              : AppColors.primary100)
                                        : (isDark
                                              ? AppColors.slate800
                                              : AppColors.slate100),
                                    borderRadius: AppRadii.roundedMd,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${opt.minutes}m',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.labelLarge,
                                      fontWeight: AppFontWeights.bold,
                                      color: isSelected
                                          ? (isDark
                                                ? AppColors.primary300
                                                : AppColors.primary700)
                                          : (isDark
                                                ? AppColors.slate300
                                                : AppColors.slate700),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            opt.label,
                                            style: TextStyle(
                                              fontSize: AppFontSizes.bodyLarge,
                                              fontWeight:
                                                  AppFontWeights.semiBold,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary,
                                            ),
                                          ),
                                          if (opt.isRecommended) ...[
                                            const SizedBox(
                                              width: AppSpacing.xs,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.sage700
                                                          .withValues(
                                                            alpha: 0.3,
                                                          )
                                                    : AppColors.sage100,
                                                borderRadius:
                                                    AppRadii.roundedSm,
                                              ),
                                              child: Text(
                                                'Recommended',
                                                style: TextStyle(
                                                  fontSize:
                                                      AppFontSizes.labelSmall,
                                                  fontWeight:
                                                      AppFontWeights.semiBold,
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
                                        opt.description,
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
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: AppIconSizes.md,
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.primary400
                                            : AppColors.primary600)
                                      : (isDark
                                            ? AppColors.slate600
                                            : AppColors.slate300),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
                SecondaryButton(label: AppStrings.back, onPressed: onBack),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: AppStrings.continueText,
                    onPressed: onContinue,
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

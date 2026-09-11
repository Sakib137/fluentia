import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

class EnglishLevelOption {
  const EnglishLevelOption({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final String code;
  final String title;
  final String subtitle;
  final String description;
}

const List<EnglishLevelOption> kLevelOptions = [
  EnglishLevelOption(
    code: 'A1',
    title: 'Beginner',
    subtitle: 'CEFR A1',
    description:
        'I know basic words, numbers, and very simple everyday greetings.',
  ),
  EnglishLevelOption(
    code: 'A2',
    title: 'Elementary',
    subtitle: 'CEFR A2',
    description:
        'I can understand simple sentences and communicate in routine tasks.',
  ),
  EnglishLevelOption(
    code: 'B1',
    title: 'Intermediate',
    subtitle: 'CEFR B1',
    description:
        'I can converse comfortably on familiar topics, travel, and personal interests.',
  ),
  EnglishLevelOption(
    code: 'B2',
    title: 'Upper Intermediate',
    subtitle: 'CEFR B2',
    description:
        'I speak fluently with native speakers and understand detailed texts.',
  ),
  EnglishLevelOption(
    code: 'C1',
    title: 'Advanced',
    subtitle: 'CEFR C1',
    description:
        'I express ideas spontaneously and flexibly for academic and professional use.',
  ),
  EnglishLevelOption(
    code: 'not_sure',
    title: 'I\'m not sure',
    subtitle: 'Assessment Recommended',
    description:
        'We will help you gauge your starting level with our quick placement check.',
  ),
];

/// Step allowing the user to self-select their current English level.
class LevelStep extends StatelessWidget {
  const LevelStep({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
    required this.onBack,
    required this.onContinue,
  });

  final String? selectedLevel;
  final ValueChanged<String> onLevelSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final canContinue = selectedLevel != null;

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
                    title: 'How would you describe your English?',
                    subtitle:
                        'Select the level that feels closest to your current experience',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...kLevelOptions.map((opt) {
                    final isSelected = selectedLevel == opt.code;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onLevelSelected(opt.code),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    opt.code == 'not_sure' ? '?' : opt.code,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.titleSmall,
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
                                            opt.title,
                                            style: TextStyle(
                                              fontSize: AppFontSizes.bodyLarge,
                                              fontWeight:
                                                  AppFontWeights.semiBold,
                                              color: isSelected
                                                  ? (isDark
                                                        ? AppColors.primary300
                                                        : AppColors.primary800)
                                                  : (isDark
                                                        ? AppColors
                                                              .darkTextPrimary
                                                        : AppColors
                                                              .lightTextPrimary),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            '• ${opt.subtitle}',
                                            style: TextStyle(
                                              fontSize: AppFontSizes.bodySmall,
                                              color: isDark
                                                  ? AppColors.slate500
                                                  : AppColors.slate400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        opt.description,
                                        style: TextStyle(
                                          fontSize: AppFontSizes.bodySmall,
                                          color: isDark
                                              ? AppColors.darkTextMuted
                                              : AppColors.lightTextSecondary,
                                          height: 1.4,
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
                    onPressed: canContinue ? onContinue : null,
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

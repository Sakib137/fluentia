import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';

class LearningGoalOption {
  const LearningGoalOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

const List<LearningGoalOption> kGoalOptions = [
  LearningGoalOption(
    id: 'Speaking',
    title: 'Speaking',
    description: 'Fluency, voice articulation, and rhythm',
    icon: Icons.record_voice_over_rounded,
  ),
  LearningGoalOption(
    id: 'Listening',
    title: 'Listening',
    description: 'Comprehending native cadence and accents',
    icon: Icons.headphones_rounded,
  ),
  LearningGoalOption(
    id: 'Reading',
    title: 'Reading',
    description: 'Passage comprehension and contextual flow',
    icon: Icons.menu_book_rounded,
  ),
  LearningGoalOption(
    id: 'Writing',
    title: 'Writing',
    description: 'Sentence precision and structured expression',
    icon: Icons.edit_note_rounded,
  ),
  LearningGoalOption(
    id: 'Vocabulary',
    title: 'Vocabulary',
    description: 'High-frequency idioms and active word banks',
    icon: Icons.spellcheck_rounded,
  ),
  LearningGoalOption(
    id: 'Grammar',
    title: 'Grammar',
    description: 'Core rules, tenses, and structural clarity',
    icon: Icons.rule_rounded,
  ),
  LearningGoalOption(
    id: 'Pronunciation',
    title: 'Pronunciation',
    description: 'Phonetics, accent reduction, and stress patterns',
    icon: Icons.graphic_eq_rounded,
  ),
  LearningGoalOption(
    id: 'Interview English',
    title: 'Interview English',
    description: 'Professional answers, poise, and workplace communication',
    icon: Icons.work_outline_rounded,
  ),
  LearningGoalOption(
    id: 'Academic English',
    title: 'Academic English',
    description: 'Formal essays, scientific vocabulary, and research syntax',
    icon: Icons.school_outlined,
  ),
  LearningGoalOption(
    id: 'Everyday Conversation',
    title: 'Everyday Conversation',
    description: 'Spontaneous dialogue, slang, and social confidence',
    icon: Icons.chat_bubble_outline_rounded,
  ),
];

/// Step allowing user to select one or more learning goals.
class GoalsStep extends StatelessWidget {
  const GoalsStep({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggled,
    required this.onBack,
    required this.onContinue,
  });

  final List<String> selectedGoals;
  final ValueChanged<String> onGoalToggled;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final canContinue = selectedGoals.isNotEmpty;

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
                    title: 'What would you like to improve?',
                    subtitle: 'Select all areas you want Fluentia to personalize for you',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (selectedGoals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        'Please select at least one learning goal to continue.',
                        style: TextStyle(
                          fontSize: AppFontSizes.bodySmall,
                          color: isDark ? AppColors.warning400 : AppColors.warning600,
                          fontWeight: AppFontWeights.medium,
                        ),
                      ),
                    ),
                  ...kGoalOptions.map((goal) {
                    final isSelected = selectedGoals.contains(goal.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onGoalToggled(goal.id),
                          borderRadius: AppRadii.roundedLg,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.primary900.withValues(alpha: 0.3) : AppColors.primary50)
                                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                              borderRadius: AppRadii.roundedLg,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppColors.primary500 : AppColors.primary600)
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? AppColors.primary800 : AppColors.primary100)
                                        : (isDark ? AppColors.slate800 : AppColors.slate100),
                                    borderRadius: AppRadii.roundedMd,
                                  ),
                                  child: Icon(
                                    goal.icon,
                                    size: AppIconSizes.md,
                                    color: isSelected
                                        ? (isDark ? AppColors.primary300 : AppColors.primary700)
                                        : (isDark ? AppColors.slate400 : AppColors.slate600),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.title,
                                        style: TextStyle(
                                          fontSize: AppFontSizes.bodyLarge,
                                          fontWeight: AppFontWeights.semiBold,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        goal.description,
                                        style: TextStyle(
                                          fontSize: AppFontSizes.bodySmall,
                                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                        : Colors.transparent,
                                    borderRadius: AppRadii.roundedSm,
                                    border: Border.all(
                                      color: isSelected
                                          ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                          : (isDark ? AppColors.slate600 : AppColors.slate300),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: isDark ? AppColors.slate950 : AppColors.white,
                                        )
                                      : null,
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
                SecondaryButton(
                  label: AppStrings.back,
                  onPressed: onBack,
                ),
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

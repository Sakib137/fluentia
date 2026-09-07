import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/onboarding_provider.dart';
import '../providers/placement_test_provider.dart';

/// Interactive placement test screen estimating initial CEFR English proficiency.
class PlacementTestScreen extends ConsumerWidget {
  const PlacementTestScreen({super.key});

  void _safeExit(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Placement Test?'),
        content: const Text(
          'Your progress on this assessment will not be saved. You can always retake the test later from your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continue Test'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.coral500,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placementTestProvider);
    final notifier = ref.read(placementTestProvider.notifier);
    final isDark = context.isDarkMode;

    return PopScope(
      canPop: state.isSubmitted,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context);
        if (shouldExit && context.mounted) {
          _safeExit(context);
        }
      },
      child: Scaffold(
        appBar: FluentAppBar(
          title: state.isSubmitted ? 'Assessment Complete' : 'English Placement Test',
          subtitle: state.isSubmitted
              ? 'Your estimated proficiency baseline'
              : 'Question ${state.currentIndex + 1} of ${state.questions.length}',
          showBackButton: true,
          onBackPressed: () async {
            if (state.isSubmitted) {
              _safeExit(context);
            } else {
              final shouldExit = await _confirmExit(context);
              if (shouldExit && context.mounted) {
                _safeExit(context);
              }
            }
          },
        ),
        body: state.isSubmitted
            ? _buildResultView(context, ref, state, isDark)
            : _buildQuestionView(context, state, notifier, isDark),
      ),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    PlacementTestState state,
    PlacementTestNotifier notifier,
    bool isDark,
  ) {
    final question = state.currentQuestion;
    final selectedOption = state.currentSelectedOption;

    return SafeArea(
      child: Column(
        children: [
          // Linear Progress Bar
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColors.primary400 : AppColors.primary600,
            ),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Difficulty Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.primary900.withValues(alpha: 0.4) : AppColors.primary50,
                        borderRadius: AppRadii.roundedFull,
                      ),
                      child: Text(
                        question.category.displayName,
                        style: TextStyle(
                          fontSize: AppFontSizes.labelSmall,
                          fontWeight: AppFontWeights.semiBold,
                          color: isDark ? AppColors.primary300 : AppColors.primary700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '• Level ${question.difficulty}',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Optional Context Passage
                if (question.context != null) ...[
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: AppIconSizes.sm,
                              color: isDark ? AppColors.primary400 : AppColors.primary600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reading Passage',
                              style: TextStyle(
                                fontSize: AppFontSizes.labelMedium,
                                fontWeight: AppFontWeights.semiBold,
                                color: isDark ? AppColors.primary400 : AppColors.primary600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          question.context!,
                          style: TextStyle(
                            fontSize: AppFontSizes.bodyMedium,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Question Stem
                Text(
                  question.question,
                  style: TextStyle(
                    fontSize: AppFontSizes.titleMedium,
                    fontWeight: AppFontWeights.semiBold,
                    height: 1.35,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Options List
                ...List.generate(question.options.length, (optIndex) {
                  final optionText = question.options[optIndex];
                  final isSelected = selectedOption == optIndex;
                  final optionLetter = String.fromCharCode(65 + optIndex); // A, B, C, D

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => notifier.selectOption(optIndex),
                        borderRadius: AppRadii.roundedLg,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
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
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? AppColors.primary800 : AppColors.primary100)
                                      : (isDark ? AppColors.slate800 : AppColors.slate100),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  optionLetter,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.labelMedium,
                                    fontWeight: AppFontWeights.bold,
                                    color: isSelected
                                        ? (isDark ? AppColors.primary300 : AppColors.primary700)
                                        : (isDark ? AppColors.slate300 : AppColors.slate700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.bodyMedium,
                                    fontWeight: isSelected ? AppFontWeights.semiBold : AppFontWeights.regular,
                                    color: isSelected
                                        ? (isDark ? AppColors.primary300 : AppColors.primary800)
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: AppIconSizes.md,
                                color: isSelected
                                    ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                    : (isDark ? AppColors.slate600 : AppColors.slate300),
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
          // Question Navigation Bar
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
                if (state.currentIndex > 0)
                  SecondaryButton(
                    label: 'Previous',
                    icon: const Icon(Icons.chevron_left_rounded, size: 18),
                    onPressed: notifier.previousQuestion,
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                PrimaryButton(
                  label: state.isLastQuestion ? 'Submit Test' : 'Next Question',
                  icon: Icon(
                    state.isLastQuestion ? Icons.check_rounded : Icons.chevron_right_rounded,
                    size: 18,
                  ),
                  onPressed: state.hasAnsweredCurrent ? notifier.nextQuestion : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(
    BuildContext context,
    WidgetRef ref,
    PlacementTestState state,
    bool isDark,
  ) {
    final result = state.result!;

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
                    title: 'Your estimated level',
                    subtitle: 'A foundational benchmark to orient your daily study',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Level Showcase Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primary900.withValues(alpha: 0.5) : AppColors.primary100,
                            borderRadius: AppRadii.roundedFull,
                          ),
                          child: Text(
                            'CEFR ${result.estimatedLevel}',
                            style: TextStyle(
                              fontSize: AppFontSizes.headlineSmall,
                              fontWeight: AppFontWeights.bold,
                              color: isDark ? AppColors.primary300 : AppColors.primary800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          result.levelTitle,
                          style: TextStyle(
                            fontSize: AppFontSizes.titleLarge,
                            fontWeight: AppFontWeights.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Score: ${result.correctAnswers} of ${result.totalQuestions} questions correct (${result.scorePercentage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: AppFontSizes.bodySmall,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'What this means',
                          style: TextStyle(
                            fontSize: AppFontSizes.labelLarge,
                            fontWeight: AppFontWeights.semiBold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.levelDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSizes.bodyMedium,
                            height: 1.45,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Skill Breakdown
                  Text(
                    'Competency Breakdown',
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
                      children: result.categoryRatings.entries.map((entry) {
                        final category = entry.key;
                        final rating = entry.value;
                        final score = result.categoryScores[category] ?? 0.0;

                        Color badgeColor;
                        Color textColor;
                        if (rating == 'Strong area') {
                          badgeColor = isDark ? AppColors.sage700.withValues(alpha: 0.3) : AppColors.sage100;
                          textColor = isDark ? AppColors.sage400 : AppColors.sage700;
                        } else if (rating == 'Good foundation') {
                          badgeColor = isDark ? AppColors.primary800 : AppColors.primary100;
                          textColor = isDark ? AppColors.primary300 : AppColors.primary700;
                        } else {
                          badgeColor = isDark ? AppColors.warning600.withValues(alpha: 0.3) : AppColors.warning100;
                          textColor = isDark ? AppColors.warning400 : AppColors.warning600;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.displayName,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.bodyMedium,
                                        fontWeight: AppFontWeights.medium,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ProgressBar(
                                      value: score,
                                      height: 5,
                                      color: textColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: AppRadii.roundedFull,
                                ),
                                child: Text(
                                  rating,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.labelSmall,
                                    fontWeight: AppFontWeights.semiBold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action Controls
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
                  label: 'Retake Test',
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  onPressed: () => ref.read(placementTestProvider.notifier).reset(),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: 'Continue to Plan',
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    onPressed: () {
                      // Save estimated level in onboarding provider
                      ref.read(onboardingNotifierProvider.notifier).recordPlacementResult(result);
                      _safeExit(context);
                    },
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

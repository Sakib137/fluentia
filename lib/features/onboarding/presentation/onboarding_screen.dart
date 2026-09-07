import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/preferences_service.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/fluent_button.dart';
import '../../../shared/widgets/fluent_card.dart';

/// Onboarding screen introducing Fluentia's principles and transitioning to Home.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setBool(StorageKeys.hasCompletedOnboarding, true);
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: FluentButton(
                  text: AppStrings.skip,
                  variant: FluentButtonVariant.text,
                  onPressed: () => _completeOnboarding(context, ref),
                ),
              ),
              const Spacer(),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.primary50,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(
                    color: isDark ? AppColors.slate700 : AppColors.primary200,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  size: 30,
                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.onboardingTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.25,
                  color: isDark ? AppColors.slate50 : AppColors.slate900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.onboardingSubtitle,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FluentCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.offline_pin_rounded,
                      color: isDark ? AppColors.sage500 : AppColors.sage600,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.offlineModeBadge,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.slate100
                                  : AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.offlineModeDesc,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isDark
                                  ? AppColors.slate400
                                  : AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FluentButton(
                text: AppStrings.getStarted,
                expand: true,
                onPressed: () => _completeOnboarding(context, ref),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

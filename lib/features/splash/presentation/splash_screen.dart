import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/preferences_service.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Splash screen that bootstraps app state and routes to Onboarding or Home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final prefs = ref.read(preferencesServiceProvider);
    final hasCompletedOnboarding =
        prefs.getBool(StorageKeys.hasCompletedOnboarding) ?? false;

    if (hasCompletedOnboarding) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.primary50,
                borderRadius: AppSpacing.roundedXl,
                border: Border.all(
                  color: isDark ? AppColors.primary700 : AppColors.primary200,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 36,
                color: isDark ? AppColors.primary300 : AppColors.primary600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: isDark ? AppColors.slate50 : AppColors.slate900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.splashTagline,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.slate400 : AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

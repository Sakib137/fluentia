import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/notifications/notification_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../onboarding/data/repositories/onboarding_repository.dart';

/// Splash screen that bootstraps app state, initializes local services, and routes cleanly.
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

  void _handleNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        // Initialize required local services
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.initialize();

        // Check onboarding completion status
        final repo = ref.read(onboardingRepositoryProvider);
        final hasCompletedOnboarding = await repo.hasCompletedOnboarding();

        if (!mounted) return;

        if (hasCompletedOnboarding) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.onboarding);
        }
      } catch (e, st) {
        AppLogger.error(
          'Error during splash initialization',
          error: e,
          stackTrace: st,
          tag: 'SplashScreen',
        );
        if (mounted) {
          context.go(AppRoutes.onboarding);
        }
      }
    });
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
                size: 38,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: isDark ? AppColors.slate50 : AppColors.slate900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.splashTagline,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.primary400 : AppColors.primary600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

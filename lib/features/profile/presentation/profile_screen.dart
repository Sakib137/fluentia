import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/widgets.dart';

/// Profile hub screen displaying learner identity, quick preferences, and system routes.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.profileTitle,
        subtitle: 'Preferences, reminders, and offline storage',
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // User Summary Card
            AppCard(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark
                        ? AppColors.slate800
                        : AppColors.primary100,
                    child: Icon(
                      Icons.person_rounded,
                      size: AppIconSizes.xl,
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'English Learner',
                          style: TextStyle(
                            fontSize: AppFontSizes.titleMedium,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Offline Profile • CEFR B1',
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
                  const LevelBadge(level: 'B1'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Preferences Section
            const SectionHeader(
              title: 'Preferences & System',
              subtitle: 'Configure app appearance and daily reminder schedule',
            ),
            const SizedBox(height: AppSpacing.xs),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.palette_outlined,
                      size: AppIconSizes.md,
                      color: isDark
                          ? AppColors.primary300
                          : AppColors.primary600,
                    ),
                    title: Text(
                      'Settings & Theme',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Appearance, dark mode, and system defaults',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppIconSizes.xs + 2,
                      color: isDark ? AppColors.slate600 : AppColors.slate400,
                    ),
                    onTap: () => context.push(AppRoutes.profileSettings),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      size: AppIconSizes.md,
                      color: isDark ? AppColors.sage400 : AppColors.sage600,
                    ),
                    title: Text(
                      'Study Reminders',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyMedium,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Daily streak alerts and practice schedules',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppIconSizes.xs + 2,
                      color: isDark ? AppColors.slate600 : AppColors.slate400,
                    ),
                    onTap: () => context.push(AppRoutes.profileNotifications),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Offline Storage Status
            const SectionHeader(
              title: 'Storage & Diagnostics',
              subtitle: 'Zero-cloud local persistence engine status',
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: AppSpacing.cardPaddingDense,
              child: Row(
                children: [
                  Icon(
                    Icons.storage_rounded,
                    size: AppIconSizes.lg,
                    color: isDark ? AppColors.primary300 : AppColors.primary600,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local SQLite Database',
                          style: TextStyle(
                            fontSize: AppFontSizes.titleSmall,
                            fontWeight: AppFontWeights.semiBold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'fluentia.db (v${AppConstants.databaseVersion}) • WAL Mode Active',
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
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // App Version Footer
            Center(
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
                  fontWeight: AppFontWeights.medium,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

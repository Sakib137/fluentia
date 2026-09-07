import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/widgets.dart';

/// Settings and preferences screen (/profile/settings).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Settings & Preferences',
        subtitle: 'Appearance and offline configuration',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SectionHeader(
              title: AppStrings.themeSetting,
              subtitle: 'Select your preferred visual appearance',
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  _buildThemeOption(
                    context: context,
                    ref: ref,
                    title: AppStrings.themeSystem,
                    value: ThemeMode.system,
                    groupValue: currentThemeMode,
                    icon: Icons.brightness_auto_rounded,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  _buildThemeOption(
                    context: context,
                    ref: ref,
                    title: AppStrings.themeLight,
                    value: ThemeMode.light,
                    groupValue: currentThemeMode,
                    icon: Icons.light_mode_rounded,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  _buildThemeOption(
                    context: context,
                    ref: ref,
                    title: AppStrings.themeDark,
                    value: ThemeMode.dark,
                    groupValue: currentThemeMode,
                    icon: Icons.dark_mode_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(
              title: 'Storage & Database',
              subtitle: 'Local SQLite engine status and diagnostics',
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
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
                          'Local SQLite Engine',
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
            SecondaryButton(
              text: 'Return to Profile',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required IconData icon,
  }) {
    final isDark = context.isDarkMode;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(value);
      },
      borderRadius: AppRadii.roundedMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppIconSizes.md,
              color: isSelected
                  ? (isDark ? AppColors.primary300 : AppColors.primary600)
                  : (isDark ? AppColors.slate500 : AppColors.slate400),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSizes.bodyMedium,
                  fontWeight: isSelected
                      ? AppFontWeights.semiBold
                      : AppFontWeights.regular,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: AppIconSizes.md,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
              ),
          ],
        ),
      ),
    );
  }
}

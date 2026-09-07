import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/notifications/notification_provider.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/widgets.dart';

/// Notifications settings and practice reminders screen (/profile/notifications).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _remindersEnabled = true;

  Future<void> _triggerTestNotification() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    await notificationService.requestPermissions();
    await notificationService.showImmediateNotification(
      id: 999,
      title: 'Fluentia Practice Time',
      body: 'Keep your streak alive! Complete a quick 5-minute exercise today.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: const FluentAppBar(
        title: 'Study Reminders',
        subtitle: 'Daily notifications and practice schedule',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SectionHeader(
              title: 'Daily Practice Reminders',
              subtitle: 'Never lose your streak with timely local alerts',
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _remindersEnabled,
                    activeTrackColor: isDark
                        ? AppColors.primary400
                        : AppColors.primary600,
                    title: Text(
                      AppStrings.reminderSetting,
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSmall,
                        fontWeight: AppFontWeights.medium,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      AppStrings.reminderDesc,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _remindersEnabled = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    text: 'Send Test Notification',
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                    ),
                    onPressed: _remindersEnabled
                        ? _triggerTestNotification
                        : null,
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
}

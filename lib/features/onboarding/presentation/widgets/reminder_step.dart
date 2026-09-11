import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/onboarding_state_model.dart';

/// Step allowing user to configure practice reminders, reminder frequency, and times.
class ReminderStep extends StatelessWidget {
  const ReminderStep({
    super.key,
    required this.remindersEnabled,
    required this.reminderCount,
    required this.reminderTimes,
    required this.onRemindersEnabledChanged,
    required this.onReminderCountChanged,
    required this.onTimeUpdated,
    required this.onAddCustomSlot,
    required this.onRemoveSlot,
    required this.onBack,
    required this.onContinue,
  });

  final bool remindersEnabled;
  final int reminderCount;
  final List<ReminderTimeSlot> reminderTimes;
  final ValueChanged<bool> onRemindersEnabledChanged;
  final ValueChanged<int> onReminderCountChanged;
  final void Function(int index, int hour, int minute) onTimeUpdated;
  final void Function(int hour, int minute, String label) onAddCustomSlot;
  final ValueChanged<int> onRemoveSlot;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  Future<void> _pickTime(
    BuildContext context,
    int index,
    ReminderTimeSlot slot,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: slot.hour, minute: slot.minute),
    );
    if (picked != null) {
      onTimeUpdated(index, picked.hour, picked.minute);
    }
  }

  Future<void> _addCustomSlot(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) {
      onAddCustomSlot(picked.hour, picked.minute, 'Custom');
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final standardHour = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$standardHour:$minuteStr $period';
  }

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
                    title: 'Would you like practice reminders?',
                    subtitle:
                        'Stay on track with gentle, local notifications on your device',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Toggle Enable / Disable Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: remindersEnabled
                                ? (isDark
                                      ? AppColors.primary900.withValues(
                                          alpha: 0.4,
                                        )
                                      : AppColors.primary50)
                                : (isDark
                                      ? AppColors.slate800
                                      : AppColors.slate100),
                            borderRadius: AppRadii.roundedMd,
                          ),
                          child: Icon(
                            remindersEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_outlined,
                            color: remindersEnabled
                                ? (isDark
                                      ? AppColors.primary400
                                      : AppColors.primary600)
                                : (isDark
                                      ? AppColors.slate500
                                      : AppColors.slate400),
                            size: AppIconSizes.md,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable daily study alerts',
                                style: TextStyle(
                                  fontSize: AppFontSizes.bodyLarge,
                                  fontWeight: AppFontWeights.semiBold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                remindersEnabled
                                    ? 'Daily local reminders active'
                                    : 'Reminders disabled — study at your own pace',
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
                        Switch.adaptive(
                          value: remindersEnabled,
                          onChanged: onRemindersEnabledChanged,
                          activeTrackColor: isDark
                              ? AppColors.primary400
                              : AppColors.primary600,
                        ),
                      ],
                    ),
                  ),
                  if (remindersEnabled) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'How many reminders per day?',
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSmall,
                        fontWeight: AppFontWeights.semiBold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Frequency Selector
                    Row(
                      children: [1, 2, 3].map((count) {
                        final isSelected = reminderCount == count;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: count < 3 ? AppSpacing.sm : 0,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onReminderCountChanged(count),
                                borderRadius: AppRadii.roundedMd,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
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
                                    borderRadius: AppRadii.roundedMd,
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
                                  alignment: Alignment.center,
                                  child: Text(
                                    count == 1 ? '1x Daily' : '${count}x Daily',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.labelMedium,
                                      fontWeight: AppFontWeights.semiBold,
                                      color: isSelected
                                          ? (isDark
                                                ? AppColors.primary300
                                                : AppColors.primary700)
                                          : (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reminder Times',
                          style: TextStyle(
                            fontSize: AppFontSizes.titleSmall,
                            fontWeight: AppFontWeights.semiBold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (reminderTimes.length < 5)
                          TextButton.icon(
                            onPressed: () => _addCustomSlot(context),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Time'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: isDark
                                  ? AppColors.primary300
                                  : AppColors.primary700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...reminderTimes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final timeSlot = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _pickTime(context, index, timeSlot),
                            borderRadius: AppRadii.roundedMd,
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm + 2,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: AppIconSizes.sm + 2,
                                    color: isDark
                                        ? AppColors.primary400
                                        : AppColors.primary600,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      'Reminder ${index + 1}',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.bodyMedium,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.slate800
                                          : AppColors.slate100,
                                      borderRadius: AppRadii.roundedSm,
                                    ),
                                    child: Text(
                                      _formatTime(
                                        timeSlot.hour,
                                        timeSlot.minute,
                                      ),
                                      style: TextStyle(
                                        fontSize: AppFontSizes.labelLarge,
                                        fontWeight: AppFontWeights.bold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ),
                                  if (reminderTimes.length > 1) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.slate500
                                            : AppColors.slate400,
                                      ),
                                      onPressed: () => onRemoveSlot(index),
                                      tooltip: 'Remove slot',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
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
                    label: remindersEnabled
                        ? AppStrings.continueText
                        : 'Maybe Later',
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

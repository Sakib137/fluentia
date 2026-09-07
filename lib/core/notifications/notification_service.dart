import 'package:flutter/material.dart';

/// Abstract contract for scheduling and managing local reminders and alerts.
/// Platform details are isolated behind this interface.
abstract class NotificationService {
  /// Initializes the local notification plugin and configures channel settings.
  Future<void> initialize();

  /// Requests permission to display notifications from the user.
  Future<bool> requestPermissions();

  /// Schedules a recurring daily study reminder at [timeOfDay].
  Future<void> scheduleDailyReminder({
    required TimeOfDay timeOfDay,
    required String title,
    required String body,
    int notificationId,
  });

  /// Shows an immediate local notification (e.g. for milestones, streaks).
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Cancels a specific reminder by [id].
  Future<void> cancelReminder(int id);

  /// Cancels all scheduled notifications.
  Future<void> cancelAll();
}

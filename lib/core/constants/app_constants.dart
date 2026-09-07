/// Application-wide constants for Fluentia.
class AppConstants {
  AppConstants._();

  static const String appName = 'Fluentia';
  static const String appTagline = 'Master English with Clarity and Confidence';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'fluentia.db';
  static const int databaseVersion = 1;

  // Notifications
  static const String notificationChannelId = 'fluentia_daily_reminders';
  static const String notificationChannelName = 'Daily Practice Reminders';
  static const String notificationChannelDesc =
      'Gentle reminders to help you build your daily English practice habit.';
  static const int dailyReminderNotificationId = 1001;

  // Defaults
  static const int defaultDailyGoalMinutes = 15;
  static const int defaultReminderHour = 20; // 8:00 PM
  static const int defaultReminderMinute = 0;
}

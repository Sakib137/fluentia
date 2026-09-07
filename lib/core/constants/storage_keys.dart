/// Storage keys for local key-value preferences and cached state.
class StorageKeys {
  StorageKeys._();

  static const String themeMode = 'fluentia_theme_mode';
  static const String hasCompletedOnboarding =
      'fluentia_has_completed_onboarding';
  static const String dailyReminderEnabled = 'fluentia_daily_reminder_enabled';
  static const String reminderTimeHour = 'fluentia_reminder_time_hour';
  static const String reminderTimeMinute = 'fluentia_reminder_time_minute';
  static const String dailyGoalMinutes = 'fluentia_daily_goal_minutes';
  static const String currentStreak = 'fluentia_current_streak';
  static const String lastPracticeTimestamp =
      'fluentia_last_practice_timestamp';
  static const String preferredLanguageLevel = 'fluentia_user_cefr_level';
}

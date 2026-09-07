/// Utilities for managing practice sessions, streaks, and timestamps.
class DateTimeUtils {
  DateTimeUtils._();

  /// Formats seconds into mm:ss or hh:mm:ss.
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Checks if two DateTimes fall on the exact same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if a date is yesterday relative to reference date (or now).
  static bool isYesterday(DateTime date, [DateTime? referenceDate]) {
    final ref = referenceDate ?? DateTime.now();
    final yesterday = ref.subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Returns ISO 8601 day string (YYYY-MM-DD).
  static String toDateString(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

import '../data/models/home_models.dart';

/// Isolated, pure domain calculator for learning streaks.
///
/// Features:
/// - Normalizes all dates to UTC calendar dates (year-month-day) ignoring time.
/// - Dedupes multiple sessions on the same calendar day.
/// - If practiced today, streak is active and `isMaintainedToday` is true.
/// - If not practiced today, but practiced yesterday, the current streak remains
///   intact but `isMaintainedToday` is false (prompting action).
/// - If yesterday was missed, active streak resets to 0.
/// - Computes the all-time `longestStreak` across historical records.
class StreakCalculator {
  const StreakCalculator._();

  /// Calculates [StreakData] from an unsorted or sorted list of [activeDates].
  ///
  /// [today] specifies the reference date (defaults to `DateTime.now()` if omitted).
  static StreakData calculate({
    required List<DateTime> activeDates,
    DateTime? today,
  }) {
    if (activeDates.isEmpty) {
      return StreakData.empty();
    }

    final referenceDate = today ?? DateTime.now();
    final normalizedToday = _normalizeDate(referenceDate);
    final normalizedYesterday = normalizedToday.subtract(const Duration(days: 1));

    // Normalize and deduplicate active dates
    final uniqueSortedDates = activeDates
        .map(_normalizeDate)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order (newest first)

    if (uniqueSortedDates.isEmpty) {
      return StreakData.empty();
    }

    final mostRecent = uniqueSortedDates.first;
    final isMaintainedToday = uniqueSortedDates.contains(normalizedToday);
    final practicedYesterday = uniqueSortedDates.contains(normalizedYesterday);

    // If neither today nor yesterday has activity, current streak is broken
    int currentStreak = 0;
    if (isMaintainedToday || practicedYesterday) {
      DateTime checkDate = isMaintainedToday ? normalizedToday : normalizedYesterday;
      for (final date in uniqueSortedDates) {
        if (date.isAtSameMomentAs(checkDate)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(checkDate)) {
          // Gap detected in consecutive sequence
          break;
        }
      }
    }

    // Calculate longest consecutive streak across history
    // Sort ascending to count forward sequences
    final ascendingDates = uniqueSortedDates.reversed.toList();
    int longestStreak = 0;
    int runningStreak = 0;
    DateTime? previousDate;

    for (final date in ascendingDates) {
      if (previousDate == null) {
        runningStreak = 1;
      } else {
        final expectedNext = previousDate.add(const Duration(days: 1));
        if (date.isAtSameMomentAs(expectedNext)) {
          runningStreak++;
        } else {
          runningStreak = 1;
        }
      }
      if (runningStreak > longestStreak) {
        longestStreak = runningStreak;
      }
      previousDate = date;
    }

    // Longest streak is at least the current streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDate: mostRecent,
      isMaintainedToday: isMaintainedToday,
    );
  }

  /// Truncates a [DateTime] to date-only at midnight UTC for clean comparison.
  static DateTime _normalizeDate(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }
}

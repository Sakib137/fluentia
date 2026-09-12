import '../models/reading_activity.dart';

/// Pure utility that deterministically selects a daily reading challenge based on calendar date.
class DailyReadingSelector {
  DailyReadingSelector._();

  /// Returns a deterministic ReadingActivity for the specified [date].
  ///
  /// Adapts to [userLevel] when activities for that CEFR level exist.
  /// Guarantees the same activity is selected for identical calendar dates regardless of widget rebuilds.
  static ReadingActivity selectDailyActivity({
    required List<ReadingActivity> activities,
    DateTime? date,
    String? userLevel,
  }) {
    if (activities.isEmpty) {
      throw ArgumentError('Activities list cannot be empty');
    }

    final targetDate = date ?? DateTime.now();
    final dayOfYearHash =
        (targetDate.year * 10000) + (targetDate.month * 100) + targetDate.day;

    // Filter candidate pool by user level if provided
    List<ReadingActivity> pool = activities;
    if (userLevel != null && userLevel.isNotEmpty) {
      final levelFiltered = activities
          .where((a) => a.level.toLowerCase() == userLevel.toLowerCase())
          .toList();
      if (levelFiltered.isNotEmpty) {
        pool = levelFiltered;
      }
    }

    final index = (dayOfYearHash.abs()) % pool.length;
    return pool[index];
  }

  /// Convenience alias for [selectDailyActivity].
  static ReadingActivity select({
    required List<ReadingActivity> activities,
    DateTime? date,
    String? targetLevel,
  }) {
    return selectDailyActivity(
      activities: activities,
      date: date,
      userLevel: targetLevel,
    );
  }
}

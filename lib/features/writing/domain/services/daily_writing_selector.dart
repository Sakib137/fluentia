import '../models/writing_activity.dart';

/// Pure deterministic selector that picks a daily writing prompt based on calendar date.
class DailyWritingSelector {
  DailyWritingSelector._();

  /// Returns a deterministic [WritingActivity] for the specified [date].
  ///
  /// Adapts to [userLevel] when activities for that CEFR level exist.
  /// Guarantees the same activity is selected for identical calendar dates regardless of widget rebuilds.
  static WritingActivity selectDailyActivity({
    required List<WritingActivity> activities,
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
    List<WritingActivity> pool = activities;
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
  static WritingActivity select({
    required List<WritingActivity> activities,
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

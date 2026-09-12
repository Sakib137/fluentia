import '../models/listening_activity.dart';

/// Deterministic selector that picks today's Daily Listening Challenge.
///
/// Ensures the selected activity remains stable and consistent across
/// rebuilds throughout the local calendar day.
class DailyListeningSelector {
  DailyListeningSelector._();

  /// Deterministically selects a [ListeningActivity] from [activities] for [date].
  static ListeningActivity select({
    required List<ListeningActivity> activities,
    required DateTime date,
  }) {
    if (activities.isEmpty) {
      throw ArgumentError('Activities list cannot be empty');
    }

    // Stable date-based hash key: YYYYMMDD
    final dateSeed = date.year * 10000 + date.month * 100 + date.day;
    final index = dateSeed % activities.length;

    return activities[index];
  }
}

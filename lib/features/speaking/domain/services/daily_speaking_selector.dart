import '../models/speaking_activity.dart';
import '../models/speaking_mode.dart';

/// Deterministic calendar-date selector for the Daily Speaking Challenge.
class DailySpeakingSelector {
  const DailySpeakingSelector._();

  /// Deterministically picks a speaking activity from [activities] for [date].
  /// Guaranteed to return the exact same prompt for the same calendar date.
  static SpeakingActivity select({
    required List<SpeakingActivity> activities,
    required DateTime date,
  }) {
    if (activities.isEmpty) {
      throw ArgumentError('Activities list cannot be empty.');
    }

    // Filter to dedicated daily speaking activities if available
    final dailyPool = activities
        .where(
          (a) =>
              a.mode == SpeakingMode.dailySpeaking ||
              a.mode == SpeakingMode.speakAboutIt,
        )
        .toList();

    final candidatePool = dailyPool.isNotEmpty ? dailyPool : activities;

    // Stable date integer hash: YYYYMMDD
    final dateSeed = (date.year * 10000) + (date.month * 100) + date.day;
    final index = (dateSeed % candidatePool.length).abs();

    return candidatePool[index];
  }
}

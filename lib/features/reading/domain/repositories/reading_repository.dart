import '../models/reading_activity.dart';
import '../models/reading_mode.dart';

/// Abstract contract for querying local reading activities and content.
abstract class ReadingRepository {
  /// Fetches all available reading activities across all CEFR levels.
  Future<List<ReadingActivity>> getActivities();

  /// Fetches reading activities tailored to a specific CEFR level (e.g. 'A1', 'B2').
  Future<List<ReadingActivity>> getActivitiesForLevel(String level);

  /// Looks up a specific reading activity by its unique identifier.
  Future<ReadingActivity?> getActivityById(String id);

  /// Returns the deterministic daily reading drill for the given date and user level.
  Future<ReadingActivity> getDailyReading({DateTime? date, String? userLevel});

  /// Yields recommended reading activities considering user level and completed history.
  Future<List<ReadingActivity>> getRecommendedActivities({
    String? userLevel,
    List<String>? completedIds,
  });

  /// Fetches activities belonging to a specific topical category.
  Future<List<ReadingActivity>> getActivitiesByCategory(String category);

  /// Fetches activities designed for a specific reading mode.
  Future<List<ReadingActivity>> getActivitiesForMode(ReadingMode mode);
}

import '../models/writing_activity.dart';
import '../models/writing_mode.dart';

/// Abstract contract for querying local writing practice activities.
abstract class WritingRepository {
  /// Fetches all available writing practice activities across all CEFR levels.
  Future<List<WritingActivity>> getActivities();

  /// Fetches writing activities tailored to a specific CEFR level (e.g. 'A1', 'B2').
  Future<List<WritingActivity>> getActivitiesForLevel(String level);

  /// Looks up a specific writing activity by its unique identifier.
  Future<WritingActivity?> getActivityById(String id);

  /// Returns the deterministic daily writing drill for the given date and user level.
  Future<WritingActivity> getDailyWriting({DateTime? date, String? userLevel});

  /// Yields recommended writing activities considering user level and completed history.
  Future<List<WritingActivity>> getRecommendedActivities({
    String? userLevel,
    List<String>? completedIds,
  });

  /// Fetches activities designed for a specific writing mode.
  Future<List<WritingActivity>> getActivitiesForMode(WritingMode mode);

  /// Fetches activities belonging to a specific topical category.
  Future<List<WritingActivity>> getActivitiesByCategory(String category);
}

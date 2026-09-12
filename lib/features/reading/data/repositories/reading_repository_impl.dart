import '../../domain/models/reading_activity.dart';
import '../../domain/models/reading_mode.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/services/daily_reading_selector.dart';
import '../datasources/reading_content.dart';

/// Offline-first implementation of [ReadingRepository] backed by bundled local content.
class ReadingRepositoryImpl implements ReadingRepository {
  const ReadingRepositoryImpl({List<ReadingActivity>? customActivities})
    : _activities = customActivities ?? ReadingContent.activities;

  final List<ReadingActivity> _activities;

  @override
  Future<List<ReadingActivity>> getActivities() async {
    return List.unmodifiable(_activities);
  }

  @override
  Future<List<ReadingActivity>> getActivitiesForLevel(String level) async {
    return _activities
        .where((a) => a.level.toLowerCase() == level.toLowerCase())
        .toList();
  }

  @override
  Future<ReadingActivity?> getActivityById(String id) async {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ReadingActivity> getDailyReading({
    DateTime? date,
    String? userLevel,
  }) async {
    return DailyReadingSelector.selectDailyActivity(
      activities: _activities,
      date: date,
      userLevel: userLevel,
    );
  }

  @override
  Future<List<ReadingActivity>> getRecommendedActivities({
    String? userLevel,
    List<String>? completedIds,
  }) async {
    final completed = completedIds ?? const [];

    // Filter out recently completed items if alternatives exist
    var uncompleted = _activities
        .where((a) => !completed.contains(a.id))
        .toList();
    if (uncompleted.isEmpty) uncompleted = _activities;

    if (userLevel != null && userLevel.isNotEmpty) {
      final matchingLevel = uncompleted
          .where((a) => a.level.toLowerCase() == userLevel.toLowerCase())
          .toList();
      if (matchingLevel.isNotEmpty) return matchingLevel;
    }

    return uncompleted;
  }

  @override
  Future<List<ReadingActivity>> getActivitiesByCategory(String category) async {
    return _activities
        .where((a) => a.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<ReadingActivity>> getActivitiesForMode(ReadingMode mode) async {
    return _activities.where((a) => a.mode == mode).toList();
  }
}

import '../../domain/models/writing_activity.dart';
import '../../domain/models/writing_mode.dart';
import '../../domain/repositories/writing_repository.dart';
import '../../domain/services/daily_writing_selector.dart';
import '../datasources/writing_content.dart';

/// Offline-first implementation of [WritingRepository] backed by bundled local content.
class WritingRepositoryImpl implements WritingRepository {
  const WritingRepositoryImpl({List<WritingActivity>? customActivities})
    : _activities = customActivities ?? WritingContent.activities;

  final List<WritingActivity> _activities;

  @override
  Future<List<WritingActivity>> getActivities() async {
    return List.unmodifiable(_activities);
  }

  @override
  Future<List<WritingActivity>> getActivitiesForLevel(String level) async {
    return _activities
        .where((a) => a.level.toLowerCase() == level.toLowerCase())
        .toList();
  }

  @override
  Future<WritingActivity?> getActivityById(String id) async {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<WritingActivity> getDailyWriting({
    DateTime? date,
    String? userLevel,
  }) async {
    return DailyWritingSelector.selectDailyActivity(
      activities: _activities,
      date: date,
      userLevel: userLevel,
    );
  }

  @override
  Future<List<WritingActivity>> getRecommendedActivities({
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
  Future<List<WritingActivity>> getActivitiesForMode(WritingMode mode) async {
    return _activities.where((a) => a.mode == mode).toList();
  }

  @override
  Future<List<WritingActivity>> getActivitiesByCategory(String category) async {
    return _activities
        .where((a) => a.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}

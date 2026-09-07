import 'package:flutter/foundation.dart';

/// Models representing state and entities displayed on the Home Dashboard.

/// Daily practice progress state.
@immutable
class DailyProgressState {
  const DailyProgressState({
    required this.targetMinutes,
    required this.practicedMinutes,
    required this.isCompleted,
    required this.remainingMinutes,
    required this.progressFraction,
    required this.isFirstDay,
  });

  final int targetMinutes;
  final int practicedMinutes;
  final bool isCompleted;
  final int remainingMinutes;
  final double progressFraction;
  final bool isFirstDay;

  DailyProgressState copyWith({
    int? targetMinutes,
    int? practicedMinutes,
    bool? isCompleted,
    int? remainingMinutes,
    double? progressFraction,
    bool? isFirstDay,
  }) {
    return DailyProgressState(
      targetMinutes: targetMinutes ?? this.targetMinutes,
      practicedMinutes: practicedMinutes ?? this.practicedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      progressFraction: progressFraction ?? this.progressFraction,
      isFirstDay: isFirstDay ?? this.isFirstDay,
    );
  }

  factory DailyProgressState.initial({int targetMinutes = 15, bool isFirstDay = true}) {
    return DailyProgressState(
      targetMinutes: targetMinutes,
      practicedMinutes: 0,
      isCompleted: false,
      remainingMinutes: targetMinutes,
      progressFraction: 0.0,
      isFirstDay: isFirstDay,
    );
  }
}

/// User learning streak metrics.
@immutable
class StreakData {
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.isMaintainedToday,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final bool isMaintainedToday;

  factory StreakData.empty() {
    return const StreakData(
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: null,
      isMaintainedToday: false,
    );
  }
}

/// A single activity within the Daily Challenge.
@immutable
class DailyChallengeItem {
  const DailyChallengeItem({
    required this.id,
    required this.title,
    required this.skillType,
    required this.isCompleted,
    required this.durationMinutes,
  });

  final String id;
  final String title;
  final String skillType;
  final bool isCompleted;
  final int durationMinutes;

  DailyChallengeItem copyWith({
    String? id,
    String? title,
    String? skillType,
    bool? isCompleted,
    int? durationMinutes,
  }) {
    return DailyChallengeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      skillType: skillType ?? this.skillType,
      isCompleted: isCompleted ?? this.isCompleted,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

/// State of today's Daily Challenge.
@immutable
class DailyChallengeState {
  const DailyChallengeState({
    required this.dateKey,
    required this.items,
  });

  final String dateKey; // YYYY-MM-DD
  final List<DailyChallengeItem> items;

  int get completedCount => items.where((i) => i.isCompleted).length;
  int get totalCount => items.length;
  bool get isAllCompleted => items.isNotEmpty && completedCount == totalCount;
  double get progressFraction => totalCount > 0 ? (completedCount / totalCount) : 0.0;
}

/// Word of the Day entity.
@immutable
class WordOfTheDay {
  const WordOfTheDay({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.cefrLevel,
    this.isSaved = false,
  });

  final String id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final String example;
  final String cefrLevel;
  final bool isSaved;

  WordOfTheDay copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? partOfSpeech,
    String? definition,
    String? example,
    String? cefrLevel,
    bool? isSaved,
  }) {
    return WordOfTheDay(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Quick practice card item recommendation.
@immutable
class QuickPracticeItem {
  const QuickPracticeItem({
    required this.skillType,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.route,
    required this.isPrimaryGoal,
  });

  final String skillType;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String route;
  final bool isPrimaryGoal;
}

/// Summary metrics for the Progress Snapshot section.
@immutable
class ProgressSnapshotData {
  const ProgressSnapshotData({
    required this.cefrLevel,
    required this.levelTitle,
    required this.totalPracticeMinutes,
    required this.wordsLearnedCount,
    required this.completedSessionsCount,
    required this.currentStreakDays,
  });

  final String cefrLevel;
  final String levelTitle;
  final int totalPracticeMinutes;
  final int wordsLearnedCount;
  final int completedSessionsCount;
  final int currentStreakDays;

  factory ProgressSnapshotData.initial({String cefrLevel = 'B1', String levelTitle = 'Intermediate'}) {
    return ProgressSnapshotData(
      cefrLevel: cefrLevel,
      levelTitle: levelTitle,
      totalPracticeMinutes: 0,
      wordsLearnedCount: 0,
      completedSessionsCount: 0,
      currentStreakDays: 0,
    );
  }
}

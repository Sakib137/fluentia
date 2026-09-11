import 'package:flutter/material.dart';

/// Supported practice skills in Fluentia.
enum PracticeSkill {
  speaking(
    'speaking',
    'Speaking',
    'Build confidence through real-world speaking.',
    Icons.mic_rounded,
    5,
    'Oral Fluency',
  ),
  listening(
    'listening',
    'Listening',
    'Improve native comprehension and rhythm.',
    Icons.headphones_rounded,
    5,
    'Comprehension',
  ),
  reading(
    'reading',
    'Reading',
    'Master contextual comprehension and flow.',
    Icons.menu_book_rounded,
    5,
    'Articles & Drills',
  ),
  writing(
    'writing',
    'Writing',
    'Express ideas with grammatical precision.',
    Icons.edit_note_rounded,
    5,
    'Composition',
  );

  const PracticeSkill(
    this.id,
    this.title,
    this.description,
    this.icon,
    this.defaultDurationMinutes,
    this.badgeText,
  );

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int defaultDurationMinutes;
  final String badgeText;

  static PracticeSkill fromId(String id) {
    return PracticeSkill.values.firstWhere(
      (s) => s.id.toLowerCase() == id.toLowerCase(),
      orElse: () => PracticeSkill.speaking,
    );
  }
}

/// Extensible activity drill types across skills.
enum PracticeActivityType {
  speakingPrompt('speakingPrompt', 'Speaking Prompt'),
  listenAndChoose('listenAndChoose', 'Listen & Choose'),
  dictation('dictation', 'Dictation'),
  readingComprehension('readingComprehension', 'Reading Comprehension'),
  sentenceWriting('sentenceWriting', 'Sentence Writing'),
  shortWriting('shortWriting', 'Short Writing');

  const PracticeActivityType(this.id, this.displayName);

  final String id;
  final String displayName;

  static PracticeActivityType fromId(String id) {
    return PracticeActivityType.values.firstWhere(
      (t) => t.id.toLowerCase() == id.toLowerCase(),
      orElse: () => PracticeActivityType.speakingPrompt,
    );
  }
}

/// Extensible domain representation of a practice activity drill.
class PracticeActivity {
  const PracticeActivity({
    required this.id,
    required this.skill,
    required this.type,
    required this.title,
    required this.instruction,
    required this.level,
    this.estimatedDurationMinutes = 2,
    this.difficulty = 'Intermediate',
    this.content = const {},
    this.metadata = const {},
  });

  final String id;
  final PracticeSkill skill;
  final PracticeActivityType type;
  final String title;
  final String instruction;
  final String level;
  final int estimatedDurationMinutes;
  final String difficulty;
  final Map<String, dynamic> content;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
    'id': id,
    'skill': skill.id,
    'type': type.id,
    'title': title,
    'instruction': instruction,
    'level': level,
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'difficulty': difficulty,
    'content': content,
    'metadata': metadata,
  };

  factory PracticeActivity.fromJson(Map<String, dynamic> json) {
    return PracticeActivity(
      id: json['id'] as String? ?? '',
      skill: PracticeSkill.fromId(json['skill'] as String? ?? 'speaking'),
      type: PracticeActivityType.fromId(
        json['type'] as String? ?? 'speakingPrompt',
      ),
      title: json['title'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      level: json['level'] as String? ?? 'B1',
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int? ?? 2,
      difficulty: json['difficulty'] as String? ?? 'Intermediate',
      content: json['content'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}

/// Lifecycle status for a practice session.
enum PracticeSessionStatus {
  notStarted,
  inProgress,
  completed,
  abandoned;

  String get displayName => switch (this) {
    notStarted => 'Not Started',
    inProgress => 'In Progress',
    completed => 'Completed',
    abandoned => 'Abandoned',
  };
}

/// Reusable domain model for a practice session.
class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.skill,
    required this.activityIds,
    required this.level,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds = 0,
    this.score,
    this.status = PracticeSessionStatus.notStarted,
    this.currentActivityIndex = 0,
    required this.totalActivities,
  });

  final String id;
  final PracticeSkill skill;
  final List<String> activityIds;
  final String level;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int durationSeconds;
  final double? score;
  final PracticeSessionStatus status;
  final int currentActivityIndex;
  final int totalActivities;

  bool get isCompleted => status == PracticeSessionStatus.completed;
  bool get isAbandoned => status == PracticeSessionStatus.abandoned;
  bool get isInProgress => status == PracticeSessionStatus.inProgress;

  double get progressFraction {
    if (totalActivities <= 0) return 0.0;
    return (currentActivityIndex / totalActivities).clamp(0.0, 1.0);
  }

  int get durationMinutes => (durationSeconds / 60).ceil();

  PracticeSession copyWith({
    String? id,
    PracticeSkill? skill,
    List<String>? activityIds,
    String? level,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    double? score,
    PracticeSessionStatus? status,
    int? currentActivityIndex,
    int? totalActivities,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      skill: skill ?? this.skill,
      activityIds: activityIds ?? this.activityIds,
      level: level ?? this.level,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      score: score ?? this.score,
      status: status ?? this.status,
      currentActivityIndex: currentActivityIndex ?? this.currentActivityIndex,
      totalActivities: totalActivities ?? this.totalActivities,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'skill': skill.id,
    'activityIds': activityIds,
    'level': level,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'score': score,
    'status': status.name,
    'currentActivityIndex': currentActivityIndex,
    'totalActivities': totalActivities,
  };

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] as String? ?? '',
      skill: PracticeSkill.fromId(json['skill'] as String? ?? 'speaking'),
      activityIds:
          (json['activityIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      level: json['level'] as String? ?? 'B1',
      startedAt:
          DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      score: (json['score'] as num?)?.toDouble(),
      status: PracticeSessionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PracticeSessionStatus.notStarted,
      ),
      currentActivityIndex: json['currentActivityIndex'] as int? ?? 0,
      totalActivities: json['totalActivities'] as int? ?? 0,
    );
  }
}

/// UI presentation model for practice module cards.
class PracticeModuleInfo {
  const PracticeModuleInfo({
    required this.skill,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.icon,
    this.badge,
    this.metadata,
    this.isEnabled = true,
    this.isRecommended = false,
  });

  final PracticeSkill skill;
  final String title;
  final String description;
  final int durationMinutes;
  final IconData icon;
  final String? badge;
  final String? metadata;
  final bool isEnabled;
  final bool isRecommended;
}

import '../../../practice/domain/models/practice_models.dart';
import 'speaking_mode.dart';

/// Domain model representing an interactive speaking drill in Fluentia Speaking Lab.
class SpeakingActivity {
  const SpeakingActivity({
    required this.id,
    required this.title,
    required this.prompt,
    required this.instruction,
    required this.level,
    this.estimatedDurationMinutes = 2,
    this.preparationSeconds = 10,
    this.speakingSeconds = 60,
    required this.mode,
    this.expectedText,
    this.category = 'General',
    this.tags = const [],
    this.starter,
    this.keyPhrases = const [],
  });

  final String id;
  final String title;
  final String prompt;
  final String instruction;
  final String level;
  final int estimatedDurationMinutes;
  final int preparationSeconds;
  final int speakingSeconds;
  final SpeakingMode mode;
  final String? expectedText; // Specifically for Read Aloud
  final String category;
  final List<String> tags;
  final String? starter;
  final List<String> keyPhrases;

  /// Whether this activity is an expected text comparison drill (Read Aloud).
  bool get hasExpectedText =>
      expectedText != null && expectedText!.trim().isNotEmpty;

  /// Adapts this [SpeakingActivity] to the central [PracticeActivity] domain model.
  PracticeActivity toPracticeActivity() {
    return PracticeActivity(
      id: id,
      skill: PracticeSkill.speaking,
      type: PracticeActivityType.speakingPrompt,
      title: title,
      instruction: instruction,
      level: level,
      estimatedDurationMinutes: estimatedDurationMinutes,
      difficulty: _cefrToDifficulty(level),
      content: {
        'prompt': prompt,
        if (expectedText != null) 'expectedText': expectedText,
        if (starter != null) 'starter': starter,
        if (keyPhrases.isNotEmpty) 'keyPhrases': keyPhrases,
        'mode': mode.id,
        'preparationSeconds': preparationSeconds,
        'speakingSeconds': speakingSeconds,
      },
      metadata: {'category': category, 'tags': tags},
    );
  }

  /// Instantiates a [SpeakingActivity] from a generic [PracticeActivity].
  factory SpeakingActivity.fromPracticeActivity(PracticeActivity activity) {
    final content = activity.content;
    final metadata = activity.metadata;

    final modeStr = content['mode'] as String?;
    final mode = modeStr != null
        ? SpeakingMode.fromId(modeStr)
        : SpeakingMode.speakAboutIt;

    return SpeakingActivity(
      id: activity.id,
      title: activity.title,
      prompt: content['prompt'] as String? ?? activity.instruction,
      instruction: activity.instruction,
      level: activity.level,
      estimatedDurationMinutes: activity.estimatedDurationMinutes,
      preparationSeconds: content['preparationSeconds'] as int? ?? 10,
      speakingSeconds: content['speakingSeconds'] as int? ?? 60,
      mode: mode,
      expectedText: content['expectedText'] as String?,
      category: metadata['category'] as String? ?? 'General',
      tags: (metadata['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      starter: content['starter'] as String?,
      keyPhrases:
          (content['keyPhrases'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  static String _cefrToDifficulty(String level) {
    return switch (level.toUpperCase()) {
      'A1' => 'Beginner',
      'A2' => 'Elementary',
      'B1' => 'Intermediate',
      'B2' => 'Upper Intermediate',
      'C1' => 'Advanced',
      _ => 'Intermediate',
    };
  }

  SpeakingActivity copyWith({
    String? id,
    String? title,
    String? prompt,
    String? instruction,
    String? level,
    int? estimatedDurationMinutes,
    int? preparationSeconds,
    int? speakingSeconds,
    SpeakingMode? mode,
    String? expectedText,
    String? category,
    List<String>? tags,
    String? starter,
    List<String>? keyPhrases,
  }) {
    return SpeakingActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      instruction: instruction ?? this.instruction,
      level: level ?? this.level,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      preparationSeconds: preparationSeconds ?? this.preparationSeconds,
      speakingSeconds: speakingSeconds ?? this.speakingSeconds,
      mode: mode ?? this.mode,
      expectedText: expectedText ?? this.expectedText,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      starter: starter ?? this.starter,
      keyPhrases: keyPhrases ?? this.keyPhrases,
    );
  }
}

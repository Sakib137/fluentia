import '../../../practice/domain/models/practice_models.dart';
import 'writing_mode.dart';

/// Domain entity representing a structured writing drill in Fluentia Writing Lab.
class WritingActivity {
  const WritingActivity({
    required this.id,
    required this.title,
    required this.instruction,
    required this.level,
    required this.mode,
    required this.prompt,
    this.context,
    this.minimumWords = 0,
    this.maximumWords = 0,
    this.expectedAnswer,
    this.acceptedAnswers = const [],
    this.sentenceParts = const [],
    this.checklist = const [],
    this.hints = const [],
    this.estimatedDurationMinutes = 3,
    required this.category,
    this.tags = const [],
    this.difficulty = 'Intermediate',
    this.sampleAnswer,
  });

  final String id;
  final String title;
  final String instruction;
  final String level;
  final WritingMode mode;
  final String prompt;
  final String? context;
  final int minimumWords;
  final int maximumWords;
  final String? expectedAnswer;
  final List<String> acceptedAnswers;
  final List<String> sentenceParts;
  final List<String> checklist;
  final List<String> hints;
  final int estimatedDurationMinutes;
  final String category;
  final List<String> tags;
  final String difficulty;
  final String? sampleAnswer;

  /// Indicates if this activity is an objective drill (Sentence Builder or Complete the Sentence)
  /// with a deterministically verifiable expected answer.
  bool get isObjective =>
      mode == WritingMode.sentenceBuilder ||
      mode == WritingMode.completeSentence ||
      (expectedAnswer != null && expectedAnswer!.isNotEmpty);

  /// Converts this writing drill into a core PracticeActivity for SQLite database persistence.
  PracticeActivity toPracticeActivity() {
    final activityType = switch (mode) {
      WritingMode.quickResponse => PracticeActivityType.quickResponse,
      WritingMode.sentenceBuilder => PracticeActivityType.sentenceBuilder,
      WritingMode.completeSentence => PracticeActivityType.completeSentence,
      WritingMode.shortWriting => PracticeActivityType.shortWriting,
      WritingMode.guidedWriting => PracticeActivityType.guidedWriting,
    };

    return PracticeActivity(
      id: id,
      skill: PracticeSkill.writing,
      type: activityType,
      title: title,
      instruction: instruction,
      level: level,
      estimatedDurationMinutes: estimatedDurationMinutes,
      difficulty: difficulty,
      content: {
        'prompt': prompt,
        if (context != null) 'context': context,
        'minimumWords': minimumWords,
        'maximumWords': maximumWords,
        if (expectedAnswer != null) 'expectedAnswer': expectedAnswer,
        if (acceptedAnswers.isNotEmpty) 'acceptedAnswers': acceptedAnswers,
        if (sentenceParts.isNotEmpty) 'sentenceParts': sentenceParts,
        if (checklist.isNotEmpty) 'checklist': checklist,
        if (hints.isNotEmpty) 'hints': hints,
        if (sampleAnswer != null) 'sampleAnswer': sampleAnswer,
      },
      metadata: {'category': category, 'mode': mode.id, 'tags': tags},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'instruction': instruction,
    'level': level,
    'mode': mode.id,
    'prompt': prompt,
    'context': context,
    'minimumWords': minimumWords,
    'maximumWords': maximumWords,
    'expectedAnswer': expectedAnswer,
    'acceptedAnswers': acceptedAnswers,
    'sentenceParts': sentenceParts,
    'checklist': checklist,
    'hints': hints,
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'category': category,
    'tags': tags,
    'difficulty': difficulty,
    'sampleAnswer': sampleAnswer,
  };

  factory WritingActivity.fromJson(Map<String, dynamic> json) {
    return WritingActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      instruction: json['instruction'] as String? ?? '',
      level: json['level'] as String? ?? 'B1',
      mode: WritingMode.fromId(json['mode'] as String? ?? 'quickResponse'),
      prompt: json['prompt'] as String,
      context: json['context'] as String?,
      minimumWords: json['minimumWords'] as int? ?? 0,
      maximumWords: json['maximumWords'] as int? ?? 0,
      expectedAnswer: json['expectedAnswer'] as String?,
      acceptedAnswers:
          (json['acceptedAnswers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sentenceParts:
          (json['sentenceParts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      checklist:
          (json['checklist'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      hints:
          (json['hints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int? ?? 3,
      category: json['category'] as String? ?? 'General Writing',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      difficulty: json['difficulty'] as String? ?? 'Intermediate',
      sampleAnswer: json['sampleAnswer'] as String?,
    );
  }
}

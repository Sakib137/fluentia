import '../../../practice/domain/models/practice_models.dart';
import 'comprehension_question.dart';
import 'listening_mode.dart';

/// Domain model representing an interactive listening drill in Fluentia Listening Lab.
class ListeningActivity {
  const ListeningActivity({
    required this.id,
    required this.title,
    required this.instruction,
    required this.level,
    required this.mode,
    required this.audioAsset,
    required this.transcript,
    this.question,
    this.options = const [],
    this.correctAnswer,
    this.acceptedAnswers = const [],
    this.missingWords = const [],
    this.comprehensionQuestions = const [],
    this.explanation,
    this.estimatedDurationMinutes = 3,
    this.category = 'General',
    this.tags = const [],
  });

  final String id;
  final String title;
  final String instruction;
  final String level;
  final ListeningMode mode;
  final String audioAsset;
  final String transcript;
  final String? question;
  final List<String> options;
  final String? correctAnswer;
  final List<String> acceptedAnswers;
  final List<String> missingWords;
  final List<ComprehensionQuestion> comprehensionQuestions;
  final String? explanation;
  final int estimatedDurationMinutes;
  final String category;
  final List<String> tags;

  /// Translates [ListeningMode] to central [PracticeActivityType].
  PracticeActivityType get practiceActivityType => switch (mode) {
    ListeningMode.listenAndChoose => PracticeActivityType.listenAndChoose,
    ListeningMode.trueFalse => PracticeActivityType.trueFalse,
    ListeningMode.dictation => PracticeActivityType.dictation,
    ListeningMode.fillMissingWords => PracticeActivityType.fillMissingWords,
    ListeningMode.comprehension => PracticeActivityType.listeningComprehension,
  };

  /// Adapts this [ListeningActivity] to the central [PracticeActivity] domain model.
  PracticeActivity toPracticeActivity() {
    return PracticeActivity(
      id: id,
      skill: PracticeSkill.listening,
      type: practiceActivityType,
      title: title,
      instruction: instruction,
      level: level,
      estimatedDurationMinutes: estimatedDurationMinutes,
      difficulty: _cefrToDifficulty(level),
      content: {
        'mode': mode.id,
        'audioAsset': audioAsset,
        'transcript': transcript,
        if (question != null) 'question': question,
        if (options.isNotEmpty) 'options': options,
        if (correctAnswer != null) 'correctAnswer': correctAnswer,
        if (acceptedAnswers.isNotEmpty) 'acceptedAnswers': acceptedAnswers,
        if (missingWords.isNotEmpty) 'missingWords': missingWords,
        if (comprehensionQuestions.isNotEmpty)
          'comprehensionQuestions': comprehensionQuestions
              .map((q) => q.toJson())
              .toList(),
        if (explanation != null) 'explanation': explanation,
      },
      metadata: {'category': category, 'tags': tags},
    );
  }

  /// Instantiates a [ListeningActivity] from a generic [PracticeActivity].
  factory ListeningActivity.fromPracticeActivity(PracticeActivity activity) {
    final content = activity.content;
    final metadata = activity.metadata;

    final modeStr = content['mode'] as String?;
    final mode = modeStr != null
        ? ListeningMode.fromId(modeStr)
        : ListeningMode.listenAndChoose;

    final rawQuestions =
        content['comprehensionQuestions'] as List<dynamic>? ?? const [];
    final questions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map(ComprehensionQuestion.fromJson)
        .toList();

    return ListeningActivity(
      id: activity.id,
      title: activity.title,
      instruction: activity.instruction,
      level: activity.level,
      mode: mode,
      audioAsset: content['audioAsset'] as String? ?? '',
      transcript: content['transcript'] as String? ?? '',
      question: content['question'] as String?,
      options:
          (content['options'] as List<dynamic>?)?.cast<String>() ?? const [],
      correctAnswer: content['correctAnswer'] as String?,
      acceptedAnswers:
          (content['acceptedAnswers'] as List<dynamic>?)?.cast<String>() ??
          const [],
      missingWords:
          (content['missingWords'] as List<dynamic>?)?.cast<String>() ??
          const [],
      comprehensionQuestions: questions,
      explanation: content['explanation'] as String?,
      estimatedDurationMinutes: activity.estimatedDurationMinutes,
      category: metadata['category'] as String? ?? 'General',
      tags: (metadata['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
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

  ListeningActivity copyWith({
    String? id,
    String? title,
    String? instruction,
    String? level,
    ListeningMode? mode,
    String? audioAsset,
    String? transcript,
    String? question,
    List<String>? options,
    String? correctAnswer,
    List<String>? acceptedAnswers,
    List<String>? missingWords,
    List<ComprehensionQuestion>? comprehensionQuestions,
    String? explanation,
    int? estimatedDurationMinutes,
    String? category,
    List<String>? tags,
  }) {
    return ListeningActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      instruction: instruction ?? this.instruction,
      level: level ?? this.level,
      mode: mode ?? this.mode,
      audioAsset: audioAsset ?? this.audioAsset,
      transcript: transcript ?? this.transcript,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      acceptedAnswers: acceptedAnswers ?? this.acceptedAnswers,
      missingWords: missingWords ?? this.missingWords,
      comprehensionQuestions:
          comprehensionQuestions ?? this.comprehensionQuestions,
      explanation: explanation ?? this.explanation,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}

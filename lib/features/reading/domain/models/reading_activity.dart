import '../../../practice/domain/models/practice_models.dart';
import 'reading_mode.dart';
import 'reading_question.dart';

/// Contextual vocabulary term defined within a reading passage.
class ReadingVocabularyItem {
  const ReadingVocabularyItem({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    this.contextSentence,
  });

  final String word;
  final String partOfSpeech;
  final String definition;
  final String? contextSentence;

  Map<String, dynamic> toJson() => {
    'word': word,
    'partOfSpeech': partOfSpeech,
    'definition': definition,
    'contextSentence': contextSentence,
  };

  factory ReadingVocabularyItem.fromJson(Map<String, dynamic> json) {
    return ReadingVocabularyItem(
      word: json['word'] as String,
      partOfSpeech: json['partOfSpeech'] as String? ?? 'n.',
      definition: json['definition'] as String,
      contextSentence: json['contextSentence'] as String?,
    );
  }
}

/// Domain model representing a structured reading passage activity in Fluentia Reading Lab.
class ReadingActivity {
  const ReadingActivity({
    required this.id,
    required this.title,
    required this.level,
    required this.mode,
    required this.category,
    this.estimatedDurationMinutes = 3,
    required this.passage,
    List<String>? paragraphs,
    required this.questions,
    this.vocabularyItems = const [],
    this.tags = const [],
    this.difficulty = 'Medium',
    this.explanation,
  }) : paragraphs = paragraphs ?? const [];

  final String id;
  final String title;
  final String level;
  final ReadingMode mode;
  final String category;
  final int estimatedDurationMinutes;
  final String passage;
  final List<String> paragraphs;
  final List<ReadingQuestion> questions;
  final List<ReadingVocabularyItem> vocabularyItems;
  final List<String> tags;
  final String difficulty;
  final String? explanation;

  /// Accurately counts whitespace-separated words in the passage text.
  int get wordCount {
    if (passage.trim().isEmpty) return 0;
    return passage.trim().split(RegExp(r'\s+')).length;
  }

  /// Gets the list of paragraphs, falling back to splitting by double newlines if not provided.
  List<String> get effectiveParagraphs {
    if (paragraphs.isNotEmpty) return paragraphs;
    return passage
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// Converts this reading drill into a core PracticeActivity for database persistence.
  PracticeActivity toPracticeActivity() {
    final activityType = switch (mode) {
      ReadingMode.readAndAnswer => PracticeActivityType.readingComprehension,
      ReadingMode.mainIdea => PracticeActivityType.mainIdea,
      ReadingMode.vocabularyInContext =>
        PracticeActivityType.vocabularyInContext,
      ReadingMode.trueFalse => PracticeActivityType.trueFalse,
      ReadingMode.comprehension => PracticeActivityType.readingComprehension,
    };

    return PracticeActivity(
      id: id,
      skill: PracticeSkill.reading,
      type: activityType,
      title: title,
      instruction: mode.description,
      level: level,
      estimatedDurationMinutes: estimatedDurationMinutes,
      difficulty: difficulty,
      content: {
        'passage': passage,
        'questionCount': questions.length,
        'category': category,
        'wordCount': wordCount,
      },
      metadata: {'mode': mode.id, 'tags': tags},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'level': level,
    'mode': mode.id,
    'category': category,
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'passage': passage,
    'paragraphs': paragraphs,
    'questions': questions.map((q) => q.toJson()).toList(),
    'vocabularyItems': vocabularyItems.map((v) => v.toJson()).toList(),
    'tags': tags,
    'difficulty': difficulty,
    'explanation': explanation,
  };

  factory ReadingActivity.fromJson(Map<String, dynamic> json) {
    return ReadingActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      level: json['level'] as String,
      mode: ReadingMode.fromId(json['mode'] as String? ?? 'readAndAnswer'),
      category: json['category'] as String? ?? 'Everyday Life',
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int? ?? 3,
      passage: json['passage'] as String,
      paragraphs:
          (json['paragraphs'] as List<dynamic>?)?.cast<String>() ?? const [],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => ReadingQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          const [],
      vocabularyItems:
          (json['vocabularyItems'] as List<dynamic>?)
              ?.map(
                (v) =>
                    ReadingVocabularyItem.fromJson(v as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      difficulty: json['difficulty'] as String? ?? 'Medium',
      explanation: json['explanation'] as String?,
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';
import 'package:fluentia/features/reading/domain/models/reading_activity.dart';
import 'package:fluentia/features/reading/domain/models/reading_mode.dart';
import 'package:fluentia/features/reading/domain/models/reading_question.dart';

void main() {
  group('ReadingActivity domain tests', () {
    const sampleQuestions = [
      ReadingQuestion(
        id: 'q1',
        type: ReadingQuestionType.multipleChoice,
        question: 'What did Maya order?',
        options: ['Tea', 'Coffee', 'Juice'],
        correctAnswer: 'Coffee',
        explanation: 'The text states Maya ordered black coffee.',
      ),
      ReadingQuestion(
        id: 'q2',
        type: ReadingQuestionType.trueFalse,
        question: 'Maya was in a hurry.',
        correctAnswer: 'False',
        explanation: 'She took her time enjoying the morning.',
      ),
    ];

    const sampleVocab = [
      ReadingVocabularyItem(
        word: 'serene',
        partOfSpeech: 'adj.',
        definition: 'Calm, peaceful, and untroubled.',
        contextSentence: 'The cafe offered a serene atmosphere.',
      ),
    ];

    const testActivity = ReadingActivity(
      id: 'test_reading_01',
      title: 'A Calm Morning',
      category: 'Daily Life',
      level: 'A2',
      mode: ReadingMode.readAndAnswer,
      passage:
          'Maya sat near the window of the quiet cafe. She ordered black coffee and opened her notebook. The cafe offered a serene atmosphere with soft background music.',
      questions: sampleQuestions,
      vocabularyItems: sampleVocab,
      estimatedDurationMinutes: 3,
      tags: ['A2', 'Morning', 'Routine'],
    );

    test('Calculates word count correctly', () {
      expect(testActivity.wordCount, equals(27));
    });

    test('Can convert ReadingActivity to PracticeActivity', () {
      final practiceActivity = testActivity.toPracticeActivity();
      expect(practiceActivity.id, equals('test_reading_01'));
      expect(practiceActivity.skill, equals(PracticeSkill.reading));
      expect(
        practiceActivity.type,
        equals(PracticeActivityType.readingComprehension),
      );
      expect(practiceActivity.difficulty, equals('Medium'));
    });

    test('Translates all ReadingModes to correct PracticeActivityType', () {
      for (final mode in ReadingMode.values) {
        final act = ReadingActivity(
          id: 'test_${mode.id}',
          title: 'Test',
          category: 'Test Category',
          level: 'B1',
          mode: mode,
          passage: 'Test passage with some words.',
          questions: const [],
        );

        final practiceAct = act.toPracticeActivity();
        expect(practiceAct.skill, equals(PracticeSkill.reading));
      }
    });

    test('ReadingQuestion JSON serialization round-trip', () {
      final q = sampleQuestions.first;
      final json = q.toJson();
      final fromJson = ReadingQuestion.fromJson(json);

      expect(fromJson.id, equals(q.id));
      expect(fromJson.type, equals(ReadingQuestionType.multipleChoice));
      expect(fromJson.question, equals(q.question));
      expect(fromJson.options, equals(q.options));
      expect(fromJson.correctAnswer, equals(q.correctAnswer));
      expect(fromJson.explanation, equals(q.explanation));
    });

    test('ReadingVocabularyItem JSON serialization round-trip', () {
      final v = sampleVocab.first;
      final json = v.toJson();
      final fromJson = ReadingVocabularyItem.fromJson(json);

      expect(fromJson.word, equals(v.word));
      expect(fromJson.partOfSpeech, equals(v.partOfSpeech));
      expect(fromJson.definition, equals(v.definition));
      expect(fromJson.contextSentence, equals(v.contextSentence));
    });
  });
}

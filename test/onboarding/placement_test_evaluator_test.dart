import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/onboarding/data/datasources/placement_questions_data.dart';
import 'package:fluentia/features/onboarding/domain/scoring/placement_test_evaluator.dart';

void main() {
  group('PlacementTestEvaluator Tests', () {
    test(
      'All correct answers yield B2 Upper Intermediate with Strong ratings',
      () {
        final answers = <int, int>{};
        for (int i = 0; i < kBundledPlacementQuestions.length; i++) {
          answers[i] = kBundledPlacementQuestions[i].correctAnswerIndex;
        }

        final result = PlacementTestEvaluator.evaluate(
          questions: kBundledPlacementQuestions,
          selectedAnswers: answers,
        );

        expect(result.totalQuestions, equals(12));
        expect(result.correctAnswers, equals(12));
        expect(result.estimatedLevel, equals('B2'));
        expect(result.levelTitle, equals('Upper Intermediate'));
        expect(result.scorePercentage, equals(100.0));

        for (final rating in result.categoryRatings.values) {
          expect(rating, equals('Strong area'));
        }
      },
    );

    test('Mid-range score yields B1 Intermediate', () {
      final answers = <int, int>{};
      // Correct for first 8 questions (66.7%)
      for (int i = 0; i < 8; i++) {
        answers[i] = kBundledPlacementQuestions[i].correctAnswerIndex;
      }
      // Incorrect for remaining
      for (int i = 8; i < 12; i++) {
        answers[i] = (kBundledPlacementQuestions[i].correctAnswerIndex + 1) % 4;
      }

      final result = PlacementTestEvaluator.evaluate(
        questions: kBundledPlacementQuestions,
        selectedAnswers: answers,
      );

      expect(result.correctAnswers, equals(8));
      expect(result.estimatedLevel, equals('B1'));
      expect(result.levelTitle, equals('Intermediate'));
    });

    test('Lower score yields A2 or A1 with helpful guidance', () {
      final answers = <int, int>{};
      // Correct for only 2 questions
      answers[0] = kBundledPlacementQuestions[0].correctAnswerIndex;
      answers[1] = kBundledPlacementQuestions[1].correctAnswerIndex;
      for (int i = 2; i < 12; i++) {
        answers[i] = (kBundledPlacementQuestions[i].correctAnswerIndex + 1) % 4;
      }

      final result = PlacementTestEvaluator.evaluate(
        questions: kBundledPlacementQuestions,
        selectedAnswers: answers,
      );

      expect(result.correctAnswers, equals(2));
      expect(result.estimatedLevel, equals('A1'));
      expect(result.levelTitle, equals('Beginner'));
    });
  });
}

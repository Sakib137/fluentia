import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';
import 'package:fluentia/features/practice/domain/services/practice_recommendation_service.dart';

void main() {
  group('PracticeRecommendationService Tests', () {
    const service = PracticeRecommendationService();

    test('Default balanced ordering when goals list is empty', () {
      final ordered = service.orderSkills([]);
      expect(ordered, [
        PracticeSkill.speaking,
        PracticeSkill.listening,
        PracticeSkill.reading,
        PracticeSkill.writing,
      ]);
    });

    test('Career & business goal prioritizes Speaking then Writing', () {
      final ordered = service.orderSkills([
        'Career & Business',
        'Interview Preparation',
      ]);
      expect(ordered.first, PracticeSkill.speaking);
      expect(ordered[1], PracticeSkill.writing);
      expect(ordered.contains(PracticeSkill.listening), isTrue);
      expect(ordered.contains(PracticeSkill.reading), isTrue);
    });

    test('Exam preparation goal prioritizes Reading then Writing', () {
      final ordered = service.orderSkills(['Exams & Academic', 'IELTS']);
      expect(ordered.first, PracticeSkill.reading);
      expect(ordered[1], PracticeSkill.writing);
    });

    test('Writing-focused goal prioritizes Writing', () {
      final ordered = service.orderSkills(['Writing precision']);
      expect(ordered.first, PracticeSkill.writing);
    });

    test('Deterministic quick practice selection is stable for same date', () {
      final date = DateTime(2026, 9, 7, 10, 0);
      final skill1 = service.selectQuickPracticeSkill(
        userGoals: ['Career'],
        date: date,
      );
      final skill2 = service.selectQuickPracticeSkill(
        userGoals: ['Career'],
        date: date,
      );
      expect(skill1, equals(skill2));
    });

    test(
      'Quick practice selection alternates across adjacent days for variety',
      () {
        final day1 = DateTime(2026, 9, 7);
        final day2 = DateTime(2026, 9, 8);
        final skillDay1 = service.selectQuickPracticeSkill(
          userGoals: ['Career'],
          date: day1,
        );
        final skillDay2 = service.selectQuickPracticeSkill(
          userGoals: ['Career'],
          date: day2,
        );
        expect(skillDay1, isNot(equals(skillDay2)));
      },
    );
  });
}

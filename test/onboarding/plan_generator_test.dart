import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/onboarding/domain/scoring/plan_generator.dart';

void main() {
  group('PlanGenerator Tests', () {
    test('Plan allocations sum exactly to daily target for all standard intervals', () {
      final targetTimes = [5, 10, 15, 20, 30];

      for (final minutes in targetTimes) {
        final plan = PlanGenerator.generatePlan(
          dailyMinutes: minutes,
          selectedGoals: ['Speaking', 'Vocabulary'],
        );

        final totalAllocated = plan.values.fold<int>(0, (sum, val) => sum + val);
        expect(
          totalAllocated,
          equals(minutes),
          reason: 'Total allocated minutes must strictly equal $minutes',
        );
      }
    });

    test('Selected goal receives higher priority and weighting in plan', () {
      final speakingPlan = PlanGenerator.generatePlan(
        dailyMinutes: 15,
        selectedGoals: ['Speaking', 'Pronunciation'],
      );

      final vocabPlan = PlanGenerator.generatePlan(
        dailyMinutes: 15,
        selectedGoals: ['Vocabulary'],
      );

      expect(
        speakingPlan['Speaking']!,
        greaterThanOrEqualTo(speakingPlan['Grammar']!),
      );

      expect(
        vocabPlan['Vocabulary']!,
        greaterThanOrEqualTo(vocabPlan['Speaking']!),
      );
    });

    test('15-minute plan allocates minutes across all 5 skills', () {
      final plan = PlanGenerator.generatePlan(
        dailyMinutes: 15,
        selectedGoals: ['Everyday Conversation', 'Vocabulary'],
      );

      expect(plan.length, equals(5));
      for (final minutes in plan.values) {
        expect(minutes, greaterThan(0));
      }
      expect(plan.values.reduce((a, b) => a + b), equals(15));
    });
  });
}

import 'package:fluentia/features/home/domain/daily_challenge_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyChallengeGenerator Tests', () {
    final testDate = DateTime.utc(2026, 9, 7);

    test('Generates exactly 5 activities for a calendar date', () {
      final challenge = DailyChallengeGenerator.generate(date: testDate);

      expect(challenge.items.length, 5);
      expect(challenge.dateKey, '2026-09-07');
      expect(challenge.completedCount, 0);
      expect(challenge.isAllCompleted, isFalse);
      expect(challenge.progressFraction, 0.0);
    });

    test('Is deterministic for the same calendar date', () {
      final challenge1 = DailyChallengeGenerator.generate(date: testDate);
      final challenge2 = DailyChallengeGenerator.generate(date: testDate);

      expect(challenge1.items.length, challenge2.items.length);
      for (int i = 0; i < challenge1.items.length; i++) {
        expect(challenge1.items[i].id, challenge2.items[i].id);
        expect(challenge1.items[i].title, challenge2.items[i].title);
        expect(challenge1.items[i].skillType, challenge2.items[i].skillType);
      }
    });

    test('Correctly maps completed item IDs and calculates progress fraction', () {
      final initialChallenge = DailyChallengeGenerator.generate(date: testDate);
      final firstItemId = initialChallenge.items[0].id;
      final secondItemId = initialChallenge.items[1].id;

      final updatedChallenge = DailyChallengeGenerator.generate(
        date: testDate,
        completedItemIds: {firstItemId, secondItemId},
      );

      expect(updatedChallenge.completedCount, 2);
      expect(updatedChallenge.totalCount, 5);
      expect(updatedChallenge.progressFraction, 0.4);
      expect(updatedChallenge.items[0].isCompleted, isTrue);
      expect(updatedChallenge.items[1].isCompleted, isTrue);
      expect(updatedChallenge.items[2].isCompleted, isFalse);
      expect(updatedChallenge.isAllCompleted, isFalse);
    });

    test('Full completion reports isAllCompleted = true and 1.0 progress fraction', () {
      final initialChallenge = DailyChallengeGenerator.generate(date: testDate);
      final allIds = initialChallenge.items.map((e) => e.id).toSet();

      final fullChallenge = DailyChallengeGenerator.generate(
        date: testDate,
        completedItemIds: allIds,
      );

      expect(fullChallenge.completedCount, 5);
      expect(fullChallenge.isAllCompleted, isTrue);
      expect(fullChallenge.progressFraction, 1.0);
    });
  });
}

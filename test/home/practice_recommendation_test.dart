import 'package:fluentia/features/home/domain/practice_recommendation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PracticeRecommendationEngine Tests', () {
    test('Default balanced ordering when goals list is empty', () {
      final items = PracticeRecommendationEngine.rankRecommendations([]);

      expect(items.length, 4);
      expect(items.any((e) => e.isPrimaryGoal), isFalse);
      expect(items.map((e) => e.skillType).toList(), [
        'Speaking',
        'Listening',
        'Reading',
        'Writing',
      ]);
    });

    test('Career & business goal prioritizes Speaking and Writing', () {
      final items = PracticeRecommendationEngine.rankRecommendations([
        'career_business',
      ]);

      expect(items.length, 4);
      final topSkills = items.sublist(0, 2).map((e) => e.skillType).toSet();
      expect(topSkills, contains('Speaking'));
      expect(topSkills, contains('Writing'));

      final primaryItems = items.where((e) => e.isPrimaryGoal).toList();
      expect(primaryItems.length, 2);
    });

    test('Exams & tests goal prioritizes Reading and Writing', () {
      final items = PracticeRecommendationEngine.rankRecommendations([
        'exams_tests',
      ]);

      expect(items.length, 4);
      final topSkills = items.sublist(0, 2).map((e) => e.skillType).toSet();
      expect(topSkills, contains('Reading'));
      expect(topSkills, contains('Writing'));

      final primaryItems = items.where((e) => e.isPrimaryGoal).toList();
      expect(primaryItems.length, 2);
    });

    test('Casual conversation goal prioritizes Speaking and Listening', () {
      final items = PracticeRecommendationEngine.rankRecommendations([
        'casual_conversation',
      ]);

      expect(items.length, 4);
      final topSkills = items.sublist(0, 2).map((e) => e.skillType).toSet();
      expect(topSkills, contains('Speaking'));
      expect(topSkills, contains('Listening'));
    });
  });
}

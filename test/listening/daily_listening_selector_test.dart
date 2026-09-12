import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/listening/data/datasources/listening_content.dart';
import 'package:fluentia/features/listening/domain/services/daily_listening_selector.dart';

void main() {
  group('DailyListeningSelector tests', () {
    final activities = ListeningContent.activities;

    test('Selection is stable across calls on the same calendar day', () {
      final today = DateTime(2026, 9, 12, 10, 30);
      final todayLater = DateTime(2026, 9, 12, 23, 59);

      final selected1 = DailyListeningSelector.select(
        activities: activities,
        date: today,
      );
      final selected2 = DailyListeningSelector.select(
        activities: activities,
        date: todayLater,
      );

      expect(selected1.id, equals(selected2.id));
      expect(selected1.title, equals(selected2.title));
    });

    test('Selection varies across different calendar dates', () {
      final day1 = DateTime(2026, 9, 12);
      final day2 = DateTime(2026, 9, 13);
      final day3 = DateTime(2026, 9, 14);

      final sel1 = DailyListeningSelector.select(
        activities: activities,
        date: day1,
      );
      final sel2 = DailyListeningSelector.select(
        activities: activities,
        date: day2,
      );
      final sel3 = DailyListeningSelector.select(
        activities: activities,
        date: day3,
      );

      // At least one adjacent date should differ with multiple activities
      expect(sel1.id != sel2.id || sel2.id != sel3.id, isTrue);
    });

    test('Throws ArgumentError when activities list is empty', () {
      expect(
        () =>
            DailyListeningSelector.select(activities: [], date: DateTime.now()),
        throwsArgumentError,
      );
    });
  });
}

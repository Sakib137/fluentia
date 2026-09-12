import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/reading/data/datasources/reading_content.dart';
import 'package:fluentia/features/reading/domain/services/daily_reading_selector.dart';

void main() {
  group('DailyReadingSelector unit tests', () {
    final all = ReadingContent.activities;

    test('Returns identical daily reading for the same date and level', () {
      final date = DateTime(2026, 9, 12);
      final selection1 = DailyReadingSelector.select(
        activities: all,
        date: date,
        targetLevel: 'B1',
      );
      final selection2 = DailyReadingSelector.select(
        activities: all,
        date: date,
        targetLevel: 'B1',
      );

      expect(selection1.id, equals(selection2.id));
      expect(selection1.level, equals('B1'));
    });

    test('Selects from target level when available', () {
      for (final level in ['A1', 'A2', 'B1', 'B2', 'C1']) {
        final selection = DailyReadingSelector.select(
          activities: all,
          date: DateTime(2026, 9, 12),
          targetLevel: level,
        );
        expect(selection.level.toUpperCase(), equals(level));
      }
    });

    test(
      'Rotates or deterministically yields valid activity across consecutive days',
      () {
        final day1 = DailyReadingSelector.select(
          activities: all,
          date: DateTime(2026, 9, 1),
          targetLevel: 'B1',
        );
        final day2 = DailyReadingSelector.select(
          activities: all,
          date: DateTime(2026, 9, 2),
          targetLevel: 'B1',
        );

        expect(day1, isNotNull);
        expect(day2, isNotNull);
        expect(all.contains(day1), isTrue);
        expect(all.contains(day2), isTrue);
      },
    );

    test('Falls back gracefully if requested level has no activities', () {
      final selection = DailyReadingSelector.select(
        activities: all,
        date: DateTime(2026, 9, 12),
        targetLevel: 'NonExistentLevel',
      );

      expect(selection, isNotNull);
      expect(all.contains(selection), isTrue);
    });
  });
}

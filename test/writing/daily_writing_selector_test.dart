import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/writing/data/datasources/writing_content.dart';
import 'package:fluentia/features/writing/domain/services/daily_writing_selector.dart';

void main() {
  group('DailyWritingSelector Service Tests', () {
    test(
      'Deterministically yields the same activity for identical calendar date',
      () {
        final dateA = DateTime(2026, 9, 12, 10, 0);
        final dateB = DateTime(2026, 9, 12, 23, 45);

        final selectedA = DailyWritingSelector.selectDailyActivity(
          activities: WritingContent.activities,
          date: dateA,
        );

        final selectedB = DailyWritingSelector.selectDailyActivity(
          activities: WritingContent.activities,
          date: dateB,
        );

        expect(selectedA.id, selectedB.id);
      },
    );

    test('Adapts daily challenge to user CEFR level when specified', () {
      final targetDate = DateTime(2026, 9, 15);

      final b2Activity = DailyWritingSelector.selectDailyActivity(
        activities: WritingContent.activities,
        date: targetDate,
        userLevel: 'B2',
      );

      expect(b2Activity.level, 'B2');

      final a1Activity = DailyWritingSelector.selectDailyActivity(
        activities: WritingContent.activities,
        date: targetDate,
        userLevel: 'A1',
      );

      expect(a1Activity.level, 'A1');
    });

    test('Throws ArgumentError if empty activities provided', () {
      expect(
        () => DailyWritingSelector.selectDailyActivity(activities: []),
        throwsArgumentError,
      );
    });
  });
}

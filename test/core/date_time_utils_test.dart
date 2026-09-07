import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('formatDuration formats minutes and seconds properly', () {
      expect(
        DateTimeUtils.formatDuration(const Duration(minutes: 5, seconds: 30)),
        equals('05:30'),
      );
      expect(
        DateTimeUtils.formatDuration(
          const Duration(hours: 1, minutes: 15, seconds: 5),
        ),
        equals('01:15:05'),
      );
    });

    test('isSameDay accurately detects identical and different days', () {
      final d1 = DateTime(2026, 9, 7, 10, 30);
      final d2 = DateTime(2026, 9, 7, 21, 45);
      final d3 = DateTime(2026, 9, 8, 10, 30);

      expect(DateTimeUtils.isSameDay(d1, d2), isTrue);
      expect(DateTimeUtils.isSameDay(d1, d3), isFalse);
    });

    test('toDateString formats to YYYY-MM-DD', () {
      final date = DateTime(2026, 9, 7);
      expect(DateTimeUtils.toDateString(date), equals('2026-09-07'));
    });
  });
}

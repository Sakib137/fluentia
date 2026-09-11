import 'package:fluentia/features/home/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakCalculator Tests', () {
    final referenceToday = DateTime.utc(2026, 9, 7);

    test('Empty active dates returns 0 streak and false maintained', () {
      final result = StreakCalculator.calculate(
        activeDates: [],
        today: referenceToday,
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.isMaintainedToday, isFalse);
      expect(result.lastActiveDate, isNull);
    });

    test(
      'Practiced today produces 1 day streak and maintainedToday = true',
      () {
        final result = StreakCalculator.calculate(
          activeDates: [referenceToday],
          today: referenceToday,
        );

        expect(result.currentStreak, 1);
        expect(result.longestStreak, 1);
        expect(result.isMaintainedToday, isTrue);
        expect(result.lastActiveDate, referenceToday);
      },
    );

    test(
      'Practiced yesterday but not today preserves active streak with isMaintainedToday = false',
      () {
        final yesterday = referenceToday.subtract(const Duration(days: 1));
        final twoDaysAgo = referenceToday.subtract(const Duration(days: 2));

        final result = StreakCalculator.calculate(
          activeDates: [yesterday, twoDaysAgo],
          today: referenceToday,
        );

        expect(result.currentStreak, 2);
        expect(result.longestStreak, 2);
        expect(result.isMaintainedToday, isFalse);
        expect(result.lastActiveDate, yesterday);
      },
    );

    test('Missed yesterday resets current streak to 0', () {
      final twoDaysAgo = referenceToday.subtract(const Duration(days: 2));
      final threeDaysAgo = referenceToday.subtract(const Duration(days: 3));

      final result = StreakCalculator.calculate(
        activeDates: [twoDaysAgo, threeDaysAgo],
        today: referenceToday,
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 2);
      expect(result.isMaintainedToday, isFalse);
    });

    test('Deduplicates multiple sessions on the same calendar day', () {
      final todayMorning = DateTime.utc(2026, 9, 7, 8, 30);
      final todayEvening = DateTime.utc(2026, 9, 7, 20, 15);
      final yesterdayNoon = DateTime.utc(2026, 9, 6, 12, 0);

      final result = StreakCalculator.calculate(
        activeDates: [todayMorning, todayEvening, yesterdayNoon],
        today: referenceToday,
      );

      expect(result.currentStreak, 2);
      expect(result.longestStreak, 2);
      expect(result.isMaintainedToday, isTrue);
    });

    test('Correctly computes longest streak across historical gap', () {
      // Historical 4-day streak in January 2026
      final oldStreak = [
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 1, 11),
        DateTime.utc(2026, 1, 12),
        DateTime.utc(2026, 1, 13),
      ];

      // Current 2-day streak in September 2026
      final currentStreak = [
        DateTime.utc(2026, 9, 6),
        DateTime.utc(2026, 9, 7),
      ];

      final result = StreakCalculator.calculate(
        activeDates: [...oldStreak, ...currentStreak],
        today: referenceToday,
      );

      expect(result.currentStreak, 2);
      expect(result.longestStreak, 4);
      expect(result.isMaintainedToday, isTrue);
    });
  });
}

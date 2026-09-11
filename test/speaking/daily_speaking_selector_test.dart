import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/speaking/data/datasources/speaking_content.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_activity.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_mode.dart';
import 'package:fluentia/features/speaking/domain/services/daily_speaking_selector.dart';

void main() {
  group('DailySpeakingSelector Tests', () {
    final activities = SpeakingContent.activities;

    test('Same date always yields identical activity', () {
      final date = DateTime(2026, 9, 11);
      final first = DailySpeakingSelector.select(
        activities: activities,
        date: date,
      );
      final second = DailySpeakingSelector.select(
        activities: activities,
        date: date,
      );

      expect(first.id, second.id);
      expect(first.title, second.title);
    });

    test('Consecutive days cycle deterministically', () {
      final day1 = DateTime(2026, 9, 11);
      final day2 = DateTime(2026, 9, 12);
      final day3 = DateTime(2026, 9, 13);

      final act1 = DailySpeakingSelector.select(
        activities: activities,
        date: day1,
      );
      final act2 = DailySpeakingSelector.select(
        activities: activities,
        date: day2,
      );
      final act3 = DailySpeakingSelector.select(
        activities: activities,
        date: day3,
      );

      // Verify all are valid activities in pool
      expect(act1, isNotNull);
      expect(act2, isNotNull);
      expect(act3, isNotNull);

      // Verify they belong to daily speaking or speak about it pool
      expect(
        act1.mode == SpeakingMode.dailySpeaking ||
            act1.mode == SpeakingMode.speakAboutIt,
        isTrue,
      );
      expect(
        act2.mode == SpeakingMode.dailySpeaking ||
            act2.mode == SpeakingMode.speakAboutIt,
        isTrue,
      );
    });

    test('Throws ArgumentError if activities list is empty', () {
      expect(
        () =>
            DailySpeakingSelector.select(activities: [], date: DateTime.now()),
        throwsArgumentError,
      );
    });

    test(
      'Fallback to any activity if no dailySpeaking or speakAboutIt exist',
      () {
        const readAloudOnly = [
          SpeakingActivity(
            id: 'ra_only',
            title: 'Read Only',
            prompt: 'Read',
            instruction: 'Read',
            level: 'A1',
            mode: SpeakingMode.readAloud,
          ),
        ];

        final selected = DailySpeakingSelector.select(
          activities: readAloudOnly,
          date: DateTime(2026, 1, 1),
        );

        expect(selected.id, 'ra_only');
      },
    );
  });
}

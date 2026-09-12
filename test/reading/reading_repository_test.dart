import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/reading/data/repositories/reading_repository_impl.dart';
import 'package:fluentia/features/reading/domain/models/reading_mode.dart';

void main() {
  group('ReadingRepositoryImpl tests', () {
    const repository = ReadingRepositoryImpl();

    test('getActivities returns all seeded reading activities', () async {
      final activities = await repository.getActivities();
      expect(activities, isNotEmpty);
      expect(activities.length, greaterThanOrEqualTo(8));
    });

    test('getActivityById returns the correct activity or null', () async {
      final activities = await repository.getActivities();
      final target = activities.first;

      final found = await repository.getActivityById(target.id);
      expect(found, isNotNull);
      expect(found!.id, equals(target.id));

      final notFound = await repository.getActivityById('non_existent_id');
      expect(notFound, isNull);
    });

    test('getActivitiesForMode filters correctly', () async {
      for (final mode in ReadingMode.values) {
        final filtered = await repository.getActivitiesForMode(mode);
        for (final item in filtered) {
          expect(item.mode, equals(mode));
        }
      }
    });

    test('getActivitiesForLevel filters by CEFR level', () async {
      for (final level in ['A1', 'A2', 'B1', 'B2', 'C1']) {
        final filtered = await repository.getActivitiesForLevel(level);
        for (final item in filtered) {
          expect(item.level.toUpperCase(), equals(level));
        }
      }
    });

    test('getDailyReading returns an activity', () async {
      final daily = await repository.getDailyReading(
        date: DateTime.now(),
        userLevel: 'B1',
      );
      expect(daily, isNotNull);
      expect(daily.level, equals('B1'));
    });
  });
}

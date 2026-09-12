import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/writing/data/repositories/writing_repository_impl.dart';
import 'package:fluentia/features/writing/domain/models/writing_mode.dart';

void main() {
  group('WritingRepository Tests', () {
    late WritingRepositoryImpl repo;

    setUp(() {
      repo = const WritingRepositoryImpl();
    });

    test('Fetches all available activities', () async {
      final activities = await repo.getActivities();
      expect(activities.isNotEmpty, isTrue);
      expect(activities.length, greaterThanOrEqualTo(15));
    });

    test('Filters activities by CEFR level', () async {
      final b1Activities = await repo.getActivitiesForLevel('B1');
      expect(b1Activities.isNotEmpty, isTrue);
      expect(b1Activities.every((a) => a.level == 'B1'), isTrue);
    });

    test('Retrieves activity by ID and handles invalid IDs', () async {
      final activity = await repo.getActivityById('wr-a1-sb-01');
      expect(activity, isNotNull);
      expect(activity!.id, 'wr-a1-sb-01');
      expect(activity.mode, WritingMode.sentenceBuilder);

      final notFound = await repo.getActivityById('non-existent-id');
      expect(notFound, isNull);
    });

    test('Filters activities by WritingMode', () async {
      final sentenceBuilders = await repo.getActivitiesForMode(
        WritingMode.sentenceBuilder,
      );
      expect(sentenceBuilders.isNotEmpty, isTrue);
      expect(
        sentenceBuilders.every((a) => a.mode == WritingMode.sentenceBuilder),
        isTrue,
      );

      final guidedWritings = await repo.getActivitiesForMode(
        WritingMode.guidedWriting,
      );
      expect(guidedWritings.isNotEmpty, isTrue);
      expect(
        guidedWritings.every((a) => a.mode == WritingMode.guidedWriting),
        isTrue,
      );
    });

    test('Filters activities by category', () async {
      final workActivities = await repo.getActivitiesByCategory(
        'Workplace & Business',
      );
      expect(workActivities.isNotEmpty, isTrue);
      expect(
        workActivities.every(
          (a) => a.category.toLowerCase().contains('workplace'),
        ),
        isTrue,
      );
    });

    test(
      'Provides recommendations prioritized by level and uncompleted',
      () async {
        final recs = await repo.getRecommendedActivities(
          userLevel: 'B2',
          completedIds: ['wr-b2-sb-01'],
        );
        expect(recs.isNotEmpty, isTrue);
        expect(recs.any((a) => a.id == 'wr-b2-sb-01'), isFalse);
      },
    );
  });
}

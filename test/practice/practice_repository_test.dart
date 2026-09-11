import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/practice/data/repositories/practice_repository.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('SqlitePracticeRepository Tests', () {
    late FakeDatabaseService fakeDb;
    late SqlitePracticeRepository repository;

    setUp(() async {
      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();
      repository = SqlitePracticeRepository(fakeDb);
    });

    test('Retrieves activities filtered by skill', () async {
      final speakingActivities = await repository.getActivitiesBySkill(
        PracticeSkill.speaking,
      );
      expect(speakingActivities, isNotEmpty);
      expect(
        speakingActivities.every((a) => a.skill == PracticeSkill.speaking),
        isTrue,
      );

      final writingActivities = await repository.getActivitiesBySkill(
        PracticeSkill.writing,
      );
      expect(writingActivities, isNotEmpty);
      expect(
        writingActivities.every((a) => a.skill == PracticeSkill.writing),
        isTrue,
      );
    });

    test('Retrieves activities filtered by level', () async {
      final b1Activities = await repository.getActivitiesByLevel('B1');
      expect(b1Activities, isNotEmpty);
      expect(b1Activities.every((a) => a.level == 'B1'), isTrue);
    });

    test('Retrieves activity by id', () async {
      final activity = await repository.getActivityById('spk_a1_01');
      expect(activity, isNotNull);
      expect(activity!.title, 'Daily Routine Overview');
      expect(activity.skill, PracticeSkill.speaking);

      final notFound = await repository.getActivityById('non_existent_id');
      expect(notFound, isNull);
    });

    test('Selects recommended activity based on goals and level', () async {
      final recommended = await repository.getRecommendedActivity(
        level: 'B1',
        goals: ['Career & Business'],
        date: DateTime(2026, 9, 7),
      );
      expect(recommended, isNotNull);
      expect(
        recommended.skill,
        anyOf(PracticeSkill.speaking, PracticeSkill.writing),
      );
    });

    test(
      'Saving completed session updates PracticeSessions and UserProgress tables',
      () async {
        final now = DateTime(2026, 9, 7, 15, 30);
        final session = PracticeSession(
          id: 'session_test_1',
          skill: PracticeSkill.speaking,
          activityIds: ['spk_b1_01'],
          level: 'B1',
          startedAt: now.subtract(const Duration(minutes: 5)),
          completedAt: now,
          durationSeconds: 300,
          score: 92.0,
          status: PracticeSessionStatus.completed,
          totalActivities: 1,
        );

        await repository.saveSession(session);

        // Verify session logged
        final history = await repository.getSessionHistory();
        expect(history.length, 1);
        expect(history.first.id, 'session_test_1');
        expect(history.first.isCompleted, isTrue);

        // Verify today practice minutes credited (5 minutes)
        final todayMinutes = await repository.getTodayPracticeMinutes(
          date: now,
        );
        expect(todayMinutes, 5);
      },
    );

    test(
      'Saving abandoned session logs session without adding practice minutes',
      () async {
        final now = DateTime(2026, 9, 7, 16, 0);
        final session = PracticeSession(
          id: 'session_abandoned_1',
          skill: PracticeSkill.listening,
          activityIds: ['lis_b1_01'],
          level: 'B1',
          startedAt: now.subtract(const Duration(minutes: 2)),
          completedAt: now,
          durationSeconds: 120,
          status: PracticeSessionStatus.abandoned,
          totalActivities: 1,
        );

        await repository.saveSession(session);

        // Verify session in history with abandoned status
        final history = await repository.getSessionHistory();
        expect(history.length, 1);
        expect(history.first.isAbandoned, isTrue);

        // Verify NO minutes were credited in UserProgressTable
        final todayMinutes = await repository.getTodayPracticeMinutes(
          date: now,
        );
        expect(todayMinutes, 0);
      },
    );
  });
}

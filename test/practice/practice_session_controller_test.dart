import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';
import 'package:fluentia/features/practice/presentation/providers/practice_providers.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('PracticeSessionController Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;

    setUp(() async {
      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();

      container = ProviderContainer(
        overrides: [databaseServiceProvider.overrideWithValue(fakeDb)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state has no active session', () {
      final state = container.read(practiceSessionControllerProvider);
      expect(state.session, isNull);
      expect(state.activities, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test(
      'initializeSession loads activities and builds unstarted session',
      () async {
        final controller = container.read(
          practiceSessionControllerProvider.notifier,
        );
        await controller.initializeSession(
          skill: PracticeSkill.speaking,
          level: 'B1',
        );

        final state = container.read(practiceSessionControllerProvider);
        expect(state.session, isNotNull);
        expect(state.session!.status, PracticeSessionStatus.notStarted);
        expect(state.activities, isNotEmpty);
        expect(state.currentActivity, isNotNull);
        expect(state.session!.currentActivityIndex, 0);
      },
    );

    test('startSession transitions status to inProgress', () async {
      final controller = container.read(
        practiceSessionControllerProvider.notifier,
      );
      await controller.initializeSession(skill: PracticeSkill.listening);
      controller.startSession();

      final state = container.read(practiceSessionControllerProvider);
      expect(state.session!.isInProgress, isTrue);
    });

    test('nextActivity advances current activity index', () async {
      final controller = container.read(
        practiceSessionControllerProvider.notifier,
      );
      await controller.initializeSession(skill: PracticeSkill.reading);
      controller.startSession();

      expect(
        container
            .read(practiceSessionControllerProvider)
            .session!
            .currentActivityIndex,
        0,
      );

      controller.nextActivity();
      expect(
        container
            .read(practiceSessionControllerProvider)
            .session!
            .currentActivityIndex,
        1,
      );
    });

    test(
      'completeSession marks completed and persists to repository',
      () async {
        final controller = container.read(
          practiceSessionControllerProvider.notifier,
        );
        await controller.initializeSession(skill: PracticeSkill.writing);
        controller.startSession();

        final completed = await controller.completeSession(score: 95.0);
        expect(completed, isNotNull);
        expect(completed!.isCompleted, isTrue);
        expect(completed.score, 95.0);
        expect(completed.durationSeconds, greaterThan(0));

        // Verify saved in repository history
        final history = await container
            .read(practiceRepositoryProvider)
            .getSessionHistory();
        expect(history.length, 1);
        expect(history.first.isCompleted, isTrue);
      },
    );

    test('abandonSession marks status as abandoned', () async {
      final controller = container.read(
        practiceSessionControllerProvider.notifier,
      );
      await controller.initializeSession(skill: PracticeSkill.speaking);
      controller.startSession();

      await controller.abandonSession();

      final state = container.read(practiceSessionControllerProvider);
      expect(state.session!.isAbandoned, isTrue);

      final history = await container
          .read(practiceRepositoryProvider)
          .getSessionHistory();
      expect(history.length, 1);
      expect(history.first.isAbandoned, isTrue);
    });
  });
}

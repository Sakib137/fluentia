import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/listening/data/datasources/listening_content.dart';
import 'package:fluentia/features/listening/domain/models/listening_mode.dart';
import 'package:fluentia/features/listening/presentation/providers/listening_providers.dart';
import 'package:fluentia/features/listening/presentation/providers/listening_session_controller.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';

import '../helpers/fake_database_service.dart';
import 'audio_player_service_test.dart';

void main() {
  group('ListeningSessionController Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late FakeAudioPlayerService fakeAudioService;
    late SharedPreferences prefs;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();

      fakeAudioService = FakeAudioPlayerService();
      await fakeAudioService.initialize();

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDb),
          sharedPreferencesProvider.overrideWithValue(prefs),
          audioPlayerServiceProvider.overrideWithValue(fakeAudioService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is empty', () {
      final state = container.read(listeningSessionControllerProvider);
      expect(state.activity, isNull);
      expect(state.session, isNull);
      expect(state.isSubmitted, isFalse);
      expect(state.isCompleted, isFalse);
    });

    test(
      'initializeActivity loads activity and creates inProgress PracticeSession',
      () async {
        final activity = ListeningContent.activities.first;
        final controller = container.read(
          listeningSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);

        final state = container.read(listeningSessionControllerProvider);
        expect(state.activity, equals(activity));
        expect(state.session, isNotNull);
        expect(state.session!.skill, equals(PracticeSkill.listening));
        expect(state.session!.status, equals(PracticeSessionStatus.inProgress));
        expect(
          fakeAudioService.snapshot.currentAsset,
          equals(activity.audioAsset),
        );
      },
    );

    test('Listen & Choose submission and scoring', () async {
      final lacActivity = ListeningContent.activities.firstWhere(
        (a) => a.mode == ListeningMode.listenAndChoose,
      );
      final controller = container.read(
        listeningSessionControllerProvider.notifier,
      );

      await controller.initializeActivity(lacActivity);

      // Select wrong answer
      controller.selectOption('Wrong Answer');
      expect(
        container.read(listeningSessionControllerProvider).canSubmit,
        isTrue,
      );

      controller.submitAnswer();
      var state = container.read(listeningSessionControllerProvider);
      expect(state.isSubmitted, isTrue);
      expect(state.isCorrect, isFalse);
      expect(state.scorePercentage, equals(0.0));

      // Re-initialize and select correct answer
      await controller.initializeActivity(lacActivity);
      controller.selectOption(lacActivity.correctAnswer!);
      controller.submitAnswer();
      state = container.read(listeningSessionControllerProvider);
      expect(state.isSubmitted, isTrue);
      expect(state.isCorrect, isTrue);
      expect(state.scorePercentage, equals(100.0));
    });

    test('Dictation submission and accuracy scoring', () async {
      final dictActivity = ListeningContent.activities.firstWhere(
        (a) => a.mode == ListeningMode.dictation,
      );
      final controller = container.read(
        listeningSessionControllerProvider.notifier,
      );

      await controller.initializeActivity(dictActivity);
      controller.updateDictationInput(dictActivity.transcript);
      controller.submitAnswer();

      final state = container.read(listeningSessionControllerProvider);
      expect(state.isSubmitted, isTrue);
      expect(state.isCorrect, isTrue);
      expect(state.scorePercentage, equals(100.0));
      expect(state.dictationResult, isNotNull);
      expect(state.dictationResult!.isExactMatch, isTrue);
    });

    test('Fill in the Missing Words submission and scoring', () async {
      final fillActivity = ListeningContent.activities.firstWhere(
        (a) => a.mode == ListeningMode.fillMissingWords,
      );
      final controller = container.read(
        listeningSessionControllerProvider.notifier,
      );

      await controller.initializeActivity(fillActivity);
      for (var i = 0; i < fillActivity.missingWords.length; i++) {
        controller.updateMissingWord(i, fillActivity.missingWords[i]);
      }
      controller.submitAnswer();

      final state = container.read(listeningSessionControllerProvider);
      expect(state.isSubmitted, isTrue);
      expect(state.isCorrect, isTrue);
      expect(state.scorePercentage, equals(100.0));
    });

    test('Comprehension multi-question progression', () async {
      final compActivity = ListeningContent.activities.firstWhere(
        (a) => a.mode == ListeningMode.comprehension,
      );
      final controller = container.read(
        listeningSessionControllerProvider.notifier,
      );

      await controller.initializeActivity(compActivity);

      final q1 = compActivity.comprehensionQuestions[0];
      controller.selectComprehensionOption(q1.id, q1.correctAnswer);
      controller.submitAnswer();

      var state = container.read(listeningSessionControllerProvider);
      expect(state.isSubmitted, isTrue);
      expect(state.isCorrect, isTrue);

      controller.nextComprehensionQuestion();
      state = container.read(listeningSessionControllerProvider);
      expect(state.currentComprehensionIndex, equals(1));
      expect(state.isSubmitted, isFalse);
    });

    test(
      'completeSession saves session to PracticeRepository and marks completed',
      () async {
        final activity = ListeningContent.activities.first;
        final controller = container.read(
          listeningSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);
        controller.selectOption(activity.correctAnswer ?? '');
        controller.submitAnswer();

        final completedSession = await controller.completeSession();
        expect(completedSession, isNotNull);
        expect(
          completedSession!.status,
          equals(PracticeSessionStatus.completed),
        );
        expect(completedSession.skill, equals(PracticeSkill.listening));
        expect(completedSession.durationSeconds, greaterThan(0));

        final state = container.read(listeningSessionControllerProvider);
        expect(state.isCompleted, isTrue);

        // Verify continue-listening key was cleared
        expect(prefs.getString(kContinueListeningActivityIdKey), isNull);
      },
    );
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';
import 'package:fluentia/features/reading/data/datasources/reading_content.dart';
import 'package:fluentia/features/reading/presentation/providers/reading_providers.dart';
import 'package:fluentia/features/reading/presentation/providers/reading_session_controller.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('ReadingSessionController Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late SharedPreferences prefs;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDb),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state has default values', () {
      final state = container.read(readingSessionControllerProvider);
      expect(state.activity, isNull);
      expect(state.session, isNull);
      expect(state.isPassagePhase, isTrue);
      expect(state.isSubmitted, isFalse);
      expect(state.isCompleted, isFalse);
      expect(state.fontSizeDelta, equals(0.0));
    });

    test(
      'initializeActivity loads activity and creates inProgress PracticeSession',
      () async {
        final activity = ReadingContent.activities.first;
        final controller = container.read(
          readingSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);

        final state = container.read(readingSessionControllerProvider);
        expect(state.activity, equals(activity));
        expect(state.session, isNotNull);
        expect(state.session!.skill, equals(PracticeSkill.reading));
        expect(state.session!.status, equals(PracticeSessionStatus.inProgress));
        expect(state.isPassagePhase, isTrue);

        // Verify continue reading markers are stored
        expect(
          prefs.getString(kContinueReadingActivityIdKey),
          equals(activity.id),
        );
      },
    );

    test('Font size adjustments are clamped between -4.0 and 6.0', () {
      final controller = container.read(
        readingSessionControllerProvider.notifier,
      );

      controller.setFontSizeDelta(2.0);
      expect(
        container.read(readingSessionControllerProvider).fontSizeDelta,
        equals(2.0),
      );

      // Exceed upper bound (clamped to 6.0)
      controller.setFontSizeDelta(10.0);
      expect(
        container.read(readingSessionControllerProvider).fontSizeDelta,
        equals(6.0),
      );

      // Decrease beyond lower bound (clamped to -4.0)
      controller.setFontSizeDelta(-20.0);
      expect(
        container.read(readingSessionControllerProvider).fontSizeDelta,
        equals(-4.0),
      );

      // Reset
      controller.resetFontSize();
      expect(
        container.read(readingSessionControllerProvider).fontSizeDelta,
        equals(0.0),
      );
    });

    test('Progresses from passage reading phase to questions phase', () async {
      final activity = ReadingContent.activities.first;
      final controller = container.read(
        readingSessionControllerProvider.notifier,
      );

      await controller.initializeActivity(activity);
      expect(
        container.read(readingSessionControllerProvider).isPassagePhase,
        isTrue,
      );

      controller.setPassagePhase(false);
      expect(
        container.read(readingSessionControllerProvider).isPassagePhase,
        isFalse,
      );
      expect(
        container.read(readingSessionControllerProvider).currentQuestionIndex,
        equals(0),
      );
    });

    test(
      'Answers questions, evaluates correctness, and completes session',
      () async {
        final activity = ReadingContent.activities.first;
        final controller = container.read(
          readingSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);
        controller.setPassagePhase(false);

        // Answer all questions
        for (int i = 0; i < activity.questions.length; i++) {
          final q = activity.questions[i];
          controller.selectOption(q.correctAnswer);
          controller.submitAnswer();

          final state = container.read(readingSessionControllerProvider);
          expect(state.userAnswers[q.id], equals(q.correctAnswer));
          expect(state.questionResults[q.id], isTrue);

          if (i < activity.questions.length - 1) {
            controller.nextQuestion();
          }
        }

        // Complete session
        await controller.completeSession();

        final finishedState = container.read(readingSessionControllerProvider);
        expect(finishedState.isSubmitted, isTrue);
        expect(finishedState.isCompleted, isTrue);
        expect(finishedState.scorePercentage, equals(100.0));
        expect(finishedState.session!.isCompleted, isTrue);

        // Verify continue reading markers are cleared
        expect(prefs.containsKey(kContinueReadingActivityIdKey), isFalse);
      },
    );

    test('abandonSession cleans up active state and marks abandoned', () async {
      final activity = ReadingContent.activities.first;
      final controller = container.read(
        readingSessionControllerProvider.notifier,
      );

      await controller.initializeActivity(activity);
      await controller.abandonSession();

      expect(prefs.containsKey(kContinueReadingActivityIdKey), isFalse);
    });
  });
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/core/constants/storage_keys.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';
import 'package:fluentia/features/practice/presentation/providers/practice_providers.dart';
import 'package:fluentia/features/writing/data/datasources/writing_content.dart';
import 'package:fluentia/features/writing/domain/models/writing_mode.dart';
import 'package:fluentia/features/writing/presentation/providers/writing_session_controller.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('WritingSessionController Tests', () {
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
      final state = container.read(writingSessionControllerProvider);
      expect(state.activity, isNull);
      expect(state.session, isNull);
      expect(state.currentText, isEmpty);
      expect(state.wordCount, 0);
      expect(state.isSubmitted, isFalse);
      expect(state.isCompleted, isFalse);
    });

    test(
      'initializeActivity loads activity and creates in-progress PracticeSession',
      () async {
        final activity = WritingContent.activities.firstWhere(
          (a) => a.mode == WritingMode.quickResponse,
        );
        final controller = container.read(
          writingSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);

        final state = container.read(writingSessionControllerProvider);
        expect(state.activity, equals(activity));
        expect(state.session, isNotNull);
        expect(state.session!.status, PracticeSessionStatus.inProgress);
        expect(state.session!.skill, PracticeSkill.writing);

        // Verify draft marker written
        final unfinishedJson = prefs.getString(
          StorageKeys.unfinishedWritingSession,
        );
        expect(unfinishedJson, isNotNull);
        final map = jsonDecode(unfinishedJson!) as Map<String, dynamic>;
        expect(map['activityId'], activity.id);
      },
    );

    test(
      'updateText updates metrics and persists draft in local storage',
      () async {
        final activity = WritingContent.activities.firstWhere(
          (a) => a.mode == WritingMode.quickResponse,
        );
        final controller = container.read(
          writingSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);
        controller.updateText('This is a four word response.');

        final state = container.read(writingSessionControllerProvider);
        expect(state.currentText, 'This is a four word response.');
        expect(state.wordCount, 6);
        expect(state.sentenceCount, 1);

        // Verify draft persisted
        final draft = prefs.getString(
          '${StorageKeys.writingDraftPrefix}${activity.id}',
        );
        expect(draft, 'This is a four word response.');
      },
    );

    test(
      'Sentence Builder interactive chips assembling and resetting',
      () async {
        final sbActivity = WritingContent.activities.firstWhere(
          (a) => a.mode == WritingMode.sentenceBuilder,
        );
        final controller = container.read(
          writingSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(sbActivity);

        var state = container.read(writingSessionControllerProvider);
        expect(state.availableTokens.isNotEmpty, isTrue);
        expect(state.selectedTokens.isEmpty, isTrue);

        final initialTokensCount = state.availableTokens.length;

        // Tap first token into selected
        controller.tapAvailableToken(0);
        state = container.read(writingSessionControllerProvider);
        expect(state.selectedTokens.length, 1);
        expect(state.availableTokens.length, initialTokensCount - 1);

        // Tap back to return
        controller.tapSelectedToken(0);
        state = container.read(writingSessionControllerProvider);
        expect(state.selectedTokens.length, 0);
        expect(state.availableTokens.length, initialTokensCount);

        // Add two tokens and reset
        controller.tapAvailableToken(0);
        controller.tapAvailableToken(0);
        controller.resetSentenceBuilder();
        state = container.read(writingSessionControllerProvider);
        expect(state.selectedTokens.isEmpty, isTrue);
        expect(state.availableTokens.length, initialTokensCount);
      },
    );

    test('Guided Writing checklist toggling', () async {
      final gwActivity = WritingContent.activities.firstWhere(
        (a) => a.mode == WritingMode.guidedWriting,
      );
      final controller = container.read(
        writingSessionControllerProvider.notifier,
      );

      await controller.initializeActivity(gwActivity);

      controller.toggleChecklistItem(0);
      controller.toggleChecklistItem(1);

      var state = container.read(writingSessionControllerProvider);
      expect(state.checkedChecklistIndices, containsAll([0, 1]));

      // Toggle off 0
      controller.toggleChecklistItem(0);
      state = container.read(writingSessionControllerProvider);
      expect(state.checkedChecklistIndices.contains(0), isFalse);
      expect(state.checkedChecklistIndices.contains(1), isTrue);
    });

    test(
      'submitWriting evaluates response accurately and completeSession saves to SQLite',
      () async {
        final activity = WritingContent.activities.firstWhere(
          (a) => a.mode == WritingMode.completeSentence,
        );
        final controller = container.read(
          writingSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);

        // Directly update text with expected answer
        controller.updateText(activity.expectedAnswer!);
        controller.submitWriting();

        var state = container.read(writingSessionControllerProvider);
        expect(state.isSubmitted, isTrue);
        expect(state.evaluationResult, isNotNull);
        expect(state.evaluationResult!.isCorrect, isTrue);

        // Complete session
        await controller.completeSession();
        state = container.read(writingSessionControllerProvider);
        expect(state.isCompleted, isTrue);

        // Verify saved in PracticeRepository
        final practiceRepo = container.read(practiceRepositoryProvider);
        final history = await practiceRepo.getSessionHistory();
        expect(history.length, 1);
        expect(history.first.skill, PracticeSkill.writing);
        expect(history.first.status, PracticeSessionStatus.completed);

        // Verify unfinished session key removed upon completion
        final unfinished = prefs.getString(
          StorageKeys.unfinishedWritingSession,
        );
        expect(unfinished, isNull);
      },
    );

    test(
      'abandonSession clears or keeps draft based on keepDraft flag',
      () async {
        final activity = WritingContent.activities.first;
        final controller = container.read(
          writingSessionControllerProvider.notifier,
        );

        await controller.initializeActivity(activity);
        controller.updateText('Draft in progress');

        // Abandon with keepDraft = true
        await controller.abandonSession(keepDraft: true);
        expect(
          prefs.getString(StorageKeys.unfinishedWritingSession),
          isNotNull,
        );

        // Abandon with keepDraft = false
        await controller.abandonSession(keepDraft: false);
        expect(prefs.getString(StorageKeys.unfinishedWritingSession), isNull);
      },
    );
  });
}

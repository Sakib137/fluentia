import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';
import 'package:fluentia/features/practice/presentation/providers/practice_providers.dart';
import 'package:fluentia/features/speaking/data/datasources/speaking_content.dart';
import 'package:fluentia/features/speaking/data/services/mock_speech_recognition_service.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_mode.dart';
import 'package:fluentia/features/speaking/domain/models/speech_recognition_state.dart';
import 'package:fluentia/features/speaking/presentation/providers/speaking_providers.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('SpeakingSessionController Lifecycle Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late MockSpeechRecognitionService mockSpeechService;

    final testActivity = SpeakingContent.activities.firstWhere(
      (a) => a.mode == SpeakingMode.readAloud,
    );

    setUp(() async {
      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();

      mockSpeechService = MockSpeechRecognitionService();

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDb),
          speechRecognitionServiceProvider.overrideWithValue(mockSpeechService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is idle before activity is set', () {
      final state = container.read(speakingSessionControllerProvider);
      expect(state.recordingState, SpeechRecordingState.idle);
      expect(state.activity, isNull);
      expect(state.transcript, isEmpty);
    });

    test('initializeActivity initializes timers and metadata correctly', () {
      final controller = container.read(
        speakingSessionControllerProvider.notifier,
      );
      controller.initializeActivity(testActivity);

      final state = container.read(speakingSessionControllerProvider);
      expect(state.activity, testActivity);
      expect(state.recordingState, SpeechRecordingState.idle);
      expect(state.prepRemainingSeconds, testActivity.preparationSeconds);
      expect(state.maxSpeakingSeconds, testActivity.speakingSeconds);
      expect(state.sessionId, isNotNull);
    });

    test('startPreparation transitions state to preparing', () {
      final controller = container.read(
        speakingSessionControllerProvider.notifier,
      );
      controller.initializeActivity(testActivity);
      controller.startPreparation();

      final state = container.read(speakingSessionControllerProvider);
      expect(state.recordingState, SpeechRecordingState.preparing);
      expect(state.isPreparing, isTrue);
    });

    test(
      'startSpeaking transitions to listening and receives live transcript',
      () async {
        final controller = container.read(
          speakingSessionControllerProvider.notifier,
        );
        controller.initializeActivity(testActivity);

        await controller.startSpeaking();

        var state = container.read(speakingSessionControllerProvider);
        expect(state.recordingState, SpeechRecordingState.listening);
        expect(state.isListening, isTrue);

        // Simulate recognition engine emitting words
        mockSpeechService.emitTranscript('I always drink coffee');
        state = container.read(speakingSessionControllerProvider);
        expect(state.transcript, 'I always drink coffee');
      },
    );

    test('startSpeaking handles microphone permission denied', () async {
      mockSpeechService.setPermission(MicrophonePermissionStatus.denied);

      final controller = container.read(
        speakingSessionControllerProvider.notifier,
      );
      controller.initializeActivity(testActivity);

      await controller.startSpeaking();

      final state = container.read(speakingSessionControllerProvider);
      expect(state.recordingState, SpeechRecordingState.permissionDenied);
      expect(state.errorMessage, contains('Microphone access is required'));
    });

    test(
      'startSpeaking handles speech recognition service unavailable',
      () async {
        mockSpeechService.setAvailability(false);

        final controller = container.read(
          speakingSessionControllerProvider.notifier,
        );
        controller.initializeActivity(testActivity);

        await controller.startSpeaking();

        final state = container.read(speakingSessionControllerProvider);
        expect(state.recordingState, SpeechRecordingState.unavailable);
        expect(state.errorMessage, contains("isn't available"));
      },
    );

    test('stopSpeaking processes speech and generates metrics', () async {
      final controller = container.read(
        speakingSessionControllerProvider.notifier,
      );
      controller.initializeActivity(testActivity);

      await controller.startSpeaking();
      mockSpeechService.emitTranscript(testActivity.expectedText!);

      await controller.stopSpeaking();

      final state = container.read(speakingSessionControllerProvider);
      expect(state.recordingState, SpeechRecordingState.completed);
      expect(state.isCompleted, isTrue);
      expect(state.metrics, isNotNull);
      expect(state.metrics!.matchPercentage, 100.0);
    });

    test(
      'completeSession persists to SQLite and updates practice history',
      () async {
        final controller = container.read(
          speakingSessionControllerProvider.notifier,
        );
        controller.initializeActivity(testActivity);

        await controller.startSpeaking();
        mockSpeechService.emitTranscript(testActivity.expectedText!);
        await controller.stopSpeaking();

        final session = await controller.completeSession();
        expect(session, isNotNull);
        expect(session!.status, PracticeSessionStatus.completed);
        expect(session.skill, PracticeSkill.speaking);

        // Verify stored in practice repository
        final repo = container.read(practiceRepositoryProvider);
        final history = await repo.getSessionHistory(
          skill: PracticeSkill.speaking,
        );
        expect(history.length, 1);
        expect(history.first.id, session.id);
        expect(history.first.isCompleted, isTrue);

        final todayMinutes = await repo.getTodayPracticeMinutes();
        expect(todayMinutes, greaterThan(0));
      },
    );

    test('abandonSession saves abandoned record to database', () async {
      final controller = container.read(
        speakingSessionControllerProvider.notifier,
      );
      controller.initializeActivity(testActivity);
      await controller.startSpeaking();

      await controller.abandonSession();

      final repo = container.read(practiceRepositoryProvider);
      final history = await repo.getSessionHistory(
        skill: PracticeSkill.speaking,
      );
      expect(history.length, 1);
      expect(history.first.status, PracticeSessionStatus.abandoned);
    });
  });
}

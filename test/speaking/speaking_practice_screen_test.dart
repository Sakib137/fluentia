import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/features/speaking/data/datasources/speaking_content.dart';
import 'package:fluentia/features/speaking/data/services/mock_speech_recognition_service.dart';
import 'package:fluentia/features/speaking/data/services/mock_tts_service.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_mode.dart';
import 'package:fluentia/features/speaking/presentation/providers/speaking_providers.dart';
import 'package:fluentia/features/speaking/presentation/screens/speaking_practice_screen.dart';
import 'package:fluentia/features/speaking/presentation/widgets/leave_speaking_dialog.dart';
import 'package:fluentia/features/speaking/presentation/widgets/microphone_button.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('SpeakingPracticeScreen Widget Tests', () {
    late ProviderContainer container;
    late MockSpeechRecognitionService mockSpeechService;
    late MockTtsService mockTtsService;
    late FakeDatabaseService fakeDb;

    final readAloudActivity = SpeakingContent.activities.firstWhere(
      (a) => a.mode == SpeakingMode.readAloud,
    );

    setUp(() async {
      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();

      mockSpeechService = MockSpeechRecognitionService();
      mockTtsService = MockTtsService();

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDb),
          speechRecognitionServiceProvider.overrideWithValue(mockSpeechService),
          ttsServiceProvider.overrideWithValue(mockTtsService),
        ],
      );
    });

    tearDown(() {
      container.read(speakingSessionControllerProvider.notifier).cleanup();
      container.dispose();
    });

    Future<void> pumpPracticeScreen(
      WidgetTester tester, {
      String? activityId,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: SpeakingPracticeScreen(
              activityId: activityId ?? readAloudActivity.id,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Renders Read Aloud activity details, prompt, and start button',
      (tester) async {
        await pumpPracticeScreen(tester);

        expect(find.text(readAloudActivity.title), findsOneWidget);
        expect(find.text(readAloudActivity.instruction), findsOneWidget);
        expect(find.text('Sentence to Read'), findsOneWidget);
        expect(
          find.text('"${readAloudActivity.expectedText!}"'),
          findsOneWidget,
        );

        // Verify TTS listen button
        expect(find.text('Listen'), findsOneWidget);
        expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

        // Verify Ready to Speak CTA
        expect(find.text('Ready to Speak'), findsOneWidget);
      },
    );

    testWidgets('TTS audio button triggers text to speech speak', (
      tester,
    ) async {
      await pumpPracticeScreen(tester);

      await tester.tap(find.text('Listen'));
      await tester.pump();

      expect(mockTtsService.lastSpokenText, readAloudActivity.expectedText);
      expect(mockTtsService.speakCallCount, 1);
    });

    testWidgets('Tapping Ready to Speak begins prep countdown', (tester) async {
      await pumpPracticeScreen(tester);

      await tester.tap(find.text('Ready to Speak'));
      await tester.pump();

      // Controller should enter preparing state
      final state = container.read(speakingSessionControllerProvider);
      expect(state.isPreparing, isTrue);

      // Should show option to start speaking immediately
      expect(find.text('Start Speaking Now'), findsOneWidget);

      // Cancel timer before completing test
      container.read(speakingSessionControllerProvider.notifier).cleanup();
    });

    testWidgets('Starting speaking listens and displays live transcription', (
      tester,
    ) async {
      await pumpPracticeScreen(tester);

      final controller = container.read(
        speakingSessionControllerProvider.notifier,
      );
      await controller.startSpeaking();
      await tester.pump();

      final state = container.read(speakingSessionControllerProvider);
      expect(state.isListening, isTrue);

      // Verify MicrophoneButton is rendered
      expect(find.byType(MicrophoneButton), findsOneWidget);

      // Simulate spoken words
      mockSpeechService.emitTranscript('I always drink coffee in the morning');
      await tester.pump();

      expect(find.text('I always drink coffee in the morning'), findsOneWidget);

      // Cancel timer before completing test
      controller.cleanup();
    });

    testWidgets(
      'Tapping close button when listening shows LeaveSpeakingDialog',
      (tester) async {
        await pumpPracticeScreen(tester);

        final controller = container.read(
          speakingSessionControllerProvider.notifier,
        );
        await controller.startSpeaking();
        await tester.pump();

        // Tap close button in app bar
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify leave dialog appears
        expect(find.byType(LeaveSpeakingDialog), findsOneWidget);
        expect(find.text('Leave practice?'), findsOneWidget);
        expect(find.text('Stay'), findsOneWidget);
        expect(find.text('Leave'), findsOneWidget);

        // Dismiss dialog
        await tester.tap(find.text('Stay'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(LeaveSpeakingDialog), findsNothing);

        controller.cleanup();
      },
    );
  });
}

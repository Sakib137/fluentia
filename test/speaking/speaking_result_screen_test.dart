import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/features/speaking/data/datasources/speaking_content.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_metrics.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_mode.dart';
import 'package:fluentia/features/speaking/domain/models/speech_recognition_state.dart';
import 'package:fluentia/features/speaking/presentation/providers/speaking_providers.dart';
import 'package:fluentia/features/speaking/presentation/providers/speaking_session_controller.dart';
import 'package:fluentia/features/speaking/presentation/screens/speaking_result_screen.dart';
import 'package:fluentia/features/speaking/presentation/widgets/text_match_diff_view.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('SpeakingResultScreen Widget Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;

    final readAloudActivity = SpeakingContent.activities.firstWhere(
      (a) => a.mode == SpeakingMode.readAloud,
    );

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

    testWidgets('Renders empty state when no active session result exists', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SpeakingResultScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Result Available'), findsOneWidget);
      expect(find.text('Go to Speaking Hub'), findsOneWidget);
    });

    testWidgets(
      'Renders complete metrics, speech match diff, and recommendation for Read Aloud',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        const metrics = SpeakingMetrics(
          durationSeconds: 12,
          wordCount: 14,
          wordsPerMinute: 70,
          matchPercentage: 92.5,
          feedbackMessage: 'Great job! Strong sentence flow and accuracy.',
          nextRecommendation: 'Try reading longer sentences next time.',
          wordTokens: [
            WordDiffToken(text: 'i', status: WordMatchStatus.matched),
            WordDiffToken(text: 'always', status: WordMatchStatus.matched),
            WordDiffToken(text: 'drink', status: WordMatchStatus.matched),
            WordDiffToken(text: 'hot', status: WordMatchStatus.extra),
            WordDiffToken(text: 'coffee', status: WordMatchStatus.matched),
          ],
          missingWords: [],
          recognizedTranscript: 'I always drink hot coffee',
          expectedTranscript: 'I always drink coffee',
        );

        // Pre-seed state in controller
        container
            .read(speakingSessionControllerProvider.notifier)
            .initializeActivity(readAloudActivity);
        final seededState = container
            .read(speakingSessionControllerProvider)
            .copyWith(
              recordingState: SpeechRecordingState.completed,
              elapsedSeconds: 12,
              metrics: metrics,
            );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: ProviderScope(
                overrides: [
                  speakingSessionControllerProvider.overrideWith(
                    () => _SeededController(seededState),
                  ),
                ],
                child: const SpeakingResultScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Header verification
        expect(find.text('Speaking Practice Complete ✓'), findsOneWidget);
        expect(
          find.text('Read Aloud • ${readAloudActivity.title}'),
          findsOneWidget,
        );

        // Metrics cards verification
        expect(find.text('12 sec'), findsOneWidget);
        expect(find.text('14'), findsOneWidget);
        expect(find.text('93%'), findsOneWidget); // 92.5 rounds to 93%

        // Diff view verification
        expect(find.byType(TextMatchDiffView), findsOneWidget);
        expect(find.text('Speech Match'), findsNWidgets(2));
        expect(find.text('Target Sentence'), findsOneWidget);
        expect(find.text('What Was Recognized'), findsOneWidget);

        // Feedback & Recommendation
        expect(
          find.text('Great job! Strong sentence flow and accuracy.'),
          findsOneWidget,
        );
        expect(
          find.text('Try reading longer sentences next time.'),
          findsOneWidget,
        );

        // Buttons
        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
      },
    );
  });
}

class _SeededController extends SpeakingSessionController {
  _SeededController(this._initialState);
  final SpeakingSessionState _initialState;

  @override
  SpeakingSessionState build() => _initialState;
}

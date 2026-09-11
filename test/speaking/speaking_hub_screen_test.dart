import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/speaking/data/datasources/speaking_content.dart';
import 'package:fluentia/features/speaking/data/services/mock_speech_recognition_service.dart';
import 'package:fluentia/features/speaking/data/services/mock_tts_service.dart';
import 'package:fluentia/features/speaking/presentation/providers/speaking_providers.dart';
import 'package:fluentia/features/speaking/presentation/screens/speaking_hub_screen.dart';
import 'package:fluentia/features/speaking/presentation/widgets/mode_selection_card.dart';

void main() {
  group('SpeakingHubScreen Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          speechRecognitionServiceProvider.overrideWithValue(
            MockSpeechRecognitionService(),
          ),
          ttsServiceProvider.overrideWithValue(MockTtsService()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> pumpHubScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SpeakingHubScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Renders AppBar, Daily Challenge banner, and 4 mode cards', (
      tester,
    ) async {
      await pumpHubScreen(tester);

      // Verify AppBar
      expect(find.text('Speaking'), findsOneWidget);
      expect(
        find.text('Practice speaking English with real-world prompts.'),
        findsOneWidget,
      );

      // Verify Daily Challenge Banner
      expect(find.text("Today's Speaking Challenge"), findsOneWidget);
      expect(find.text('1 minute'), findsOneWidget);

      // Verify Practice Modes Header
      expect(find.text('Practice Modes'), findsOneWidget);

      // Verify 4 Mode Cards
      expect(find.byType(ModeSelectionCard), findsNWidgets(4));
      expect(find.text('Read Aloud'), findsOneWidget);
      expect(find.text('Speak About It'), findsOneWidget);
      expect(find.text('Quick Response'), findsOneWidget);
      expect(find.text('Daily Speaking'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget); // Read Aloud badge
    });

    testWidgets(
      'Tapping Read Aloud card opens modal bottom sheet with drills',
      (tester) async {
        await pumpHubScreen(tester);

        // Tap on Read Aloud card
        await tester.tap(find.text('Read Aloud'));
        await tester.pumpAndSettle();

        // Verify close button is present in bottom sheet
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);

        // Verify activities listed inside sheet
        final activities = SpeakingContent.activities
            .where((a) => a.mode.name == 'readAloud')
            .toList();
        expect(find.text(activities.first.title), findsOneWidget);

        // Close bottom sheet
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.close_rounded), findsNothing);
      },
    );

    testWidgets('Tapping Speak About It card opens activity picker', (
      tester,
    ) async {
      await pumpHubScreen(tester);

      await tester.tap(find.text('Speak About It'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      final speakActivities = SpeakingContent.activities
          .where((a) => a.mode.name == 'speakAboutIt')
          .toList();
      expect(find.text(speakActivities.first.title), findsOneWidget);
    });
  });
}

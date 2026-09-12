import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/listening/domain/models/listening_activity.dart';
import 'package:fluentia/features/listening/domain/models/listening_mode.dart';
import 'package:fluentia/features/listening/presentation/providers/listening_providers.dart';
import 'package:fluentia/features/listening/presentation/screens/listening_session_screen.dart';
import 'package:fluentia/features/listening/presentation/widgets/audio_player_card.dart';

import '../helpers/fake_database_service.dart';
import 'audio_player_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListeningSessionScreen Widget Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late FakeAudioPlayerService fakeAudioService;
    late SharedPreferences prefs;

    final testActivity = ListeningActivity(
      id: 'test_lac_1',
      title: 'Morning Flight Announcement',
      instruction: 'Listen carefully and select the gate number.',
      level: 'A2',
      mode: ListeningMode.listenAndChoose,
      audioAsset: 'assets/audio/listening/a2/announcement.wav',
      transcript:
          'Attention passengers, flight 204 to Chicago will now board at Gate 12.',
      options: ['Gate 2', 'Gate 12', 'Gate 20', 'Gate 22'],
      correctAnswer: 'Gate 12',
      explanation: 'The announcement says flight 204 boards at Gate 12.',
    );

    final dictationActivity = ListeningActivity(
      id: 'test_dict_1',
      title: 'Library Study Session',
      instruction: 'Listen and type what you hear.',
      level: 'B1',
      mode: ListeningMode.dictation,
      audioAsset: 'assets/audio/listening/b1/library.wav',
      transcript: 'The quiet study area is located on the second floor.',
      correctAnswer: 'The quiet study area is located on the second floor.',
    );

    setUp(() async {
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
          allListeningActivitiesProvider.overrideWithValue([
            testActivity,
            dictationActivity,
          ]),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Widget createTestWidget({String? activityId, bool isDark = false}) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: ListeningSessionScreen(activityId: activityId),
        ),
      );
    }

    testWidgets('Renders AudioPlayerCard and Listen & Choose options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(activityId: 'test_lac_1'));
      await tester.pumpAndSettle();

      // Verify header and mode info
      expect(find.text('Morning Flight Announcement'), findsOneWidget);
      expect(find.text('Listen & Choose • Level A2'), findsOneWidget);

      // Verify Audio player card components
      expect(find.byType(AudioPlayerCard), findsOneWidget);
      expect(find.text('1.0x'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Verify options are rendered
      expect(find.text('Gate 2'), findsOneWidget);
      expect(find.text('Gate 12'), findsOneWidget);
      expect(find.text('Gate 20'), findsOneWidget);
      expect(find.text('Gate 22'), findsOneWidget);

      // Check answer button should initially be present
      expect(find.text('Check Answer'), findsOneWidget);
    });

    testWidgets(
      'Selecting answer and submitting transitions to completed state',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(activityId: 'test_lac_1'));
        await tester.pumpAndSettle();

        // Tap on correct option 'Gate 12'
        await tester.tap(find.text('Gate 12'));
        await tester.pumpAndSettle();

        // Submit answer
        await tester.tap(find.text('Check Answer'));
        await tester.pumpAndSettle();

        // Verify feedback explanation is visible
        expect(
          find.text('The announcement says flight 204 boards at Gate 12.'),
          findsOneWidget,
        );
        expect(find.text('Well Done!'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

        // Verify action button changes to 'Complete Drill'
        expect(find.text('Complete Drill'), findsOneWidget);
      },
    );

    testWidgets(
      'Dictation mode renders text field and explicit pronunciation note',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(activityId: 'test_dict_1'));
        await tester.pumpAndSettle();

        // Verify dictation disclaimer requirement is visible
        expect(
          find.textContaining(
            'Measures text comprehension only, not pronunciation.',
          ),
          findsWidgets,
        );

        // Verify text field exists and can receive input
        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);

        await tester.enterText(textFieldFinder, 'The quiet study area');
        await tester.pumpAndSettle();

        // Check answer
        await tester.tap(find.text('Check Answer'));
        await tester.pumpAndSettle();

        // Word match metrics and expected transcript should be displayed
        expect(find.text('Word Match Accuracy'), findsOneWidget);
        expect(find.text('Expected Transcript:'), findsOneWidget);
      },
    );

    testWidgets('Transcript button opens bottom sheet modal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(activityId: 'test_lac_1'));
      await tester.pumpAndSettle();

      // Tap on bottom bar 'Transcript' button
      await tester.tap(find.widgetWithText(TextButton, 'Transcript'));
      await tester.pumpAndSettle();

      // Transcript sheet should be displayed
      expect(find.text('Audio Transcript'), findsOneWidget);
      expect(
        find.text(
          'Attention passengers, flight 204 to Chicago will now board at Gate 12.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'Back button triggers exit confirmation modal when drill is active',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(activityId: 'test_lac_1'));
        await tester.pumpAndSettle();

        // Tap back button in FluentAppBar
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Leave Practice?'), findsOneWidget);
        expect(find.text('Stay'), findsOneWidget);
        expect(find.text('Leave'), findsOneWidget);

        // Tap Stay
        await tester.tap(find.text('Stay'));
        await tester.pumpAndSettle();

        // Dialog closed and drill stays open
        expect(find.text('Leave Practice?'), findsNothing);
        expect(find.text('Morning Flight Announcement'), findsOneWidget);
      },
    );
  });
}

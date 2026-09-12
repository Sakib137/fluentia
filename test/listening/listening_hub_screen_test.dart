import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/listening/domain/models/listening_mode.dart';
import 'package:fluentia/features/listening/presentation/providers/listening_providers.dart';
import 'package:fluentia/features/listening/presentation/screens/listening_hub_screen.dart';

import 'package:fluentia/features/listening/presentation/widgets/listening_mode_card.dart';

import '../helpers/fake_database_service.dart';
import 'audio_player_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListeningHubScreen Widget Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late FakeAudioPlayerService fakeAudioService;
    late SharedPreferences prefs;

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
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Widget createTestWidget({bool isDark = false}) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const ListeningHubScreen(),
        ),
      );
    }

    testWidgets(
      'Renders header, daily banner, continue section, and 5 mode cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Header
        expect(find.text('Listening Lab'), findsOneWidget);

        // Continue listening empty starter state
        expect(find.text('No unfinished sessions'), findsOneWidget);

        // Daily listening challenge banner
        expect(find.text('DAILY LISTENING'), findsOneWidget);
        expect(find.text('Start Daily Drill'), findsOneWidget);

        // Section header
        expect(find.text('Listening Modes'), findsOneWidget);

        // Verify all 5 modes appear
        for (final mode in ListeningMode.values) {
          expect(
            find.widgetWithText(ListeningModeCard, mode.title),
            findsOneWidget,
          );
        }
      },
    );

    testWidgets('Tapping a mode opens bottom sheet activity picker', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 'Dictation' card
      await tester.tap(find.widgetWithText(ListeningModeCard, 'Dictation'));
      await tester.pumpAndSettle();

      // Modal bottom sheet should display Dictation title and its drills
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('Library Study Session'), findsOneWidget);
    });

    testWidgets('Renders smoothly in dark mode', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(isDark: true));
      await tester.pumpAndSettle();

      expect(find.text('Listening Lab'), findsOneWidget);
      expect(find.text('DAILY LISTENING'), findsOneWidget);
    });
  });
}

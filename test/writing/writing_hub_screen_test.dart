import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/constants/storage_keys.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/writing/presentation/providers/writing_providers.dart';
import 'package:fluentia/features/writing/presentation/screens/writing_hub_screen.dart';
import 'package:fluentia/features/writing/presentation/widgets/writing_mode_card.dart';
import 'package:fluentia/features/writing/presentation/widgets/writing_prompt_card.dart';

import '../helpers/fake_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WritingHubScreen Widget Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late SharedPreferences prefs;

    setUp(() async {
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

    Widget createTestWidget({bool isDark = false}) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const WritingHubScreen(),
        ),
      );
    }

    testWidgets(
      'Renders header, daily writing challenge banner, and all 5 practice mode cards',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 1. Hub Header
        expect(find.text('Writing Lab'), findsOneWidget);

        // 2. Daily Challenge Banner
        expect(find.text('DAILY WRITING CHALLENGE'), findsOneWidget);

        // 3. Recommended section
        expect(find.textContaining('RECOMMENDED'), findsOneWidget);

        // 4. Practice Modes Section
        expect(find.text('Practice Modes'), findsOneWidget);
        expect(find.byType(WritingModeCard), findsWidgets);

        // 5. All Writing Practice list
        expect(find.text('All Writing Practice'), findsOneWidget);
        expect(find.byType(WritingPromptCard), findsWidgets);
      },
    );

    testWidgets('Filtering by CEFR level updates activities list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap A1 filter chip
      await tester.tap(find.widgetWithText(FilterChip, 'A1'));
      await tester.pumpAndSettle();

      final selectedLevel = container.read(selectedWritingLevelFilterProvider);
      expect(selectedLevel, 'A1');

      final filtered = container.read(filteredWritingActivitiesProvider);
      expect(filtered.every((a) => a.level == 'A1'), isTrue);
    });

    testWidgets(
      'Displays Continue Writing card when draft is present in storage',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Seed draft in prefs
        await prefs.setString(
          StorageKeys.unfinishedWritingSession,
          '{"activityId": "wr-a1-sb-01", "draftText": "I usually drink coffee", "wordCount": 4, "lastSaved": 1600000000000}',
        );

        // Re-create container to read seeded draft
        container = ProviderContainer(
          overrides: [
            databaseServiceProvider.overrideWithValue(fakeDb),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('CONTINUE WRITING'), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);
        expect(find.text('4 words drafted'), findsOneWidget);
      },
    );
  });
}

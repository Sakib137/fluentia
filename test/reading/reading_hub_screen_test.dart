import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/reading/domain/models/reading_mode.dart';
import 'package:fluentia/features/reading/presentation/providers/reading_providers.dart';
import 'package:fluentia/features/reading/presentation/screens/reading_hub_screen.dart';
import 'package:fluentia/features/reading/presentation/widgets/reading_mode_card.dart';

import '../helpers/fake_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReadingHubScreen Widget Tests', () {
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
          home: const ReadingHubScreen(),
        ),
      );
    }

    testWidgets(
      'Renders header, daily reading banner, continue section, and 5 mode cards',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Header title
        expect(find.text('Reading Lab'), findsOneWidget);
        expect(
          find.text(
            'Read naturally, expand vocabulary, and master comprehension.',
          ),
          findsOneWidget,
        );

        // Daily Reading challenge card
        expect(find.text('DAILY READING'), findsOneWidget);
        expect(find.text('Start Daily Drill'), findsOneWidget);

        // Continue Reading section header
        expect(find.text('Continue Reading'), findsOneWidget);

        // Practice Modes
        expect(find.text('Reading Modes'), findsOneWidget);
        expect(
          find.byType(ReadingModeCard),
          findsNWidgets(ReadingMode.values.length),
        );

        for (final mode in ReadingMode.values) {
          expect(find.text(mode.displayName), findsOneWidget);
        }
      },
    );

    testWidgets('Filter chip selection updates the active CEFR level filter', (
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

      // Default filter is 'All'
      expect(container.read(selectedReadingLevelFilterProvider), equals('All'));

      // Find the 'B1' filter chip and tap it
      final b1Chip = find.widgetWithText(FilterChip, 'B1');
      expect(b1Chip, findsOneWidget);

      await tester.tap(b1Chip);
      await tester.pumpAndSettle();

      expect(container.read(selectedReadingLevelFilterProvider), equals('B1'));
    });
  });
}

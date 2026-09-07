import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/constants/app_strings.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/home/presentation/home_screen.dart';
import 'package:fluentia/features/home/presentation/providers/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen Dashboard Widget Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeDb = FakeDatabaseService();
      await fakeDb.initialize();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseServiceProvider.overrideWithValue(fakeDb),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Widget createTestWidget() {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      );
    }

    testWidgets('Renders all primary sections of the Home Dashboard', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. App Bar
      expect(find.text('Fluentia'), findsOneWidget);

      // 2. Header with dynamic greeting and streak
      final greeting = container.read(timeGreetingProvider);
      expect(find.text(greeting), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsWidgets);

      // 3. Daily Goal Card
      expect(find.text(AppStrings.dailyGoalTitle), findsOneWidget);
      expect(find.textContaining('/ 15 min'), findsOneWidget);

      // 4. Daily Challenge Card
      expect(find.text('Daily Challenge'), findsOneWidget);
      expect(find.textContaining('completed'), findsWidgets);

      // 5. Quick Practice Section
      expect(find.text('Quick Practice'), findsOneWidget);
      expect(find.text('Speaking'), findsWidgets);
      expect(find.text('Listening'), findsWidgets);
      expect(find.text('Reading'), findsWidgets);
      expect(find.text('Writing'), findsWidgets);

      // 6. Word of the Day Card
      expect(find.text('Word of the Day'), findsOneWidget);
      expect(find.text('Save Word'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsWidgets);

      // 7. Progress Snapshot Section
      expect(find.text('Progress Snapshot'), findsOneWidget);
      expect(find.text('Estimated Level'), findsOneWidget);
      expect(find.text('Practice Time'), findsOneWidget);
      expect(find.text('Words Saved'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Active Streak'), findsOneWidget);
    });

    testWidgets('Toggles challenge activity checklist item', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find first challenge checkbox button
      final checkButtons = find.byTooltip('Mark complete');
      expect(checkButtons, findsWidgets);

      await tester.tap(checkButtons.first);
      await tester.pumpAndSettle();

      // Should now have a completed button tooltip
      expect(find.byTooltip('Mark incomplete'), findsWidgets);
    });

    testWidgets('Toggles Word of the Day bookmark state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final saveButton = find.text('Save Word');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Saved to Vocabulary'), findsOneWidget);
    });

    testWidgets('Pull to refresh executes cleanly without crashing', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trigger pull to refresh gesture
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Fluentia'), findsOneWidget);
    });
  });
}

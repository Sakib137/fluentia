import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/app/app.dart';
import 'package:fluentia/app/router/app_router.dart';
import 'package:fluentia/core/constants/storage_keys.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/practice/presentation/providers/practice_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Practice Session Flow & Lifecycle Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.hasCompletedOnboarding: true,
      });
      sharedPreferences = await SharedPreferences.getInstance();
      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          databaseServiceProvider.overrideWithValue(fakeDb),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const FluentiaApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    }

    testWidgets(
      'Full session lifecycle: Intro -> Active Session -> Next -> Complete -> Result',
      (WidgetTester tester) async {
        await pumpApp(tester);

        final router = container.read(routerProvider);
        router.go('/practice/writing/intro');
        await tester.pumpAndSettle();

        // 1. Intro Screen
        expect(find.text('Writing'), findsWidgets);
        expect(find.text('Session Overview'), findsOneWidget);
        expect(find.text('Start Practice'), findsOneWidget);

        // 2. Start Practice
        await tester.tap(find.text('Start Practice'));
        await tester.pumpAndSettle();

        // 3. Active Session Screen
        expect(find.text('Activity 1 of 3'), findsOneWidget);
        expect(find.text('Next Activity →'), findsOneWidget);

        // Advance to Activity 2
        await tester.tap(find.text('Next Activity →'));
        await tester.pumpAndSettle();
        expect(find.text('Activity 2 of 3'), findsOneWidget);

        // Advance to Activity 3
        await tester.tap(find.text('Next Activity →'));
        await tester.pumpAndSettle();
        expect(find.text('Activity 3 of 3'), findsOneWidget);
        expect(find.text('Complete Practice ✓'), findsOneWidget);

        // Complete Practice
        await tester.tap(find.text('Complete Practice ✓'));
        await tester.pumpAndSettle();

        // 4. Result Screen
        expect(find.text('Practice Complete ✓'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Practice Again'), findsOneWidget);

        // 5. Verify database recorded session
        final repo = container.read(practiceRepositoryProvider);
        final history = await repo.getSessionHistory();
        expect(history.length, 1);
        expect(history.first.isCompleted, isTrue);

        final todayMinutes = await repo.getTodayPracticeMinutes();
        expect(todayMinutes, greaterThan(0));

        // Tap Continue to return to Practice Hub
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(
          find.text('Choose a skill and start improving.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Exit confirmation dialog prevents accidental abandonment', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      final router = container.read(routerProvider);
      router.go('/practice/writing/intro');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Practice'));
      await tester.pumpAndSettle();

      expect(find.text('Activity 1 of 3'), findsOneWidget);

      // Tap exit button
      final exitBtn = find.byTooltip('Exit practice');
      expect(exitBtn, findsOneWidget);
      await tester.tap(exitBtn);
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Leave practice?'), findsOneWidget);
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);

      // Tap Stay
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();

      // Still in active session
      expect(find.text('Activity 1 of 3'), findsOneWidget);

      // Tap exit button again and tap Leave
      await tester.tap(exitBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      // Session abandoned: no practice minutes credited
      final repo = container.read(practiceRepositoryProvider);
      final todayMinutes = await repo.getTodayPracticeMinutes();
      expect(todayMinutes, 0);
    });
  });
}

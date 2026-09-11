import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/constants/app_strings.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/practice/presentation/practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PracticeScreen Widget Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      fakeDb = FakeDatabaseService();
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
          home: const PracticeScreen(),
        ),
      );
    }

    testWidgets(
      'Renders Practice Hub header, quick practice card, and 4 skill cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 4800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 1. App Bar
        expect(find.text(AppStrings.practiceTitle), findsOneWidget);
        expect(
          find.text('Choose a skill and start improving.'),
          findsOneWidget,
        );

        // 2. Quick Practice Card
        expect(find.text('Quick Practice'), findsOneWidget);
        expect(find.text('5-minute session'), findsOneWidget);
        expect(find.text('Start Quick Practice'), findsOneWidget);

        // 3. Section Header
        expect(find.text('Core Skills'), findsOneWidget);

        // 4. 4 Skill Cards
        expect(find.text(AppStrings.speakingTitle), findsWidgets);
        expect(find.text(AppStrings.listeningTitle), findsWidgets);
        expect(find.text(AppStrings.readingTitle), findsWidgets);
        expect(find.text(AppStrings.writingTitle), findsWidgets);
        expect(find.text('5 min'), findsWidgets);
        expect(find.text('Start Practice'), findsWidgets);
      },
    );

    testWidgets('Pull to refresh executes cleanly without errors', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.practiceTitle), findsOneWidget);
    });
  });
}

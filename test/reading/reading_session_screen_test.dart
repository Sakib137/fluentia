import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/reading/data/datasources/reading_content.dart';
import 'package:fluentia/features/reading/presentation/providers/reading_session_controller.dart';
import 'package:fluentia/features/reading/presentation/screens/reading_session_screen.dart';
import 'package:fluentia/features/reading/presentation/widgets/passage_bottom_sheet.dart';
import 'package:fluentia/features/reading/presentation/widgets/reading_passage_card.dart';
import 'package:fluentia/features/reading/presentation/widgets/reading_question_card.dart';

import '../helpers/fake_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReadingSessionScreen Widget Tests', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;
    late SharedPreferences prefs;
    final testActivity = ReadingContent.activities.first;

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
          home: ReadingSessionScreen(activity: testActivity),
        ),
      );
    }

    testWidgets(
      'Displays passage phase with title, passage text, and font controls',
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
        expect(find.text(testActivity.title), findsWidgets);

        // Passage Card is present
        expect(find.byType(ReadingPassageCard), findsOneWidget);
        expect(
          find.text(testActivity.effectiveParagraphs.first),
          findsOneWidget,
        );

        // Font size control in app bar
        expect(find.byTooltip('Adjust font size'), findsOneWidget);

        // Proceed to questions button
        expect(find.text('Proceed to Questions →'), findsOneWidget);
      },
    );

    testWidgets('Font resize modal updates font size delta', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        container.read(readingSessionControllerProvider).fontSizeDelta,
        equals(0.0),
      );

      // Open font size modal
      await tester.tap(find.byTooltip('Adjust font size'));
      await tester.pumpAndSettle();

      // Tap 'A + Large'
      final aPlusButton = find.text('A + Large');
      expect(aPlusButton, findsOneWidget);
      await tester.tap(aPlusButton);
      await tester.pumpAndSettle();

      expect(
        container.read(readingSessionControllerProvider).fontSizeDelta,
        equals(2.0),
      );
    });

    testWidgets(
      'Tapping Proceed to Questions switches to the questions phase',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final proceedBtn = find.text('Proceed to Questions →');
        await tester.tap(proceedBtn);
        await tester.pumpAndSettle();

        // Verify Questions phase is active
        expect(find.byType(ReadingQuestionCard), findsOneWidget);
        expect(find.byTooltip('View Passage'), findsOneWidget);
      },
    );

    testWidgets('View Passage button in questions phase opens bottom sheet', (
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

      // Proceed to questions
      await tester.tap(find.text('Proceed to Questions →'));
      await tester.pumpAndSettle();

      // Tap "View Passage" in AppBar actions
      final viewPassageBtn = find.byTooltip('View Passage');
      await tester.tap(viewPassageBtn);
      await tester.pumpAndSettle();

      // Bottom sheet is visible
      expect(find.byType(PassageBottomSheet), findsOneWidget);

      // Close bottom sheet
      final closeIcon = find.byIcon(Icons.close_rounded);
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();

      expect(find.byType(PassageBottomSheet), findsNothing);
    });

    testWidgets('Tapping back button shows exit confirmation dialog', (
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

      final backBtn = find.byTooltip('Back');
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.text('Leave Reading Practice?'), findsOneWidget);
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);

      // Tap stay
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();

      expect(find.text('Leave Reading Practice?'), findsNothing);
    });
  });
}

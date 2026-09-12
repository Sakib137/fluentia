import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluentia/app/theme/app_theme.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/writing/presentation/screens/writing_session_screen.dart';
import 'package:fluentia/features/writing/presentation/widgets/guided_checklist_widget.dart';
import 'package:fluentia/features/writing/presentation/widgets/sentence_builder_widget.dart';
import 'package:fluentia/features/writing/presentation/widgets/writing_editor.dart';

import '../helpers/fake_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WritingSessionScreen Widget Tests', () {
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

    Widget createTestWidget(String activityId) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: WritingSessionScreen(activityId: activityId),
        ),
      );
    }

    testWidgets('Sentence Builder interactive words assembly and submission', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget('wr-a1-sb-01'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Morning Habit'), findsOneWidget);
      expect(find.byType(SentenceBuilderWidget), findsOneWidget);
      expect(find.text('YOUR SENTENCE'), findsOneWidget);
      expect(find.text('WORD BANK'), findsOneWidget);

      // Tap an ActionChip from the word bank
      final chips = find.byType(ActionChip);
      expect(chips, findsWidgets);

      await tester.tap(chips.first);
      await tester.pumpAndSettle();

      // Submit button should now be enabled
      final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Response');
      expect(submitBtn, findsOneWidget);

      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Post-submission summary CTA
      expect(find.text('View Summary'), findsOneWidget);
    });

    testWidgets(
      'Guided Writing renders checklist and editor with live metrics',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestWidget('wr-a2-gw-01'));
        await tester.pumpAndSettle();

        expect(find.text('Rescheduling Dinner Plans'), findsOneWidget);
        expect(find.byType(GuidedChecklistWidget), findsOneWidget);
        expect(find.byType(WritingEditor), findsOneWidget);

        // Toggle first checklist item
        final checkIcon = find.byIcon(Icons.radio_button_unchecked_rounded);
        expect(checkIcon, findsWidgets);
        await tester.tap(checkIcon.first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);

        // Enter text into editor
        await tester.enterText(
          find.byType(TextField),
          'Hi Sarah, I am so sorry but I cannot make it tonight.',
        );
        await tester.pumpAndSettle();

        // Live metrics should update
        expect(find.textContaining('words'), findsWidgets);
      },
    );

    testWidgets('Exit confirmation dialog prevents accidental loss of drafts', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget('wr-a1-qr-01'));
      await tester.pumpAndSettle();

      // Enter draft text
      await tester.enterText(find.byType(TextField), 'I love autumn seasons.');
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Verify exit confirmation dialog
      expect(find.text('Save your draft?'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Keep Writing'), findsOneWidget);
      expect(find.text('Save & Exit'), findsOneWidget);

      // Tap Keep Writing
      await tester.tap(find.text('Keep Writing'));
      await tester.pumpAndSettle();

      // Dialog dismissed, still on session screen
      expect(find.text('Save your draft?'), findsNothing);
      expect(find.text('Your Favorite Season'), findsOneWidget);
    });
  });
}

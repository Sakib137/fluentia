import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/app/app.dart';
import 'package:fluentia/app/router/app_router.dart';
import 'package:fluentia/app/router/app_routes.dart';
import 'package:fluentia/core/constants/app_constants.dart';
import 'package:fluentia/core/constants/app_strings.dart';
import 'package:fluentia/core/constants/storage_keys.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_database_service.dart';

void main() {
  group('GoRouter and Shell Navigation Tests', () {
    late SharedPreferences sharedPreferences;
    late FakeDatabaseService fakeDb;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.hasCompletedOnboarding: true,
      });
      sharedPreferences = await SharedPreferences.getInstance();
      fakeDb = FakeDatabaseService();
      await fakeDb.initialize();
    });

    Future<void> pumpApp(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const FluentiaApp(),
        ),
      );
      // Settle initial splash timer (1200ms) and complete initial navigation
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    }

    testWidgets('Can navigate directly to all shell tabs and subroutes', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          databaseServiceProvider.overrideWithValue(fakeDb),
        ],
      );
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final router = container.read(routerProvider);

      // Shell Tab 1: Home
      router.go(AppRoutes.home);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.dailyGoalTitle), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Shell Tab 2: Practice
      router.go(AppRoutes.practice);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.practiceTitle), findsOneWidget);

      // Practice Subroutes
      router.go(AppRoutes.practiceSpeaking);
      await tester.pumpAndSettle();
      expect(find.text('Practice Modes'), findsOneWidget);

      router.go(AppRoutes.practiceListening);
      await tester.pumpAndSettle();
      expect(find.text('Listening Modes'), findsOneWidget);

      router.go(AppRoutes.practiceReading);
      await tester.pumpAndSettle();
      expect(find.text('Reading Modes'), findsOneWidget);

      router.go(AppRoutes.practiceWriting);
      await tester.pumpAndSettle();
      expect(find.text('Session Overview'), findsOneWidget);

      // Shell Tab 3: Learn
      router.go(AppRoutes.learn);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.learnTitle), findsOneWidget);

      // Learn Subroutes
      router.go(AppRoutes.learnVocabulary);
      await tester.pumpAndSettle();
      expect(find.text('${AppStrings.vocabularyTitle} Module'), findsOneWidget);

      router.go(AppRoutes.learnGrammar);
      await tester.pumpAndSettle();
      expect(find.text('${AppStrings.grammarTitle} Module'), findsOneWidget);

      // Shell Tab 4: Progress
      router.go(AppRoutes.progress);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.progressTitle), findsOneWidget);

      // Progress Subroutes
      router.go(AppRoutes.progressStatistics);
      await tester.pumpAndSettle();
      expect(find.text('Detailed Statistics'), findsOneWidget);

      router.go(AppRoutes.progressAchievements);
      await tester.pumpAndSettle();
      expect(find.text('Milestones & Badges'), findsOneWidget);

      // Shell Tab 5: Profile
      router.go(AppRoutes.profile);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileTitle), findsOneWidget);

      // Profile Subroutes
      router.go(AppRoutes.profileSettings);
      await tester.pumpAndSettle();
      expect(find.text('Settings & Preferences'), findsOneWidget);

      router.go(AppRoutes.profileNotifications);
      await tester.pumpAndSettle();
      expect(find.text('Daily Practice Reminders'), findsOneWidget);

      // Standalone Routes
      router.go(AppRoutes.challenge);
      await tester.pumpAndSettle();
      expect(find.text('Daily Challenge Active'), findsOneWidget);

      router.go(AppRoutes.onboarding);
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.getStarted), findsOneWidget);

      // Splash route (advance timer after navigation)
      router.go(AppRoutes.splash);
      await tester.pump();
      expect(find.text(AppConstants.appName), findsOneWidget);
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    });

    testWidgets('Tapping bottom navigation bar switches shell tabs', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          databaseServiceProvider.overrideWithValue(fakeDb),
        ],
      );
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final router = container.read(routerProvider);
      router.go(AppRoutes.home);
      await tester.pumpAndSettle();

      // Tap Practice destination
      await tester.tap(find.text(AppStrings.navPractice));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.practiceTitle), findsOneWidget);

      // Tap Learn destination
      await tester.tap(find.text(AppStrings.navLearn));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.learnTitle), findsOneWidget);

      // Tap Progress destination
      await tester.tap(find.text(AppStrings.navProgress));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.progressTitle), findsOneWidget);

      // Tap Profile destination
      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileTitle), findsOneWidget);

      // Tap Home destination
      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.dailyGoalTitle), findsOneWidget);
    });

    testWidgets('Back button on nested subroute pops back to parent screen', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          databaseServiceProvider.overrideWithValue(fakeDb),
        ],
      );
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final router = container.read(routerProvider);
      router.go(AppRoutes.practice);
      await tester.pumpAndSettle();

      // Tap on Speaking skill card to push subroute
      await tester.tap(find.text(AppStrings.speakingTitle));
      await tester.pumpAndSettle();

      expect(find.text('Practice Modes'), findsOneWidget);

      // Subroute has a back button in FluentAppBar
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);

      // Tap back button
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back on Practice screen
      expect(find.text(AppStrings.practiceTitle), findsOneWidget);
    });

    testWidgets('Profile screen tiles navigate to Settings and Notifications', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          databaseServiceProvider.overrideWithValue(fakeDb),
        ],
      );
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final router = container.read(routerProvider);
      router.go(AppRoutes.profile);
      await tester.pumpAndSettle();

      // Ensure tile is in view and tap Settings tile
      final settingsTile = find.text('Settings & Theme');
      await tester.ensureVisible(settingsTile);
      await tester.tap(settingsTile);
      await tester.pumpAndSettle();
      expect(find.text('Settings & Preferences'), findsOneWidget);

      // Pop back
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileTitle), findsOneWidget);

      // Ensure tile is in view and tap Notifications tile
      final notificationsTile = find.text('Study Reminders');
      await tester.ensureVisible(notificationsTile);
      await tester.tap(notificationsTile);
      await tester.pumpAndSettle();
      expect(find.text('Daily Practice Reminders'), findsOneWidget);
    });
  });
}

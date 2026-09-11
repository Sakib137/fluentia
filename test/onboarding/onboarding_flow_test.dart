import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/app/app.dart';
import 'package:fluentia/app/router/app_router.dart';
import 'package:fluentia/app/router/app_routes.dart';
import 'package:fluentia/core/constants/app_strings.dart';
import 'package:fluentia/core/constants/storage_keys.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/database/database_service.dart';
import 'package:fluentia/core/notifications/notification_provider.dart';
import 'package:fluentia/core/notifications/notification_service.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/onboarding/data/datasources/placement_questions_data.dart';
import 'package:fluentia/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:fluentia/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDatabaseService implements DatabaseService {
  final Map<String, List<Map<String, Object?>>> _tables = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    int? conflictAlgorithm,
  }) async {
    _tables.putIfAbsent(table, () => []).add(Map.of(values));
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async => List<Map<String, Object?>>.from(_tables[table] ?? []);

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    int? conflictAlgorithm,
  }) async => 1;

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async => 1;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async => [];

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseService txn) action,
  ) async => action(this);
}

class _MockNotificationService implements NotificationService {
  bool isInitialized = false;
  bool permissionsGranted = true;
  final List<String> scheduledReminders = [];

  @override
  Future<void> initialize() async {
    isInitialized = true;
  }

  @override
  Future<bool> requestPermissions() async => permissionsGranted;

  @override
  Future<void> scheduleDailyReminder({
    required TimeOfDay timeOfDay,
    required String title,
    required String body,
    int notificationId = 1001,
  }) async {
    scheduledReminders.add(
      '$notificationId: ${timeOfDay.hour}:${timeOfDay.minute}',
    );
  }

  @override
  Future<void> cancelReminder(int id) async {}

  @override
  Future<void> cancelAll() async {
    scheduledReminders.clear();
  }

  @override
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}
}

void main() {
  group('First-Time Onboarding Flow Tests', () {
    late SharedPreferences sharedPreferences;
    late _MockNotificationService mockNotificationService;
    late _MockDatabaseService mockDatabaseService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      mockNotificationService = _MockNotificationService();
      mockDatabaseService = _MockDatabaseService();
    });

    Widget createTestWidget(ProviderContainer container) {
      return UncontrolledProviderScope(
        container: container,
        child: const FluentiaApp(),
      );
    }

    testWidgets('Complete onboarding flow from Welcome to Home', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          notificationServiceProvider.overrideWithValue(
            mockNotificationService,
          ),
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Starts at Splash, which initializes services and immediately routes to Onboarding
      expect(
        find.text('Practice English.\nBuild confidence.\nEvery day.'),
        findsOneWidget,
      );
      expect(find.text(AppStrings.getStarted), findsOneWidget);

      // Step 0 -> Step 1: Tap "Get Started"
      await tester.tap(find.text(AppStrings.getStarted));
      await tester.pumpAndSettle();

      // Step 1: Goals Step
      expect(find.text('What would you like to improve?'), findsOneWidget);
      // Try tapping Continue before selecting any goal (disabled)
      final continueButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.continueText,
      );
      final continueWidget = tester.widget<ElevatedButton>(continueButton);
      expect(continueWidget.onPressed, isNull);

      // Select Speaking and Vocabulary
      await tester.tap(find.text('Speaking'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vocabulary'));
      await tester.pumpAndSettle();

      // Now Continue is enabled
      await tester.tap(find.text(AppStrings.continueText));
      await tester.pumpAndSettle();

      // Step 2: Level Step
      expect(find.text('How would you describe your English?'), findsOneWidget);
      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.continueText));
      await tester.pumpAndSettle();

      // Step 3: Daily Practice Duration Step
      expect(
        find.text('How much time can you practice each day?'),
        findsOneWidget,
      );
      // Select 15 Minutes
      await tester.tap(find.text('15 Minutes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.continueText));
      await tester.pumpAndSettle();

      // Step 4: Reminder Step
      expect(find.text('Would you like practice reminders?'), findsOneWidget);
      await tester.tap(find.text(AppStrings.continueText));
      await tester.pumpAndSettle();

      // Step 5: Placement Prompt Step
      expect(find.text('Benchmark your starting ability'), findsOneWidget);
      // Choose "Skip to My Plan"
      await tester.tap(find.text('Skip to My Plan'));
      await tester.pumpAndSettle();

      // Step 6: Personalized Plan Step
      expect(find.text('Your daily plan is ready'), findsOneWidget);
      expect(find.text('15 Minutes Daily'), findsOneWidget);

      // Complete Onboarding
      await tester.tap(find.text('Start Your Journey'));
      await tester.pumpAndSettle();

      // Verifies transitioned to Home screen
      expect(find.text(AppStrings.dailyGoalTitle), findsOneWidget);

      // Verifies persistence
      final repo = container.read(onboardingRepositoryProvider);
      final isCompleted = await repo.hasCompletedOnboarding();
      expect(isCompleted, isTrue);

      final state = await repo.getOnboardingState();
      expect(state.selectedGoals, contains('Speaking'));
      expect(state.selectedGoals, contains('Vocabulary'));
      expect(state.currentLevel, equals('B1'));
      expect(state.dailyPracticeMinutes, equals(15));
      expect(state.onboardingCompleted, isTrue);
    });

    testWidgets(
      'Taking placement test benchmarks estimated level and updates plan',
      (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            notificationServiceProvider.overrideWithValue(
              mockNotificationService,
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createTestWidget(container));
        await tester.pumpAndSettle();

        final router = container.read(routerProvider);
        // Navigate directly to placement test route
        router.go(AppRoutes.placementTest);
        await tester.pumpAndSettle();

        expect(find.text('English Placement Test'), findsOneWidget);
        expect(find.text('Question 1 of 12'), findsOneWidget);

        // Answer all 12 questions correctly
        for (int i = 0; i < 12; i++) {
          final q = kBundledPlacementQuestions[i];
          final correctOptionText = q.options[q.correctAnswerIndex];

          await tester.tap(find.text(correctOptionText));
          await tester.pumpAndSettle();

          if (i < 11) {
            await tester.tap(find.text('Next Question'));
            await tester.pumpAndSettle();
          } else {
            await tester.tap(find.text('Submit Test'));
            await tester.pumpAndSettle();
          }
        }

        // Assessment Complete view
        expect(find.text('Assessment Complete'), findsOneWidget);
        expect(find.text('CEFR B2'), findsOneWidget);
        expect(find.text('Upper Intermediate'), findsOneWidget);

        // Continue to Plan
        await tester.tap(find.text('Continue to Plan'));
        await tester.pumpAndSettle();

        final onboardingState = container.read(onboardingNotifierProvider);
        expect(onboardingState.placementTestCompleted, isTrue);
        expect(onboardingState.estimatedLevel, equals('B2'));
        expect(onboardingState.placementTestScore, equals(12));
      },
    );

    testWidgets('Exiting placement test shows confirmation dialog', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          notificationServiceProvider.overrideWithValue(
            mockNotificationService,
          ),
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      final router = container.read(routerProvider);
      router.go(AppRoutes.placementTest);
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Alert dialog appears
      expect(find.text('Exit Placement Test?'), findsOneWidget);

      // Cancel exit
      await tester.tap(find.text('Continue Test'));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 12'), findsOneWidget);

      // Tap back again and confirm exit
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      // Confirmed exit popped the placement test
      expect(find.text('Question 1 of 12'), findsNothing);
    });

    testWidgets(
      'Second launch with completed onboarding routes directly to Home',
      (WidgetTester tester) async {
        // Set onboarding as already completed in SharedPreferences
        SharedPreferences.setMockInitialValues({
          StorageKeys.hasCompletedOnboarding: true,
        });
        final prefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            notificationServiceProvider.overrideWithValue(
              mockNotificationService,
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createTestWidget(container));
        await tester.pumpAndSettle();

        // Splash initializes and immediately goes to Home, skipping Onboarding
        expect(find.text(AppStrings.dailyGoalTitle), findsOneWidget);
        expect(find.text(AppStrings.getStarted), findsNothing);
      },
    );
  });
}

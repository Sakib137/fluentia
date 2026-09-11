import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/app/app.dart';
import 'package:fluentia/core/constants/app_constants.dart';
import 'package:fluentia/core/constants/app_strings.dart';
import 'package:fluentia/core/database/database_provider.dart';
import 'package:fluentia/core/database/database_service.dart';
import 'package:fluentia/core/notifications/notification_provider.dart';
import 'package:fluentia/core/notifications/notification_service.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDb implements DatabaseService {
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
  }) async => 1;
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
  }) async => [];
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
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> scheduleDailyReminder({
    required TimeOfDay timeOfDay,
    required String title,
    required String body,
    int notificationId = 1001,
  }) async {}
  @override
  Future<void> cancelReminder(int id) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}
}

void main() {
  testWidgets('FluentiaApp bootstraps and displays splash screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          databaseServiceProvider.overrideWithValue(_MockDb()),
          notificationServiceProvider.overrideWithValue(
            _MockNotificationService(),
          ),
        ],
        child: const FluentiaApp(),
      ),
    );

    // Initial frame shows the Splash Screen
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppStrings.splashTagline), findsOneWidget);

    // Advance time past the splash delay to trigger navigation to Onboarding
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verifies Onboarding is presented
    expect(
      find.text('Practice English.\nBuild confidence.\nEvery day.'),
      findsOneWidget,
    );
    expect(find.text(AppStrings.getStarted), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/database/database_service.dart';
import 'package:fluentia/core/database/tables/app_settings_table.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:fluentia/features/onboarding/data/models/onboarding_state_model.dart';
import 'package:fluentia/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDatabaseService implements DatabaseService {
  final Map<String, List<Map<String, Object?>>> _tables = {
    AppSettingsTable.tableName: [],
  };

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
    _tables.putIfAbsent(table, () => []);
    _tables[table]!.add(Map.of(values));
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
  }) async {
    return _tables[table] ?? [];
  }

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
  ) async {
    return action(this);
  }
}

void main() {
  group('LocalOnboardingRepository Tests', () {
    late SharedPreferences sharedPreferences;
    late PreferencesService preferencesService;
    late DatabaseService databaseService;
    late OnboardingRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      preferencesService = SharedPreferencesService(sharedPreferences);
      databaseService = _FakeDatabaseService();

      repository = LocalOnboardingRepository(
        preferencesService: preferencesService,
        databaseService: databaseService,
      );
    });

    test('Defaults to onboardingCompleted false', () async {
      final isCompleted = await repository.hasCompletedOnboarding();
      expect(isCompleted, isFalse);

      final state = await repository.getOnboardingState();
      expect(state.onboardingCompleted, isFalse);
      expect(state.dailyPracticeMinutes, equals(15));
      expect(state.selectedGoals, isEmpty);
    });

    test('Persists onboarding state and recovers all fields', () async {
      const state = OnboardingStateModel(
        onboardingCompleted: true,
        selectedGoals: ['Speaking', 'Vocabulary', 'Everyday Conversation'],
        currentLevel: 'B1',
        estimatedLevel: 'B2',
        dailyPracticeMinutes: 20,
        remindersEnabled: true,
        reminderCount: 2,
        reminderTimes: [
          ReminderTimeSlot(hour: 8, minute: 30, label: 'Morning Drill'),
          ReminderTimeSlot(hour: 20, minute: 0, label: 'Evening Review'),
        ],
        placementTestCompleted: true,
        placementTestScore: 11,
        personalizedPlan: {
          'Speaking': 6,
          'Listening': 4,
          'Vocabulary': 5,
          'Grammar': 3,
          'Reading': 2,
        },
      );

      await repository.saveOnboardingState(state);

      final isCompleted = await repository.hasCompletedOnboarding();
      expect(isCompleted, isTrue);

      final retrieved = await repository.getOnboardingState();
      expect(retrieved.onboardingCompleted, isTrue);
      expect(
        retrieved.selectedGoals,
        equals(['Speaking', 'Vocabulary', 'Everyday Conversation']),
      );
      expect(retrieved.currentLevel, equals('B1'));
      expect(retrieved.estimatedLevel, equals('B2'));
      expect(retrieved.dailyPracticeMinutes, equals(20));
      expect(retrieved.remindersEnabled, isTrue);
      expect(retrieved.reminderCount, equals(2));
      expect(retrieved.reminderTimes.length, equals(2));
      expect(retrieved.reminderTimes[0].hour, equals(8));
      expect(retrieved.reminderTimes[0].minute, equals(30));
      expect(retrieved.placementTestCompleted, isTrue);
      expect(retrieved.placementTestScore, equals(11));
      expect(retrieved.personalizedPlan['Speaking'], equals(6));
    });
  });
}

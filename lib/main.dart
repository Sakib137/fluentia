import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/database_provider.dart';
import 'core/database/sqlite_database_service.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/services/preferences_service.dart';
import 'core/utils/app_logger.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Catch Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.error(
          'FlutterError caught',
          error: details.exception,
          stackTrace: details.stack,
          tag: 'Framework',
        );
      };

      // Pre-initialize local persistent preferences
      final sharedPreferences = await SharedPreferences.getInstance();

      // Pre-initialize SQLite database service to ensure eager readiness
      final databaseService = SqliteDatabaseService();
      try {
        await databaseService.initialize();
      } catch (e) {
        AppLogger.warning(
          'Database service eager initialization postponed: $e',
          tag: 'Bootstrap',
        );
      }

      // Pre-initialize notification service
      try {
        final notificationService = LocalNotificationService();
        await notificationService.initialize();
      } catch (e) {
        AppLogger.warning(
          'Notification service initialization postponed: $e',
          tag: 'Bootstrap',
        );
      }

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            databaseServiceProvider.overrideWithValue(databaseService),
          ],
          child: const FluentiaApp(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.error(
        'Uncaught asynchronous error in root zone',
        error: error,
        stackTrace: stackTrace,
        tag: 'RootZone',
      );
    },
  );
}

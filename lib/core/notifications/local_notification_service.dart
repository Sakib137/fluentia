import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../utils/app_logger.dart';
import 'notification_service.dart';

/// Concrete [NotificationService] implementation utilizing `flutter_local_notifications`.
class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open Fluentia',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          AppLogger.info(
            'Notification tapped with payload: ${response.payload}',
            tag: 'Notification',
          );
        },
      );

      _isInitialized = true;
      AppLogger.info(
        'LocalNotificationService initialized successfully',
        tag: 'Notification',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to initialize LocalNotificationService',
        error: e,
        stackTrace: st,
        tag: 'Notification',
      );
      throw NotificationException(
        message: 'Notification service initialization failed: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }

      final darwinImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (darwinImplementation != null) {
        final granted = await darwinImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to request notification permissions',
        error: e,
        stackTrace: st,
        tag: 'Notification',
      );
      return false;
    }
  }

  @override
  Future<void> scheduleDailyReminder({
    required TimeOfDay timeOfDay,
    required String title,
    required String body,
    int notificationId = AppConstants.dailyReminderNotificationId,
  }) async {
    try {
      final scheduledDate = _nextInstanceOfTime(
        timeOfDay.hour,
        timeOfDay.minute,
      );

      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      AppLogger.info(
        'Scheduled daily reminder at ${timeOfDay.hour}:${timeOfDay.minute}',
        tag: 'Notification',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to schedule daily reminder',
        error: e,
        stackTrace: st,
        tag: 'Notification',
      );
      throw NotificationException(
        message: 'Failed to schedule daily reminder: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e, st) {
      throw NotificationException(
        message: 'Failed to show notification: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (e, st) {
      throw NotificationException(
        message: 'Failed to cancel notification $id: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e, st) {
      throw NotificationException(
        message: 'Failed to cancel all notifications: $e',
        details: e,
        stackTrace: st,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

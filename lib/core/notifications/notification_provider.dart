import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_notification_service.dart';
import 'notification_service.dart';

/// Riverpod provider exposing the application's [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = LocalNotificationService();
  return service;
});

/// Base exception class for all custom exceptions in Fluentia.
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final Object? details;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType.toString())
      ..write(': ')
      ..write(message);
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}

/// Thrown when local database operations fail (e.g. SQLite read/write/migration).
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });
}

/// Thrown when key-value cache or preferences fail.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });
}

/// Thrown when local notification scheduling or permission fails.
class NotificationException extends AppException {
  const NotificationException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });
}

/// Thrown for invalid parameters or business rule violations.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });
}

/// Thrown for audio/TTS hardware or player failures.
class AudioException extends AppException {
  const AudioException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });
}

/// Thrown when a future online or sync feature fails due to network.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });
}

/// Fallback for unexpected or unhandled exceptions.
class UnexpectedException extends AppException {
  const UnexpectedException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });
}

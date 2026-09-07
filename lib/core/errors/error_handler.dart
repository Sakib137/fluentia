import '../utils/app_logger.dart';
import 'app_exception.dart';
import 'failure.dart';

/// Central error handler and mapper for translating exceptions to domain failures.
class ErrorHandler {
  ErrorHandler._();

  /// Converts any exception or error into a strongly typed [Failure].
  static Failure handle(Object error, [StackTrace? stackTrace]) {
    AppLogger.error(
      'ErrorHandler caught error: $error',
      error: error,
      stackTrace: stackTrace,
    );

    if (error is AppException) {
      return _mapAppExceptionToFailure(error);
    }

    return UnexpectedFailure(message: error.toString(), details: error);
  }

  static Failure _mapAppExceptionToFailure(AppException exception) {
    if (exception is DatabaseException) {
      return DatabaseFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    }
    if (exception is CacheException) {
      return CacheFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    }
    if (exception is NotificationException) {
      return NotificationFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    }
    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    }
    if (exception is AudioException) {
      return AudioFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    }
    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    }
    return UnexpectedFailure(
      message: exception.message,
      code: exception.code,
      details: exception.details,
    );
  }
}

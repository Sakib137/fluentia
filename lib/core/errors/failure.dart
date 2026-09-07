/// Immutable Failure representation used in Domain & Presentation layers.
abstract class Failure {
  const Failure({required this.message, this.code, this.details});

  final String message;
  final String? code;
  final Object? details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code, super.details});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code, super.details});
}

class NotificationFailure extends Failure {
  const NotificationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code, super.details});
}

class AudioFailure extends Failure {
  const AudioFailure({required super.message, super.code, super.details});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.details});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code,
    super.details,
  });
}

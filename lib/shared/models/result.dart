import '../../core/errors/failure.dart';

/// Functional Result type representing either a successful outcome [Success]
/// or a domain failure [ErrorResult].
sealed class Result<T, E extends Failure> {
  const Result();

  /// Creates a successful result.
  const factory Result.success(T data) = Success<T, E>;

  /// Creates a failure result.
  const factory Result.failure(E failure) = ErrorResult<T, E>;

  /// Returns `true` if the result is successful.
  bool get isSuccess => this is Success<T, E>;

  /// Returns `true` if the result is a failure.
  bool get isFailure => this is ErrorResult<T, E>;

  /// Returns data if successful, null otherwise.
  T? get dataOrNull => switch (this) {
    Success(data: final d) => d,
    ErrorResult() => null,
  };

  /// Returns failure if failed, null otherwise.
  E? get failureOrNull => switch (this) {
    Success() => null,
    ErrorResult(failure: final f) => f,
  };

  /// Pattern matching fold over success and failure states.
  R when<R>({
    required R Function(T data) success,
    required R Function(E failure) failure,
  }) {
    return switch (this) {
      Success(data: final d) => success(d),
      ErrorResult(failure: final f) => failure(f),
    };
  }
}

final class Success<T, E extends Failure> extends Result<T, E> {
  const Success(this.data);
  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() => 'Result.success($data)';
}

final class ErrorResult<T, E extends Failure> extends Result<T, E> {
  const ErrorResult(this.failure);
  final E failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorResult<T, E> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'Result.failure($failure)';
}

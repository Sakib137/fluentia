import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/errors/failure.dart';
import 'package:fluentia/shared/models/result.dart';

void main() {
  group('Result<T, Failure>', () {
    test('Success returns data and isSuccess is true', () {
      const result = Result<int, Failure>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals(42));
      expect(result.failureOrNull, isNull);

      final mapped = result.when(
        success: (data) => 'Value: $data',
        failure: (f) => 'Error',
      );
      expect(mapped, equals('Value: 42'));
    });

    test('Failure returns failure and isFailure is true', () {
      const failure = DatabaseFailure(message: 'Disk error');
      const result = Result<int, Failure>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, equals(failure));

      final mapped = result.when(
        success: (data) => 'Value: $data',
        failure: (f) => f.message,
      );
      expect(mapped, equals('Disk error'));
    });
  });
}

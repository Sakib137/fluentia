import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/core/errors/app_exception.dart';
import 'package:fluentia/core/errors/error_handler.dart';
import 'package:fluentia/core/errors/failure.dart';

void main() {
  group('ErrorHandler', () {
    test('maps DatabaseException to DatabaseFailure', () {
      const exception = DatabaseException(
        message: 'Table not found',
        code: 'DB_01',
      );
      final failure = ErrorHandler.handle(exception);

      expect(failure, isA<DatabaseFailure>());
      expect(failure.message, equals('Table not found'));
      expect(failure.code, equals('DB_01'));
    });

    test('maps CacheException to CacheFailure', () {
      const exception = CacheException(message: 'Key missing');
      final failure = ErrorHandler.handle(exception);

      expect(failure, isA<CacheFailure>());
      expect(failure.message, equals('Key missing'));
    });

    test('maps generic Exception to UnexpectedFailure', () {
      final exception = Exception('Unknown error occurred');
      final failure = ErrorHandler.handle(exception);

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, contains('Unknown error occurred'));
    });
  });
}

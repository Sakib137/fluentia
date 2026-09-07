import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_service.dart';
import 'sqlite_database_service.dart';

/// Riverpod provider for the central [DatabaseService].
/// Can be overridden in tests with an in-memory or mock database.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = SqliteDatabaseService();
  ref.onDispose(() => service.close());
  return service;
});

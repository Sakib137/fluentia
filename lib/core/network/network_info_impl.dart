import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_info_service.dart';

/// Offline-first [NetworkInfoService] implementation.
/// Defaults to offline-first mode without requiring unnecessary online dependencies in the foundation phase.
class DefaultNetworkInfoService implements NetworkInfoService {
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isConnected async => false; // Offline-first default

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

final networkInfoServiceProvider = Provider<NetworkInfoService>((ref) {
  final service = DefaultNetworkInfoService();
  ref.onDispose(() => service.dispose());
  return service;
});

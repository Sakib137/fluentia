/// Contract for checking network connectivity.
/// Offline-first design allows features to query network availability before attempting
/// future cloud synchronization, remote content downloads, or online AI feedback.
abstract class NetworkInfoService {
  /// Returns `true` if internet connectivity is currently available.
  Future<bool> get isConnected;

  /// Stream of connection status changes (true = online, false = offline).
  Stream<bool> get onConnectivityChanged;
}

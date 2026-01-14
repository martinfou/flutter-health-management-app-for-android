import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for network connectivity status
///
/// Watches the device's network connectivity and provides a boolean stream.
/// Returns true if device has internet connectivity, false otherwise.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Initial check
  final results = await connectivity.checkConnectivity();
  yield !results.contains(ConnectivityResult.none);

  // Watch for changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield !results.contains(ConnectivityResult.none);
  }
});

/// Simple provider for current connectivity status
///
/// Returns the current connectivity status synchronously.
/// Use this for checking connectivity before attempting sync operations.
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final connectivity = Connectivity();
  final results = await connectivity.checkConnectivity();
  return !results.contains(ConnectivityResult.none);
});

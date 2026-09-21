import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de conectividad de la app.
/// `true` = hay alguna red (wifi/datos); no garantiza que el backend responda.
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield _hasNetwork(initial);
  await for (final results in connectivity.onConnectivityChanged) {
    yield _hasNetwork(results);
  }
});

bool _hasNetwork(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Valor síncrono cómodo para la UI (default: online mientras se resuelve).
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStreamProvider).value ?? true;
});

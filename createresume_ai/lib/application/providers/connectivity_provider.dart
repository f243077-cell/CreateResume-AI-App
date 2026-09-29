import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The platform connectivity checker; overridable in tests.
final connectivityServiceProvider = Provider<Connectivity>((ref) => Connectivity());

/// Streams the current connectivity status.
///
/// Emits `true` when the device has any network connection,
/// `false` when fully offline. The current state is emitted first, because
/// `onConnectivityChanged` only fires on changes and would otherwise leave
/// listeners waiting until the network state changes.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityServiceProvider);
  bool online(List<ConnectivityResult> r) => !r.contains(ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
});

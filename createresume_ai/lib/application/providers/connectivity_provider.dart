import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams the current connectivity status.
///
/// Emits `true` when the device has any network connection,
/// `false` when fully offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});

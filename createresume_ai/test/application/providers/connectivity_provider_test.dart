import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:createresume_app/application/providers/connectivity_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late StreamController<List<ConnectivityResult>> changes;
  late ProviderContainer container;

  setUp(() {
    connectivity = MockConnectivity();
    // Single-subscription: buffers events until the provider subscribes.
    changes = StreamController<List<ConnectivityResult>>();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => changes.stream);
    container = ProviderContainer(
      overrides: [connectivityServiceProvider.overrideWithValue(connectivity)],
    );
  });

  // Riverpod pauses providers that nobody listens to; in the app the offline
  // banner is the listener.
  void keepAlive() => container.listen(connectivityProvider, (_, _) {});

  tearDown(() async {
    container.dispose();
    await changes.close();
  });

  test('emits the current state before any change event', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
    keepAlive();

    // No change event is ever pushed; the future must still complete.
    final online = await container
        .read(connectivityProvider.future)
        .timeout(const Duration(seconds: 1));

    expect(online, isTrue);
  });

  test('initial offline state is reported as false', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);
    keepAlive();

    expect(await container.read(connectivityProvider.future), isFalse);
  });

  test('follows later connectivity changes', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.mobile]);

    final values = <bool>[];
    container.listen<AsyncValue<bool>>(
      connectivityProvider,
      (_, next) {
        if (next.hasValue) values.add(next.value!);
      },
      fireImmediately: true,
    );

    await container.read(connectivityProvider.future);
    changes.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    changes.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);

    expect(values, [true, false, true]);
  });
}

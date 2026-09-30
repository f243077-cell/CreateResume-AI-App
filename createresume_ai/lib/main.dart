// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';

// Supplied at build time with --dart-define-from-file=env.json, so no
// config file is bundled into the app as an asset.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

String _requireDefine(String name, String value) {
  if (value.isEmpty) {
    throw StateError(
      '$name is not set. Copy env.example.json to env.json, fill it in, and '
      'run with --dart-define-from-file=env.json.',
    );
  }
  return value;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: _requireDefine('SUPABASE_URL', _supabaseUrl),
    publishableKey: _requireDefine('SUPABASE_ANON_KEY', _supabaseAnonKey),
  );
  await Hive.initFlutter();
  runApp(const ProviderScope(child: CreateResumeApp()));
}

class CreateResumeApp extends ConsumerStatefulWidget {
  const CreateResumeApp({super.key});

  @override
  ConsumerState<CreateResumeApp> createState() => _CreateResumeAppState();
}

class _CreateResumeAppState extends ConsumerState<CreateResumeApp> {
  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        // Set recovery flag FIRST so the redirect guard is active
        // before the router re-evaluates.
        ref.read(passwordRecoveryProvider.notifier).state = true;

        // Navigate after the current frame so the router and widget
        // tree are in a consistent state — avoids the white-screen flash.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(routerProvider).goNamed(AppRouteNames.resetPassword);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CreateResume AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}

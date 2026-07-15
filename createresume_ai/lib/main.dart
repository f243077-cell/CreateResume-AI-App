// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
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

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'application/providers/app_theme_provider.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Hive for offline caching
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: CreateResumeApp(),
    ),
  );
}

/// Root application widget.
class CreateResumeApp extends ConsumerWidget {
  const CreateResumeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'CreateResume AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

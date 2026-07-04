import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/connectivity_provider.dart';
import '../../core/theme/app_colors.dart';

/// A wrapper scaffold that provides a persistent bottom navigation bar
/// and a global offline connectivity banner.
class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOnline = ref.watch(
      connectivityProvider.select(
        (AsyncValue<bool> async) => async.maybeWhen(
          data: (value) => value,
          orElse: () => true,
        ),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          if (!isOnline)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              content: const Text(
                'Offline — changes will sync when you reconnect',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              leading: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 20,
              ),
              backgroundColor: AppColors.warning,
              actions: const [SizedBox.shrink()],
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analyzer',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_kanban_rounded),
            label: 'Tracker',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

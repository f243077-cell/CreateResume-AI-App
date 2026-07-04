import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/service_locator.dart';
import '../../domain/entities/user.dart';

/// Streams the currently authenticated [User], or `null` when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/providers/auth_state_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/entities/application.dart';

class ApplicationTrackerNotifier
    extends AsyncNotifier<List<Application>> {
  @override
  FutureOr<List<Application>> build() async {
    return _fetchApplications();
  }

  Future<List<Application>> _fetchApplications() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];

    final getApplications = ref.watch(getApplicationsUseCaseProvider);
    final result = await getApplications(userId: user.id);

    return result.fold(
      (failure) => throw failure,
      (applications) => applications,
    );
  }

  Future<void> addApplication({
    required String companyName,
    required String jobTitle,
    required ApplicationStatus status,
    required DateTime appliedDate,
    String? notes,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final newApp = Application(
      id: '', // Let Supabase generate the ID
      userId: user.id,
      resumeId: 'default',
      companyName: companyName,
      jobTitle: jobTitle,
      status: status,
      appliedDate: appliedDate,
      notes: notes,
    );

    final createApplication = ref.read(createApplicationUseCaseProvider);
    final result = await createApplication(application: newApp);

    result.fold(
      (failure) {
        // Show error to user
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (created) {
        // Refresh the list to get the new application from server
        ref.invalidateSelf();
      },
    );
  }

  Future<void> updateStatus(
    String applicationId,
    ApplicationStatus newStatus,
  ) async {
    final useCase = ref.read(trackApplicationStatusUseCaseProvider);
    final result = await useCase.call(
      applicationId: applicationId,
      status: newStatus,
    );

    result.fold((l) {}, (updated) {
      final currentList = state.value ?? [];
      final newList = currentList
          .map((app) => app.id == updated.id ? updated : app)
          .toList();
      state = AsyncValue.data(newList);
    });
  }
}

final applicationTrackerProvider =
    AsyncNotifierProvider<
      ApplicationTrackerNotifier,
      List<Application>
    >(ApplicationTrackerNotifier.new);

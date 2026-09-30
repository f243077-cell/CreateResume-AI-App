import 'package:createresume_app/application/use_cases/resume/generate_resume_with_ai_use_case.dart';
import 'package:createresume_app/core/errors/failures.dart';
import 'package:createresume_app/core/routing/app_routes.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/presentation/modules/resume_wizard/providers/resume_generation_provider.dart';
import 'package:createresume_app/presentation/modules/resume_wizard/screens/resume_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Lets the test drive generation results without Supabase or the AI.
class FakeResumeGenerationNotifier extends ResumeGenerationNotifier {
  int retrySaveCalls = 0;

  void emit(AsyncValue<Resume?> value) => state = value;

  @override
  Future<void> retrySave() async => retrySaveCalls++;
}

void main() {
  final resume = Resume(
    id: 'resume-42',
    userId: 'u1',
    title: 'Engineer',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  late FakeResumeGenerationNotifier fake;
  String? openedTemplateSelectionFor;

  Future<void> pumpWizard(WidgetTester tester) async {
    fake = FakeResumeGenerationNotifier();
    openedTemplateSelectionFor = null;
    final router = GoRouter(
      initialLocation: AppRoutes.resumeWizard,
      routes: [
        GoRoute(
          path: AppRoutes.resumeWizard,
          builder: (context, state) => const ResumeWizardScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.templateSelection}/:resumeId',
          name: AppRouteNames.templateSelection,
          builder: (context, state) {
            openedTemplateSelectionFor = state.pathParameters['resumeId'];
            return const Text('template selection');
          },
        ),
        GoRoute(
          path: AppRoutes.subscription,
          name: AppRouteNames.subscription,
          builder: (context, state) => const Text('subscription'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [resumeGenerationProvider.overrideWith(() => fake)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('out of credits opens the upgrade dialog', (tester) async {
    await pumpWizard(tester);

    fake.emit(const AsyncValue.loading());
    fake.emit(const AsyncValue.error(
      InsufficientCreditsFailure(requested: 2, available: 1),
      StackTrace.empty,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Upgrade Required'), findsOneWidget);
    expect(openedTemplateSelectionFor, isNull);
  });

  testWidgets('failed save offers Retry, which retries only the save',
      (tester) async {
    await pumpWizard(tester);

    fake.emit(AsyncValue.error(
      GeneratedResumeNotSavedFailure(resume, 'db down'),
      StackTrace.empty,
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('generated but could not be saved'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(fake.retrySaveCalls, 1);
  });

  testWidgets('other failures show the failure message', (tester) async {
    await pumpWizard(tester);

    fake.emit(const AsyncValue.error(ServerFailure('AI down'), StackTrace.empty));
    await tester.pumpAndSettle();

    expect(find.text('Failed to generate resume: AI down'), findsOneWidget);
    expect(find.text('Upgrade Required'), findsNothing);
  });

  testWidgets('success navigates to template selection for the new resume',
      (tester) async {
    await pumpWizard(tester);

    fake.emit(const AsyncValue.loading());
    fake.emit(AsyncValue.data(resume));
    await tester.pumpAndSettle();

    expect(openedTemplateSelectionFor, 'resume-42');
    expect(find.text('template selection'), findsOneWidget);
  });
}

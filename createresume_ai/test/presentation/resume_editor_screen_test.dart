import 'package:createresume_app/application/providers/auth_state_provider.dart';
import 'package:createresume_app/core/di/service_locator.dart';
import 'package:createresume_app/core/errors/failures.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/repositories/i_resume_repository.dart';
import 'package:createresume_app/presentation/modules/resume_editor/screens/resume_editor_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockResumeRepository extends Mock implements IResumeRepository {}

class FakeResume extends Fake implements Resume {}

void main() {
  setUpAll(() => registerFallbackValue(FakeResume()));

  final resume = Resume(
    id: 'r1',
    userId: 'u1',
    title: 'Platform Engineer',
    summary: 'Builds reliable systems.',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  late MockResumeRepository repo;

  Future<void> pumpEditor(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resumeRepositoryProvider.overrideWithValue(repo),
          authStateProvider.overrideWith(
            (ref) => Stream.value(const User(id: 'u1', email: 'a@b.test', fullName: 'A')),
          ),
        ],
        child: const MaterialApp(home: ResumeEditorScreen(resumeId: 'r1')),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    repo = MockResumeRepository();
    when(() => repo.getResumeById('r1')).thenAnswer((_) async => Right(resume));
  });

  testWidgets('shows branding, title card and editable summary', (tester) async {
    await pumpEditor(tester);

    expect(find.text('CreateResume AI'), findsOneWidget);
    expect(find.text('CRAFT RESUME AI'), findsNothing);
    expect(find.text('Resume Title'), findsOneWidget);
    expect(find.text('Platform Engineer'), findsOneWidget);
    expect(find.text('Professional Summary'), findsOneWidget);
    expect(find.text('Builds reliable systems.'), findsOneWidget);
  });

  testWidgets('typing in the summary is auto-saved to the resume', (tester) async {
    when(() => repo.updateResume(any())).thenAnswer(
      (inv) async => Right(inv.positionalArguments.first as Resume),
    );
    await pumpEditor(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Builds reliable systems.'),
      'Leads platform teams.',
    );
    // Past the autosave debounce.
    await tester.pump(const Duration(seconds: 1));

    final saved = verify(() => repo.updateResume(captureAny())).captured.last as Resume;
    expect(saved.summary, 'Leads platform teams.');
    expect(saved.title, 'Platform Engineer');
  });

  testWidgets('SAVE reports a failed save instead of claiming success', (tester) async {
    when(() => repo.updateResume(any()))
        .thenAnswer((_) async => const Left(ServerFailure('offline')));
    await pumpEditor(tester);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save. Check your connection and try again.'), findsOneWidget);
    expect(find.text('Saved to Cloud'), findsNothing);
  });

  testWidgets('SAVE confirms a successful save', (tester) async {
    when(() => repo.updateResume(any())).thenAnswer(
      (inv) async => Right(inv.positionalArguments.first as Resume),
    );
    await pumpEditor(tester);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('Saved to Cloud'), findsOneWidget);
  });
}

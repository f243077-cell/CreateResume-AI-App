import 'dart:async';

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
    // Nothing is sent while the user is still typing...
    await tester.pump(const Duration(seconds: 1));
    verifyNever(() => repo.updateResume(any()));
    // ...then one save after the 1.5 s debounce.
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

  group('autosave (E2)', () {
    Future<void> editSummary(WidgetTester tester, String text) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Builds reliable systems.'),
        text,
      );
      await tester.pump();
    }

    testWidgets('indicator shows saving, then saved', (tester) async {
      final completer = Completer<Either<Failure, Resume>>();
      when(() => repo.updateResume(any())).thenAnswer((_) => completer.future);
      await pumpEditor(tester);

      await editSummary(tester, 'New summary');
      await tester.pump(const Duration(seconds: 2));
      expect(find.bySemanticsLabel('Saving'), findsOneWidget);

      completer.complete(Right(resume));
      await tester.pump();
      expect(find.byTooltip('Saved'), findsOneWidget);
    });

    testWidgets('a failed autosave shows retry, and retry saves again', (tester) async {
      var calls = 0;
      when(() => repo.updateResume(any())).thenAnswer((inv) async {
        calls++;
        return calls == 1
            ? const Left(ServerFailure('offline'))
            : Right(inv.positionalArguments.first as Resume);
      });
      await pumpEditor(tester);

      await editSummary(tester, 'New summary');
      await tester.pump(const Duration(seconds: 2));
      expect(find.byTooltip('Not saved. Tap to retry'), findsOneWidget);

      await tester.tap(find.byTooltip('Not saved. Tap to retry'));
      await tester.pump();
      expect(calls, 2);
      expect(find.byTooltip('Saved'), findsOneWidget);
    });

    testWidgets('closing the editor within the debounce still saves the edit', (tester) async {
      when(() => repo.updateResume(any())).thenAnswer(
        (inv) async => Right(inv.positionalArguments.first as Resume),
      );
      await pumpEditor(tester);

      await editSummary(tester, 'Last-second edit');
      // Leave before the debounce fires: the provider is disposed.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      final saved = verify(() => repo.updateResume(captureAny())).captured.single as Resume;
      expect(saved.summary, 'Last-second edit');
    });

    testWidgets('system back flushes the pending edit before popping', (tester) async {
      when(() => repo.updateResume(any())).thenAnswer(
        (inv) async => Right(inv.positionalArguments.first as Resume),
      );
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
          child: MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ResumeEditorScreen(resumeId: 'r1')),
                ),
                child: const Text('open editor'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open editor'));
      await tester.pumpAndSettle();

      await editSummary(tester, 'Edit then back');
      final popped = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('open editor'), findsOneWidget, reason: 'editor closed');
      final saved = verify(() => repo.updateResume(captureAny())).captured.single as Resume;
      expect(saved.summary, 'Edit then back');
    });
  });
}

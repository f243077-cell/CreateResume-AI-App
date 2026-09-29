import 'package:createresume_app/application/providers/auth_state_provider.dart';
import 'package:createresume_app/core/di/service_locator.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/skill.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/repositories/i_resume_repository.dart';
import 'package:createresume_app/presentation/modules/resume_analyzer/providers/resume_analyzer_notifier.dart';
import 'package:createresume_app/presentation/modules/resume_analyzer/providers/resume_picker_notifier.dart';
import 'package:createresume_app/presentation/modules/resume_analyzer/screens/resume_analyzer_screen.dart';
import 'package:createresume_app/presentation/modules/resume_analyzer/screens/resume_picker_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockResumeRepository extends Mock implements IResumeRepository {}

class FakePicker extends ResumePickerNotifier {
  FakePicker(this.resumes);
  final List<Resume> resumes;
  @override
  Future<List<Resume>> build() async => resumes;
}

void main() {
  final resume = Resume(
    id: 'r1',
    userId: 'u1',
    title: 'Flutter Engineer',
    summary: 'Builds Flutter apps.',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    skills: const [Skill(id: 's', resumeId: 'r1', name: 'Flutter')],
  );

  late ProviderContainer container;

  void setSurface(WidgetTester tester) {
    // Wide enough for the test font, which draws every glyph as a square.
    tester.view.physicalSize = const Size(1800, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpAnalyzer(WidgetTester tester, {String jobDescription = ''}) async {
    setSurface(tester);
    final repo = MockResumeRepository();
    when(() => repo.getResumeById('r1')).thenAnswer((_) async => Right(resume));
    container = ProviderContainer(overrides: [
      resumeRepositoryProvider.overrideWithValue(repo),
      authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
    ]);
    addTearDown(container.dispose);
    container.read(atsJobDescriptionProvider.notifier).set(jobDescription);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ResumeAnalyzerScreen(resumeId: 'r1')),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('analyzer opens and scores the chosen resume (no scope error)', (tester) async {
    await pumpAnalyzer(tester);

    expect(find.textContaining('Failed to analyze'), findsNothing);
    expect(find.text('ATS SCORE'), findsOneWidget);
    expect(find.textContaining('Add a job description to check keywords'), findsOneWidget);
  });

  testWidgets('keywords come from the pasted job description', (tester) async {
    await pumpAnalyzer(tester, jobDescription: 'Flutter Flutter Kotlin Kotlin');

    expect(find.text('1 Matched'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'flutter'), findsOneWidget);
    expect(find.text('1 Missing'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'kotlin'), findsOneWidget);
    expect(find.textContaining('50% of the job description keywords'), findsOneWidget);
    // The old header claimed a great match regardless of the score.
    expect(find.text('Your resume is highly compatible with your target role.'), findsNothing);
  });

  testWidgets('picker stores the job description and has no fake upload score', (tester) async {
    setSurface(tester);
    container = ProviderContainer(overrides: [
      resumePickerProvider.overrideWith(() => FakePicker([resume])),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ResumePickerScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Target job description (optional)'),
      'Kotlin role',
    );
    expect(container.read(atsJobDescriptionProvider), 'Kotlin role');

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.textContaining('coming soon'), findsOneWidget);
    expect(find.text('Resume Analysis Results'), findsNothing);
  });
}

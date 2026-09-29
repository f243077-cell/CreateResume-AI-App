import 'package:createresume_app/application/use_cases/user/run_ai_tool_use_case.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/presentation/modules/ai_tool_library/providers/ai_tool_notifier.dart';
import 'package:createresume_app/presentation/modules/ai_tool_library/screens/ai_tool_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAiToolNotifier extends AiToolNotifier {
  final requests = <AiToolRequest>[];

  @override
  AiToolState build() => const AiToolState(
        profile: User(id: 'u1', email: 'a@b.test', fullName: 'A', creditBalance: 5),
      );

  @override
  Future<void> runTool(AiToolRequest request) async => requests.add(request);
}

void main() {
  late FakeAiToolNotifier fake;

  Future<void> pumpScreen(WidgetTester tester) async {
    // Wide enough for the test font, which draws every glyph as a square.
    tester.view.physicalSize = const Size(1800, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    fake = FakeAiToolNotifier();
    await tester.pumpWidget(ProviderScope(
      overrides: [aiToolProvider.overrideWith(() => fake)],
      child: const MaterialApp(home: AiToolLibraryScreen()),
    ));
  }

  ElevatedButton runButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Run Tool (1 Credit)'));

  testWidgets('cover letter asks for company, job title and background', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Cover Letter GPT'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Company'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Job title'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'About you'), findsOneWidget);
    expect(runButton(tester).onPressed, isNull, reason: 'disabled until complete');

    await tester.enterText(find.widgetWithText(TextField, 'Company'), 'Acme');
    await tester.enterText(find.widgetWithText(TextField, 'Job title'), 'Engineer');
    await tester.enterText(find.widgetWithText(TextField, 'About you'), 'Mobile dev');
    await tester.pump();
    await tester.tap(find.text('Run Tool (1 Credit)'));
    await tester.pumpAndSettle();

    final request = fake.requests.single as CoverLetterRequest;
    expect(request.companyName, 'Acme');
    expect(request.jobTitle, 'Engineer');
    expect(request.background, 'Mobile dev');
  });

  testWidgets('skill gap sends skills and the job description', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Skill Gap Analyzer'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Your skills'), 'Dart, Flutter');
    await tester.enterText(find.widgetWithText(TextField, 'Target job description'), 'Kotlin role');
    await tester.pump();
    await tester.tap(find.text('Run Tool (1 Credit)'));
    await tester.pumpAndSettle();

    final request = fake.requests.single as SkillGapRequest;
    expect(request.skills, 'Dart, Flutter');
    expect(request.jobDescription, 'Kotlin role');
  });

  testWidgets('bullet rewriter sends the bullet', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Bullet Rewriter'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Bullet point'), 'did stuff');
    await tester.pump();
    await tester.tap(find.text('Run Tool (1 Credit)'));
    await tester.pumpAndSettle();

    expect((fake.requests.single as BulletRewriteRequest).bullet, 'did stuff');
  });
}

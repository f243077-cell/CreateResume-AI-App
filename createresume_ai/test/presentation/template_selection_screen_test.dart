import 'package:createresume_app/core/constants/template_ids.dart';
import 'package:createresume_app/core/routing/app_routes.dart';
import 'package:createresume_app/presentation/modules/template_selection/screens/template_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  /// Pumps the selection screen, taps [category] then [style], and returns
  /// the templateId the editor route received.
  Future<String?> pickTemplate(
    WidgetTester tester, {
    required String category,
    required String style,
  }) async {
    String? receivedTemplateId;
    final router = GoRouter(
      initialLocation: AppRoutes.templateSelectionPath('r1'),
      routes: [
        GoRoute(
          path: '${AppRoutes.templateSelection}/:resumeId',
          name: AppRouteNames.templateSelection,
          builder: (context, state) =>
              TemplateSelectionScreen(resumeId: state.pathParameters['resumeId']!),
        ),
        GoRoute(
          path: '${AppRoutes.resumeEditor}/:resumeId',
          name: AppRouteNames.resumeEditor,
          builder: (context, state) {
            receivedTemplateId = state.uri.queryParameters['templateId'];
            return const Text('editor');
          },
        ),
      ],
    );

    // 480x1000 logical screen so every card is on-screen (the test font
    // renders every glyph as a full square, so text is wider than on a phone).
    tester.view.physicalSize = const Size(1440, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.tap(find.text(category));
    await tester.pumpAndSettle();
    await tester.tap(find.text(style));
    await tester.pumpAndSettle();

    expect(find.text('editor'), findsOneWidget);
    return receivedTemplateId;
  }

  final cases = {
    ('Classic', 'Classic Style'): TemplateIds.classic,
    ('Modern', 'Modern Style'): TemplateIds.modern,
    ('Minimal', 'Minimal Style'): TemplateIds.minimal,
    ('Executive', 'Executive v1'): TemplateIds.executive,
    ('Executive', 'Executive v2'): TemplateIds.executive2,
  };

  cases.forEach((key, expectedId) {
    final (category, style) = key;
    testWidgets('$style navigates to the editor with $expectedId', (tester) async {
      final id = await pickTemplate(tester, category: category, style: style);
      expect(id, expectedId);
      // The ID must be one the PDF service renders without falling back.
      expect(TemplateIds.all, contains(id));
    });
  });
}

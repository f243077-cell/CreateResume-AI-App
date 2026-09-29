import 'package:createresume_app/domain/entities/skill.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/presentation/modules/resume_editor/widgets/forms/editor_dialogs.dart';
import 'package:createresume_app/presentation/modules/resume_editor/widgets/summary_editor_card.dart';
import 'package:createresume_app/presentation/modules/user_profile_settings/widgets/contact_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens [dialog] from a button and returns what it pops.
Future<T?> openDialog<T>(WidgetTester tester, Widget dialog, Future<void> Function() interact) async {
  T? result;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: ElevatedButton(
          onPressed: () async {
            result = await showDialog<T>(context: context, builder: (_) => dialog);
          },
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await interact();
  await tester.pumpAndSettle();
  return result;
}

void main() {
  group('SummaryEditorCard', () {
    Future<List<String>> pumpCard(
      WidgetTester tester, {
      String summary = 'Hello',
      Future<String?> Function(String)? onAiImprove,
    }) async {
      final changes = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SummaryEditorCard(
            summary: summary,
            onChanged: changes.add,
            onAiImprove: onAiImprove,
          ),
        ),
      ));
      return changes;
    }

    testWidgets('shows the summary and a live character count', (tester) async {
      final changes = await pumpCard(tester);
      expect(find.text('Professional Summary'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('5 characters'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();
      expect(find.text('11 characters'), findsOneWidget);
      expect(changes.last, 'Hello world');
    });

    testWidgets('AI Improve replaces the text and reports the change', (tester) async {
      final changes = await pumpCard(
        tester,
        onAiImprove: (text) async => 'Improved: $text',
      );
      await tester.tap(find.text('AI Improve'));
      await tester.pumpAndSettle();
      expect(find.text('Improved: Hello'), findsOneWidget);
      expect(changes.last, 'Improved: Hello');
    });

    testWidgets('AI Improve failure shows a message and keeps the text', (tester) async {
      final changes = await pumpCard(tester, onAiImprove: (_) async => null);
      await tester.tap(find.text('AI Improve'));
      await tester.pumpAndSettle();
      expect(find.text('Could not improve the summary. Please try again.'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(changes, isEmpty);
    });

    testWidgets('disposes cleanly (controllers owned by the widget)', (tester) async {
      await pumpCard(tester);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('Editor dialogs', () {
    testWidgets('editing a skill keeps its category', (tester) async {
      const skill = Skill(
        id: 's1',
        resumeId: 'r1',
        name: 'Dart',
        level: 'expert',
        category: 'Languages',
        orderIndex: 2,
      );
      final result = await openDialog<Skill>(
        tester,
        const SkillFormDialog(resumeId: 'r1', initialData: skill, newOrderIndex: 9),
        () async {
          await tester.enterText(find.widgetWithText(TextField, 'Dart'), 'Dart 3');
          await tester.tap(find.text('Save'));
        },
      );
      expect(result?.name, 'Dart 3');
      expect(result?.category, 'Languages');
      expect(result?.id, 's1');
      expect(result?.orderIndex, 2);
    });

    testWidgets('cancel returns null', (tester) async {
      final result = await openDialog<String>(
        tester,
        const ResumeTitleDialog(initialTitle: 'Old'),
        () => tester.tap(find.text('Cancel')),
      );
      expect(result, isNull);
    });

    testWidgets('title dialog returns the new title', (tester) async {
      final result = await openDialog<String>(
        tester,
        const ResumeTitleDialog(initialTitle: 'Old'),
        () async {
          await tester.enterText(find.byType(TextField), 'New title');
          await tester.tap(find.text('Save'));
        },
      );
      expect(result, 'New title');
    });
  });

  group('ContactDetailsDialog', () {
    const profile = User(
      id: 'u1',
      email: 'a@b.test',
      fullName: 'A',
      phone: '+1 555 0100',
      linkedin: 'linkedin.com/in/a',
    );

    testWidgets('prefills and returns edited details', (tester) async {
      final result = await openDialog<ContactDetails>(
        tester,
        const ContactDetailsDialog(profile: profile),
        () async {
          expect(find.text('+1 555 0100'), findsOneWidget);
          await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'Lahore');
          await tester.tap(find.text('Save'));
        },
      );
      expect(result?.phone, '+1 555 0100');
      expect(result?.location, 'Lahore');
      expect(result?.linkedin, 'linkedin.com/in/a');
    });

    testWidgets('invalid link blocks saving', (tester) async {
      final result = await openDialog<ContactDetails>(
        tester,
        const ContactDetailsDialog(profile: profile),
        () async {
          await tester.enterText(find.widgetWithText(TextFormField, 'GitHub URL'), 'not a link');
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          expect(find.textContaining('Enter a valid link'), findsOneWidget);
          await tester.tap(find.text('Cancel'));
        },
      );
      expect(result, isNull);
    });
  });
}

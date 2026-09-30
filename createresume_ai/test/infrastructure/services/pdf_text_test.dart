import 'dart:convert';

import 'package:createresume_app/core/constants/template_ids.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/infrastructure/services/local_pdf_generator_service.dart';
import 'package:createresume_app/infrastructure/services/templates/pdf_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfTextSanitizer.clean', () {
    test('keeps accents, Greek, Cyrillic, smart quotes and dashes', () {
      const text = 'José Muñoz – Łukasz Żółć — Ελένη “Дмитрий” it’s 5…';
      expect(PdfTextSanitizer.clean(text), text);
    });

    test('removes emoji, invisible characters and unsupported scripts', () {
      expect(PdfTextSanitizer.clean('Shipped 🚀 fast ✅'), 'Shipped fast');
      expect(PdfTextSanitizer.clean('a​b­c️'), 'abc');
      expect(PdfTextSanitizer.clean('Name 王小明'), 'Name');
    });

    test('collapses spaces but keeps single line breaks', () {
      expect(PdfTextSanitizer.clean('  a    b\n\n\n  c  '), 'a b\nc');
    });
  });

  group('PdfTextSanitizer.bullet', () {
    test('removes the bullet mark the text brought along', () {
      for (final line in ['• Led X', '- Led X', '* Led X', '– Led X', '▪ Led X', '  •  Led X']) {
        expect(PdfTextSanitizer.bullet(line), 'Led X', reason: line);
      }
    });
  });

  test('generated PDFs embed Noto Sans instead of Helvetica', () async {
    final bytes = await LocalPdfGeneratorService().generatePdf(
      resume: Resume(
        id: 'r',
        userId: 'u',
        title: 'Инженер',
        summary: 'Ελένη – “quoted”',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
      user: const User(id: 'u', email: 'a@b.test', fullName: 'Łukasz Żółć'),
      templateId: TemplateIds.classic,
    );
    final raw = latin1.decode(bytes, allowInvalid: true);
    expect(raw, contains('NotoSans'));
    expect(raw, isNot(contains('/Helvetica')));
  });
}

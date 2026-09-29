import 'package:createresume_app/core/utils/validators.dart';
import 'package:createresume_app/presentation/modules/resume_editor/providers/resume_editor_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.optionalPhone', () {
    test('accepts empty and common formats', () {
      for (final v in [null, '', '  ', '+1 555 0100', '(0300) 123-4567', '+92.300.1234567']) {
        expect(Validators.optionalPhone(v), isNull, reason: '$v');
      }
    });

    test('rejects letters and too-short numbers', () {
      for (final v in ['call me', '12345', '+1 abc 0100', '1' * 25]) {
        expect(Validators.optionalPhone(v), isNotNull, reason: v);
      }
    });
  });

  group('Validators.optionalUrl', () {
    test('accepts empty, with or without scheme', () {
      for (final v in [
        null,
        '',
        'linkedin.com/in/jane-doe',
        'https://github.com/jane',
        'http://leetcode.com/u/jane/',
        'www.example.co.uk',
      ]) {
        expect(Validators.optionalUrl(v), isNull, reason: '$v');
      }
    });

    test('rejects text that is not a link', () {
      for (final v in ['jane doe', 'github', 'https://', 'ftp://x.com']) {
        expect(Validators.optionalUrl(v), isNotNull, reason: v);
      }
    });
  });

  group('ResumeEditorNotifier.pdfFileName', () {
    test('keeps ordinary titles', () {
      expect(ResumeEditorNotifier.pdfFileName('Senior Engineer'), 'Senior Engineer.pdf');
    });

    test('replaces characters that break file paths', () {
      expect(
        ResumeEditorNotifier.pdfFileName('C/C++ Dev: "Lead" <2024>?'),
        'C_C++ Dev_ _Lead_ _2024.pdf',
      );
      expect(ResumeEditorNotifier.pdfFileName(r'a\b|c*d'), 'a_b_c_d.pdf');
    });

    test('falls back to "resume" and caps the length', () {
      expect(ResumeEditorNotifier.pdfFileName('   '), 'resume.pdf');
      expect(ResumeEditorNotifier.pdfFileName('///'), 'resume.pdf');
      expect(ResumeEditorNotifier.pdfFileName('x' * 200).length, 84);
    });
  });
}

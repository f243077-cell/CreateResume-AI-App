import 'package:createresume_app/core/constants/template_ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemplateIds.normalize', () {
    test('canonical IDs are returned unchanged', () {
      for (final id in TemplateIds.all) {
        expect(TemplateIds.normalize(id), id);
      }
    });

    test('legacy short IDs map to canonical IDs', () {
      expect(TemplateIds.normalize('classic'), TemplateIds.classic);
      expect(TemplateIds.normalize('modern'), TemplateIds.modern);
      expect(TemplateIds.normalize('minimal'), TemplateIds.minimal);
      expect(TemplateIds.normalize('executive'), TemplateIds.executive);
      expect(TemplateIds.normalize('executive2'), TemplateIds.executive2);
    });

    test('null falls back to classic', () {
      expect(TemplateIds.normalize(null), TemplateIds.classic);
    });

    test('unknown values fall back to classic', () {
      expect(TemplateIds.normalize(''), TemplateIds.classic);
      expect(TemplateIds.normalize('fancy_style9'), TemplateIds.classic);
    });
  });
}

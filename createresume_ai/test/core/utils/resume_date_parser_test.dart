import 'package:createresume_app/core/utils/resume_date_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResumeDateParser.parse', () {
    test('parses YYYY-MM', () {
      expect(ResumeDateParser.parse('2020-05'), DateTime(2020, 5));
      expect(ResumeDateParser.parse('2020-5'), DateTime(2020, 5));
    });

    test('parses YYYY-MM-DD to the month', () {
      expect(ResumeDateParser.parse('2020-05-17'), DateTime(2020, 5));
    });

    test('parses MMM YYYY and full month names', () {
      expect(ResumeDateParser.parse('May 2020'), DateTime(2020, 5));
      expect(ResumeDateParser.parse('Sept 2020'), DateTime(2020, 9));
      expect(ResumeDateParser.parse('september 2020'), DateTime(2020, 9));
      expect(ResumeDateParser.parse('Jan. 2019'), DateTime(2019, 1));
    });

    test('parses YYYY as January of that year', () {
      expect(ResumeDateParser.parse('2020'), DateTime(2020, 1));
    });

    test('returns null for present, empty and null', () {
      expect(ResumeDateParser.parse('Present'), isNull);
      expect(ResumeDateParser.parse('current'), isNull);
      expect(ResumeDateParser.parse(''), isNull);
      expect(ResumeDateParser.parse('   '), isNull);
      expect(ResumeDateParser.parse(null), isNull);
    });

    test('returns null for garbage without throwing', () {
      for (final value in [
        '2019-2021',
        'Foo 2020',
        'May',
        '2020-13',
        'yesterday',
        'Ma 2020',
        42,
        <String>[],
      ]) {
        expect(() => ResumeDateParser.parse(value), returnsNormally);
        expect(ResumeDateParser.parse(value), isNull, reason: '$value');
      }
    });

    test('passes DateTime through unchanged', () {
      final date = DateTime(2021, 3, 4);
      expect(ResumeDateParser.parse(date), same(date));
    });
  });

  group('ResumeDateParser.isPresent', () {
    test('recognises ongoing values', () {
      expect(ResumeDateParser.isPresent('Present'), isTrue);
      expect(ResumeDateParser.isPresent(' current '), isTrue);
      expect(ResumeDateParser.isPresent('2020-01'), isFalse);
      expect(ResumeDateParser.isPresent(null), isFalse);
    });
  });
}

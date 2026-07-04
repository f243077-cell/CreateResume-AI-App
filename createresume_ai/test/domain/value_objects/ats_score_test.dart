import 'package:createresume_app/domain/value_objects/ats_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ATSScore', () {
    group('valid range', () {
      test('accepts score of 0', () {
        final score = ATSScore(0);
        expect(score.value, 0);
      });

      test('accepts score of 100', () {
        final score = ATSScore(100);
        expect(score.value, 100);
      });

      test('accepts mid-range score', () {
        final score = ATSScore(55);
        expect(score.value, 55);
      });
    });

    group('invalid range throws', () {
      test('throws ArgumentError for negative score', () {
        expect(() => ATSScore(-1), throwsArgumentError);
      });

      test('throws ArgumentError for score above 100', () {
        expect(() => ATSScore(101), throwsArgumentError);
      });

      test('throws ArgumentError for very large score', () {
        expect(() => ATSScore(999), throwsArgumentError);
      });
    });

    group('rating buckets', () {
      test('0-39 returns poor', () {
        expect(ATSScore(0).rating, 'poor');
        expect(ATSScore(20).rating, 'poor');
        expect(ATSScore(39).rating, 'poor');
      });

      test('40-59 returns fair', () {
        expect(ATSScore(40).rating, 'fair');
        expect(ATSScore(50).rating, 'fair');
        expect(ATSScore(59).rating, 'fair');
      });

      test('60-79 returns good', () {
        expect(ATSScore(60).rating, 'good');
        expect(ATSScore(70).rating, 'good');
        expect(ATSScore(79).rating, 'good');
      });

      test('80-100 returns excellent', () {
        expect(ATSScore(80).rating, 'excellent');
        expect(ATSScore(90).rating, 'excellent');
        expect(ATSScore(100).rating, 'excellent');
      });
    });

    group('equality', () {
      test('two ATSScores with same value are equal', () {
        expect(ATSScore(75), equals(ATSScore(75)));
      });

      test('two ATSScores with different values are not equal', () {
        expect(ATSScore(75), isNot(equals(ATSScore(80))));
      });
    });
  });
}

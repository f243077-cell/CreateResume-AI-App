import 'package:createresume_app/core/errors/exceptions.dart';
import 'package:createresume_app/domain/value_objects/credit_balance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreditBalance', () {
    group('construction', () {
      test('creates with zero balance', () {
        final balance = CreditBalance(0);
        expect(balance.value, 0);
      });

      test('creates with positive balance', () {
        final balance = CreditBalance(100);
        expect(balance.value, 100);
      });

      test('throws ArgumentError for negative initial value', () {
        expect(() => CreditBalance(-1), throwsArgumentError);
      });
    });

    group('deduct', () {
      test('valid deduction returns new balance', () {
        final balance = CreditBalance(10);
        final result = balance.deduct(3);
        expect(result.value, 7);
      });

      test('deducting exact balance returns zero', () {
        final balance = CreditBalance(5);
        final result = balance.deduct(5);
        expect(result.value, 0);
      });

      test('deducting zero returns same value', () {
        final balance = CreditBalance(10);
        final result = balance.deduct(0);
        expect(result.value, 10);
      });

      test('deduction does not mutate original', () {
        final balance = CreditBalance(10);
        balance.deduct(3);
        expect(balance.value, 10);
      });

      test('deduction below zero throws InsufficientCreditsException', () {
        final balance = CreditBalance(5);
        expect(
          () => balance.deduct(10),
          throwsA(isA<InsufficientCreditsException>()),
        );
      });

      test('exception contains correct requested and available amounts', () {
        final balance = CreditBalance(3);
        try {
          balance.deduct(7);
          fail('Should have thrown InsufficientCreditsException');
        } on InsufficientCreditsException catch (e) {
          expect(e.requested, 7);
          expect(e.available, 3);
        }
      });
    });

    group('add', () {
      test('adds credits and returns new balance', () {
        final balance = CreditBalance(10);
        final result = balance.add(5);
        expect(result.value, 15);
      });

      test('adding zero returns same value', () {
        final balance = CreditBalance(10);
        final result = balance.add(0);
        expect(result.value, 10);
      });

      test('add does not mutate original', () {
        final balance = CreditBalance(10);
        balance.add(5);
        expect(balance.value, 10);
      });
    });

    group('equality', () {
      test('two CreditBalances with same value are equal', () {
        expect(CreditBalance(50), equals(CreditBalance(50)));
      });

      test('two CreditBalances with different values are not equal', () {
        expect(CreditBalance(50), isNot(equals(CreditBalance(60))));
      });
    });
  });
}

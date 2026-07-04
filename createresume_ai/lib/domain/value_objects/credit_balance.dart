import 'package:equatable/equatable.dart';

import '../../core/errors/exceptions.dart';

/// Value object wrapping a non-negative credit balance.
///
/// Provides [deduct] and [add] methods that return new instances
/// (immutability). Throws [InsufficientCreditsException] if a
/// deduction would result in a negative balance.
class CreditBalance extends Equatable {
  final int value;

  CreditBalance(this.value) {
    if (value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Credit balance cannot be negative.',
      );
    }
  }

  /// Returns a new [CreditBalance] with [amount] deducted.
  ///
  /// Throws [InsufficientCreditsException] if the resulting balance
  /// would be negative.
  CreditBalance deduct(int amount) {
    if (amount > value) {
      throw InsufficientCreditsException(
        requested: amount,
        available: value,
      );
    }
    return CreditBalance(value - amount);
  }

  /// Returns a new [CreditBalance] with [amount] added.
  CreditBalance add(int amount) {
    return CreditBalance(value + amount);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'CreditBalance($value)';
}

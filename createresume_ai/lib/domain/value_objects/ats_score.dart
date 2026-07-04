import 'package:equatable/equatable.dart';

/// Value object wrapping an ATS (Applicant Tracking System) score.
///
/// Valid range: 0–100 inclusive. Throws [ArgumentError] on invalid input.
/// Provides a human-readable [rating] getter.
class ATSScore extends Equatable {
  final int value;

  ATSScore(this.value) {
    if (value < 0 || value > 100) {
      throw ArgumentError.value(
        value,
        'value',
        'ATS score must be between 0 and 100 inclusive.',
      );
    }
  }

  /// Returns a human-readable rating based on the score.
  ///
  /// - 0–39: poor
  /// - 40–59: fair
  /// - 60–79: good
  /// - 80–100: excellent
  String get rating {
    if (value < 40) return 'poor';
    if (value < 60) return 'fair';
    if (value < 80) return 'good';
    return 'excellent';
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'ATSScore($value – $rating)';
}

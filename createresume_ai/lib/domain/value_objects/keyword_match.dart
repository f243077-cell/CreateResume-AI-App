import 'package:equatable/equatable.dart';

/// Value object representing keyword matching results between
/// a resume and a job description.
class KeywordMatch extends Equatable {
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final double matchPercentage;

  const KeywordMatch({
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.matchPercentage,
  });

  /// Total number of keywords analyzed.
  int get totalKeywords => matchedKeywords.length + missingKeywords.length;

  @override
  List<Object?> get props => [matchedKeywords, missingKeywords, matchPercentage];

  @override
  String toString() =>
      'KeywordMatch(matched: ${matchedKeywords.length}, '
      'missing: ${missingKeywords.length}, '
      '${matchPercentage.toStringAsFixed(1)}%)';
}

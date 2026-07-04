/// Represents the career stage / seniority level of a job seeker.
enum CareerStage {
  entryLevel('Entry Level'),
  midLevel('Mid Level'),
  senior('Senior'),
  executive('Executive');

  /// Human-readable display label for UI rendering.
  final String displayLabel;

  const CareerStage(this.displayLabel);
}

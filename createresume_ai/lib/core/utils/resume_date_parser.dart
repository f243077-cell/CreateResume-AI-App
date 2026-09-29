/// Parses the loosely formatted dates that come back from the AI.
///
/// Accepts `YYYY-MM`, `YYYY-MM-DD`, `MMM YYYY` / `Month YYYY` (e.g. "Sept 2020")
/// and `YYYY`. Returns null for null, empty, "present"/"current" or anything
/// it cannot read. Never throws.
abstract final class ResumeDateParser {
  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  static final _yearMonth = RegExp(r'^(\d{4})-(\d{1,2})(?:-\d{1,2})?$');
  static final _monthYear = RegExp(r'^([A-Za-z]+)\.?,?\s+(\d{4})$');
  static final _year = RegExp(r'^(\d{4})$');

  static DateTime? parse(dynamic value) {
    if (value is DateTime) return value;
    if (value is! String) return null;

    final text = value.trim();
    if (text.isEmpty || isPresent(text)) return null;

    final ym = _yearMonth.firstMatch(text);
    if (ym != null) {
      return _build(int.tryParse(ym[1]!), int.tryParse(ym[2]!));
    }

    final my = _monthYear.firstMatch(text);
    if (my != null) {
      final name = my[1]!.toLowerCase();
      final month = name.length >= 3 ? _months[name.substring(0, 3)] : null;
      return _build(int.tryParse(my[2]!), month);
    }

    final y = _year.firstMatch(text);
    if (y != null) return _build(int.tryParse(y[1]!), 1);

    return null;
  }

  /// True for values meaning "ongoing", such as "Present" or "Current".
  static bool isPresent(dynamic value) {
    if (value is! String) return false;
    final text = value.trim().toLowerCase();
    return text == 'present' || text == 'current' || text == 'now';
  }

  static DateTime? _build(int? year, int? month) {
    if (year == null || month == null || month < 1 || month > 12) return null;
    return DateTime(year, month);
  }
}

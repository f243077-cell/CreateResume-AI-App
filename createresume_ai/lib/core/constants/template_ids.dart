/// Single source of truth for resume template IDs.
///
/// Canonical IDs are what the PDF service renders and what new resumes store.
/// Legacy short IDs ('classic', 'modern', ...) are still accepted by
/// [normalize] so resumes saved before this change keep opening.
abstract final class TemplateIds {
  static const classic = 'classic_style1';
  static const modern = 'modern_style1';
  static const minimal = 'minimal_style1';
  static const executive = 'executive_style1';
  static const executive2 = 'executive_style2';

  static const all = [classic, modern, minimal, executive, executive2];

  static const _legacy = {
    'classic': classic,
    'modern': modern,
    'minimal': minimal,
    'executive': executive,
    'executive2': executive2,
  };

  /// Maps any known ID (canonical or legacy) to its canonical form.
  /// Null or unknown values fall back to [classic].
  static String normalize(String? id) {
    if (id == null) return classic;
    return all.contains(id) ? id : (_legacy[id] ?? classic);
  }
}

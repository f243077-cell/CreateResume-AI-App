/// Text cleanup shared by every PDF template, so the same input renders the
/// same way in each (brief E5).
///
/// The templates use the bundled Noto Sans font, which covers Latin (with
/// accents), Greek, Cyrillic and common punctuation, so smart quotes, dashes
/// and accented names are kept. Anything the font cannot draw (emoji, most
/// symbols, other scripts) is removed so it never shows as an empty box.
abstract final class PdfTextSanitizer {
  // Characters Noto Sans can render, plus whitespace (normalized below).
  static final _unsupported = RegExp(
    r'[^\t\n\r\f\v -~ -ɏɐ-ͯͰ-ϿЀ-ԯ'
    r'Ḁ-῿‐-‧‰-⁞⁰-₟₠-⃀'
    r'℀-↏]',
    unicode: true,
  );

  static final _invisible = RegExp(r'[­​-‍⁠︎️]');
  static final _spaces = RegExp(r'[ \t\f\v\r]+');
  static final _lineBreaks = RegExp(r' ?\n[\s]*');
  static final _leadingBullet = RegExp(
    r'^\s*[•‣⁃∙▪▫●◦▸➤➔→\-\*–—]+\s*',
  );

  /// Cleans one piece of text: removes characters the font cannot draw,
  /// collapses runs of spaces, and keeps single line breaks (no blank lines).
  static String clean(String text) {
    return text
        .replaceAll(' ', ' ')
        .replaceAll(_invisible, '')
        .replaceAll(_unsupported, '')
        .replaceAll(_spaces, ' ')
        .replaceAll(_lineBreaks, '\n')
        .trim();
  }

  /// Cleans one bullet line and removes its own bullet mark ("•", "-", "*",
  /// "–"...), because the templates draw their own bullet.
  static String bullet(String line) => clean(line.replaceFirst(_leadingBullet, ''));
}

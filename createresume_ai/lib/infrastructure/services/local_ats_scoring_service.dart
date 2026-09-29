import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/user.dart';
import '../../domain/services/i_ats_scoring_service.dart';
import '../../domain/value_objects/ats_score.dart';
import '../../domain/value_objects/keyword_match.dart';

/// Deterministic, offline ATS scorer. No AI and no credits.
///
/// Points (brief Section 6):
/// - Completeness 20: contact info, summary, experience or project,
///   education, 6+ skills.
/// - Keyword match 40: top job-description terms found in the resume.
///   Without a job description this weight is spread over the other rows.
/// - Bullet quality 20: bullets that start with an action verb, contain a
///   number, and are 8-28 words.
/// - Length and format 10: summary 40-90 words, roughly one to two pages,
///   no very long paragraphs.
/// - Consistency 10: dates present and ordered, no placeholder text.
class LocalAtsScoringService implements IATSScoringService {
  const LocalAtsScoringService();

  static const maxKeywords = 30;

  @override
  Future<Either<Failure, ATSScore>> scoreResume(
    Resume resume, {
    String jobDescription = '',
    User? profile,
  }) async {
    try {
      return Right(ATSScore(score(resume, jobDescription: jobDescription, profile: profile)));
    } catch (e) {
      return Left(ValidationFailure('Could not score resume: $e'));
    }
  }

  @override
  Future<Either<Failure, KeywordMatch>> getKeywordMatch({
    required String resumeText,
    required String jobDescription,
  }) async {
    return Right(keywordMatch(resumeText: resumeText, jobDescription: jobDescription));
  }

  // ── Scoring ─────────────────────────────────────────────────────────

  /// The 0-100 score. Pure and repeatable for the same input.
  int score(Resume resume, {String jobDescription = '', User? profile}) {
    final completeness = _completeness(resume, profile); // 0..1
    final bullets = _bulletQuality(resume); // 0..1
    final format = _lengthAndFormat(resume); // 0..1
    final consistency = _consistency(resume); // 0..1

    double total;
    if (jobDescription.trim().isEmpty) {
      // Redistribute the 40 keyword points proportionally (x 100/60).
      total = (completeness * 20 + bullets * 20 + format * 10 + consistency * 10) * 100 / 60;
    } else {
      final match = keywordMatch(resumeText: resume.toPlainText(), jobDescription: jobDescription);
      total = completeness * 20 +
          match.matchPercentage / 100 * 40 +
          bullets * 20 +
          format * 10 +
          consistency * 10;
    }
    return total.round().clamp(0, 100);
  }

  double _completeness(Resume resume, User? profile) {
    bool has(String? s) => s != null && s.trim().isNotEmpty;
    final checks = <bool>[
      // Contact beyond email: only checkable when the profile is known.
      if (profile != null) has(profile.phone) || has(profile.location) || has(profile.linkedin),
      has(resume.summary),
      resume.workExperiences.isNotEmpty || resume.projects.isNotEmpty,
      resume.educations.isNotEmpty,
      resume.skills.length >= 6,
    ];
    return checks.where((c) => c).length / checks.length;
  }

  /// Bullets from experience and project descriptions, bullet marks removed.
  static List<String> bulletsOf(Resume resume) => [
        for (final e in resume.workExperiences) ...e.description.split('\n'),
        for (final p in resume.projects) ...p.description.split('\n'),
      ]
          .map((l) => l.replaceFirst(RegExp(r'^\s*[•\-\*▪●]\s*'), '').trim())
          .where((l) => l.isNotEmpty)
          .toList();

  double _bulletQuality(Resume resume) {
    final bullets = bulletsOf(resume);
    if (bullets.isEmpty) return 0;
    var points = 0.0;
    for (final b in bullets) {
      final words = _words(b);
      final first = words.isEmpty ? '' : words.first.toLowerCase();
      if (_actionVerbs.contains(first)) points += 1 / 3;
      if (RegExp(r'\d').hasMatch(b)) points += 1 / 3;
      if (words.length >= 8 && words.length <= 28) points += 1 / 3;
    }
    return points / bullets.length;
  }

  double _lengthAndFormat(Resume resume) {
    var points = 0.0;
    final summaryWords = _words(resume.summary ?? '').length;
    if (summaryWords >= 40 && summaryWords <= 90) {
      points += 5;
    } else if (summaryWords >= 20 && summaryWords <= 130) {
      points += 2.5;
    }

    // Roughly one to two pages of content.
    final totalWords = _words(resume.toPlainText()).length;
    if (totalWords >= 250 && totalWords <= 900) {
      points += 3;
    } else if (totalWords >= 150 && totalWords <= 1200) {
      points += 1.5;
    }

    // No paragraph or bullet longer than 60 words.
    final blocks = [...bulletsOf(resume), resume.summary ?? ''];
    if (blocks.every((b) => _words(b).length <= 60)) points += 2;
    return points / 10;
  }

  double _consistency(Resume resume) {
    var points = 0.0;
    final jobs = [...resume.workExperiences]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (jobs.isEmpty) {
      points += 5;
    } else {
      final valid = jobs
          .where((j) => j.isCurrent || (j.endDate != null && !j.endDate!.isBefore(j.startDate)))
          .length;
      points += 3 * valid / jobs.length;
      // Most recent first.
      var ordered = true;
      for (var i = 1; i < jobs.length; i++) {
        if (jobs[i].startDate.isAfter(jobs[i - 1].startDate)) ordered = false;
      }
      if (ordered) points += 2;
    }

    final text = resume.toPlainText().toLowerCase();
    if (!_placeholders.any(text.contains)) points += 5;
    return points / 10;
  }

  // ── Keywords ────────────────────────────────────────────────────────

  /// Top job-description terms (unigrams, and bigrams seen at least twice)
  /// and whether each appears in [resumeText].
  KeywordMatch keywordMatch({required String resumeText, required String jobDescription}) {
    final jdTokens = tokenize(jobDescription);
    if (jdTokens.isEmpty) {
      return const KeywordMatch(matchedKeywords: [], missingKeywords: [], matchPercentage: 0);
    }

    final counts = <String, int>{};
    final firstSeen = <String, int>{};
    void add(String term, int position) {
      counts[term] = (counts[term] ?? 0) + 1;
      firstSeen.putIfAbsent(term, () => position);
    }

    for (var i = 0; i < jdTokens.length; i++) {
      final t = jdTokens[i];
      if (_isKeyword(t)) add(t, i);
      if (i + 1 < jdTokens.length && _isKeyword(t) && _isKeyword(jdTokens[i + 1])) {
        add('$t ${jdTokens[i + 1]}', i);
      }
    }
    counts.removeWhere((term, count) => term.contains(' ') && count < 2);

    final terms = counts.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : firstSeen[a]!.compareTo(firstSeen[b]!);
      });
    final top = terms.take(maxKeywords).toList();

    final resumeTokens = tokenize(resumeText);
    final resumeUnigrams = resumeTokens.toSet();
    final resumeJoined = ' ${resumeTokens.join(' ')} ';

    final matched = <String>[];
    final missing = <String>[];
    for (final term in top) {
      final found = term.contains(' ') ? resumeJoined.contains(' $term ') : resumeUnigrams.contains(term);
      (found ? matched : missing).add(term);
    }
    return KeywordMatch(
      matchedKeywords: matched,
      missingKeywords: missing,
      matchPercentage: top.isEmpty ? 0 : matched.length / top.length * 100,
    );
  }

  /// Lower-cased tokens that keep tech names like c++, c#, node.js and ci/cd.
  static List<String> tokenize(String text) {
    return RegExp(r'[a-z0-9][a-z0-9+#./-]*')
        .allMatches(text.toLowerCase())
        .map((m) => m.group(0)!.replaceAll(RegExp(r'[./-]+$'), ''))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  static bool _isKeyword(String token) =>
      token.length >= 2 && !_stopWords.contains(token) && !RegExp(r'^\d+$').hasMatch(token);

  static List<String> _words(String text) =>
      text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  static const _placeholders = [
    'example.com',
    'your name',
    'lorem ipsum',
    'company name',
    'placeholder',
    'xxx',
  ];

  static const _stopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from', 'has', 'have',
    'in', 'is', 'it', 'its', 'of', 'on', 'or', 'our', 'that', 'the', 'their',
    'this', 'to', 'we', 'will', 'with', 'you', 'your', 'who', 'what', 'which',
    'can', 'all', 'any', 'but', 'not', 'into', 'about', 'more', 'other', 'such',
    'than', 'then', 'they', 'them', 'these', 'those', 'also', 'etc', 'must',
    'should', 'would', 'able', 'ability', 'strong', 'good', 'excellent',
    'experience', 'experienced', 'work', 'working', 'team', 'role', 'job',
    'years', 'year', 'plus', 'including', 'knowledge', 'understanding',
    'skills', 'skill', 'required', 'requirements', 'preferred', 'responsibilities',
    'looking', 'join', 'us', 'candidate', 'ideal', 'well', 'using', 'use', 'new',
    'across', 'within', 'based', 'least', 'e.g', 'i.e', 'need', 'needs',
  };

  static const _actionVerbs = {
    'achieved', 'added', 'analyzed', 'architected', 'automated', 'boosted', 'built',
    'championed', 'collaborated', 'configured', 'coordinated', 'created', 'cut',
    'decreased', 'defined', 'delivered', 'deployed', 'designed', 'developed',
    'directed', 'drove', 'enabled', 'engineered', 'enhanced', 'established',
    'executed', 'expanded', 'facilitated', 'grew', 'guided', 'identified',
    'implemented', 'improved', 'increased', 'initiated', 'integrated', 'introduced',
    'launched', 'led', 'maintained', 'managed', 'mentored', 'migrated', 'modernized',
    'monitored', 'negotiated', 'optimized', 'orchestrated', 'organized', 'overhauled',
    'owned', 'partnered', 'performed', 'pioneered', 'planned', 'produced',
    'published', 'reduced', 'refactored', 'resolved', 'restructured', 'revamped',
    'scaled', 'shipped', 'simplified', 'spearheaded', 'streamlined', 'strengthened',
    'supervised', 'supported', 'tested', 'trained', 'transformed', 'upgraded', 'wrote',
  };
}

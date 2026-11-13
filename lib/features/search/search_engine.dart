import '../../content/content_repository.dart';
import '../../core/text_normalize.dart';

enum SearchHitKind { topic, rule, page, lesson }

/// How the hit was found.
enum MatchQuality {
  /// The whole entry equals the query (after strict normalisation).
  exact,

  /// An entry word starts with the query.
  prefix,

  /// The query occurs inside the entry.
  contains,

  /// Found only after folding Kurdish letters to Arabic-keyboard look-alikes.
  folded,
}

class SearchHit {
  SearchHit({
    required this.kind,
    required this.quality,
    required this.score,
    required this.matchedText,
    this.topicId,
    this.ruleId,
    this.edition,
    this.page,
    this.block,
  });

  final SearchHitKind kind;
  final MatchQuality quality;
  final double score;

  /// The (unnormalised) text that matched, for display.
  final String matchedText;
  final String? topicId;
  final String? ruleId;
  final String? edition;
  final int? page;

  /// For lesson hits: index of the matching block in the lesson.
  final int? block;
}

class _Entry {
  _Entry({
    required this.kind,
    required this.text,
    this.topicId,
    this.ruleId,
    required this.weight,
  }) : strict = normalizeStrict(text),
       loose = normalizeLoose(text);

  final SearchHitKind kind;
  final String text;
  final String? topicId;
  final String? ruleId;
  final double weight;
  final String strict;
  final String loose;
}

/// Topic and term search across all four languages, plus page-text search in
/// the English and Indonesian editions (the only editions with a reliable
/// text layer). This is not a full-book search of the Arabic or Kurdish
/// editions, and the UI says so.
class SearchEngine {
  SearchEngine(this.content) {
    for (final t in content.topics) {
      for (final lang in const ['ar', 'ckb', 'en', 'id']) {
        final title = t.title[lang];
        if (title != null) {
          _entries.add(
            _Entry(
              kind: SearchHitKind.topic,
              text: title.text,
              topicId: t.id,
              weight: 1.0,
            ),
          );
        }
        for (final a in content.topicAliases[t.id]?[lang] ?? const <String>[]) {
          _entries.add(
            _Entry(
              kind: SearchHitKind.topic,
              text: a,
              topicId: t.id,
              weight: 0.85,
            ),
          );
        }
      }
    }
    for (final r in content.rules) {
      for (final lang in const ['ar', 'ckb', 'en', 'id']) {
        final title = r.title[lang];
        if (title != null) {
          _entries.add(
            _Entry(
              kind: SearchHitKind.rule,
              text: title,
              topicId: r.topicId,
              ruleId: r.id,
              weight: 1.05,
            ),
          );
        }
      }
    }
    for (final lang in const ['ar', 'ckb', 'en', 'id']) {
      for (final t in content.topics) {
        final lesson = content.lesson(t.id, lang);
        if (lesson == null) continue;
        for (final (i, b) in lesson.blocks.indexed) {
          final plain = b.plain.replaceAll(RegExp(r'\s+'), ' ').trim();
          if (plain.isEmpty) continue;
          _lessonBlocks.add((
            lang,
            t.id,
            i,
            b.page,
            plain,
            normalizeStrict(plain),
            normalizeLoose(plain),
          ));
        }
      }
    }
    content.pageText.forEach((edition, pages) {
      pages.forEach((page, text) {
        _pages.add((edition, page, text, normalizeStrict(text)));
      });
    });
  }

  final ContentRepository content;
  final List<_Entry> _entries = [];
  final List<(String, int, String, String)> _pages = [];
  final List<(String, String, int, int, String, String, String)> _lessonBlocks =
      [];

  /// Full-text search in the native lessons of [language]. Every query word
  /// must match the start of a word in the block (definite article optional).
  /// Exact Kurdish spelling ranks above Arabic-keyboard look-alikes.
  List<SearchHit> searchLessons(
    String query,
    String language, {
    int limit = 40,
  }) {
    final q = normalizeStrict(query);
    if (meaningfulLength(q) < 2) return const [];
    final core = q
        .split(' ')
        .map((w) => w.startsWith('ال') ? w.substring(2) : w)
        .join();
    if (meaningfulLength(core) < 2) return const [];
    final qs = q.split(' ').where((w) => w.isNotEmpty).toList();
    final ql = normalizeLoose(
      query,
    ).split(' ').where((w) => w.isNotEmpty).toList();
    bool all(List<String> words, List<String> terms) => terms.every((t) {
      final tt = t.length > 3 && t.startsWith('ال') ? t.substring(2) : t;
      return words.any((w) => w.startsWith(t) || w.startsWith(tt));
    });
    final hits = <SearchHit>[];
    final perTopic = <String, int>{};
    for (final (lang, topic, block, page, plain, strict, loose)
        in _lessonBlocks) {
      if (lang != language) continue;
      double score;
      MatchQuality quality;
      if (all(searchTokens(strict), qs)) {
        score = 2;
        quality = MatchQuality.contains;
      } else if (all(searchTokens(loose), ql)) {
        score = 1;
        quality = MatchQuality.folded;
      } else {
        continue;
      }
      // Headings rank first; at most a few hits per topic.
      final n = (perTopic[topic] ?? 0) + 1;
      perTopic[topic] = n;
      if (n > 4) continue;
      hits.add(
        SearchHit(
          kind: SearchHitKind.lesson,
          quality: quality,
          score: score - n * 0.01,
          matchedText: _snippet(plain, query),
          topicId: topic,
          edition: language,
          page: page,
          block: block,
        ),
      );
    }
    hits.sort((a, b) {
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      final o = content
          .topic(a.topicId!)
          .order
          .compareTo(content.topic(b.topicId!).order);
      return o != 0 ? o : a.block!.compareTo(b.block!);
    });
    return hits.take(limit).toList();
  }

  static const int minQueryLength = 2;

  /// Topic and rule results, best first, de-duplicated per topic/rule.
  List<SearchHit> searchTerms(String query) {
    final q = normalizeStrict(query);
    if (meaningfulLength(q) < minQueryLength) return const [];
    // A query made only of definite articles (e.g. "ال") would prefix-match
    // almost every Arabic entry; require real content after the article.
    final core = q
        .split(' ')
        .map((w) => w.startsWith('ال') ? w.substring(2) : w)
        .join();
    if (meaningfulLength(core) < minQueryLength) return const [];
    final qLoose = normalizeLoose(query);
    final qTokens = q.split(' ');
    final qLooseTokens = qLoose.split(' ');
    final best = <String, SearchHit>{};
    for (final e in _entries) {
      final m =
          _match(q, qTokens, e.strict) ??
          (_match(qLoose, qLooseTokens, e.loose) != null
              ? MatchQuality.folded
              : null);
      if (m == null) continue;
      final score =
          e.weight *
          switch (m) {
            MatchQuality.exact => 100,
            MatchQuality.prefix => 70,
            MatchQuality.contains => 45,
            MatchQuality.folded => 30,
          };
      final key = '${e.kind.name}:${e.ruleId ?? e.topicId}';
      final prev = best[key];
      if (prev == null || prev.score < score) {
        best[key] = SearchHit(
          kind: e.kind,
          quality: m,
          score: score,
          matchedText: e.text,
          topicId: e.topicId,
          ruleId: e.ruleId,
        );
      }
    }
    final list = best.values.toList()
      ..sort((a, b) {
        final c = b.score.compareTo(a.score);
        if (c != 0) return c;
        return content
            .topic(a.topicId!)
            .order
            .compareTo(content.topic(b.topicId!).order);
      });
    return list;
  }

  /// Page hits in the EN/ID text layers. Only whole-word or word-prefix
  /// matches of Latin queries are returned, to avoid noisy partial matches.
  List<SearchHit> searchPages(String query, {String? edition, int limit = 30}) {
    final q = normalizeStrict(query);
    if (meaningfulLength(q) < 3) return const [];
    if (!RegExp(r'[a-z]').hasMatch(q)) return const [];
    final pattern = RegExp('(^| )${RegExp.escape(q)}');
    final hits = <SearchHit>[];
    for (final (ed, page, text, norm) in _pages) {
      if (edition != null && ed != edition) continue;
      final count = pattern.allMatches(norm).length;
      if (count == 0) continue;
      hits.add(
        SearchHit(
          kind: SearchHitKind.page,
          quality: MatchQuality.contains,
          score: count.toDouble(),
          matchedText: _snippet(text, query),
          edition: ed,
          page: page,
          topicId: content.topicsAtPage(ed, page).firstOrNull?.id,
        ),
      );
    }
    hits.sort((a, b) {
      final c = b.score.compareTo(a.score);
      return c != 0 ? c : a.page!.compareTo(b.page!);
    });
    return hits.take(limit).toList();
  }

  static MatchQuality? _match(String q, List<String> qTokens, String entry) {
    if (entry.isEmpty) return null;
    if (entry == q) return MatchQuality.exact;
    final words = searchTokens(entry);
    final qNoArticle = q.length > 3 && q.startsWith('ال') ? q.substring(2) : q;
    if (words.contains(q) || words.contains(qNoArticle)) {
      return words.length == 1 ? MatchQuality.exact : MatchQuality.prefix;
    }
    if (words.any((w) => w.startsWith(q) || w.startsWith(qNoArticle))) {
      return MatchQuality.prefix;
    }
    if (qTokens.length > 1) {
      // Every query word must match the start of some entry word.
      final all = qTokens.every((t) {
        final tt = t.length > 3 && t.startsWith('ال') ? t.substring(2) : t;
        return words.any((w) => w.startsWith(t) || w.startsWith(tt));
      });
      if (all) return MatchQuality.contains;
    }
    // Plain substring is accepted only for longer queries, to avoid noise.
    if (meaningfulLength(q) >= 4 && entry.contains(q)) {
      return MatchQuality.contains;
    }
    return null;
  }

  static String _snippet(String text, String query, {int radius = 60}) {
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query.toLowerCase().trim());
    if (idx < 0) {
      return text.length > radius * 2
          ? '${text.substring(0, radius * 2)}…'
          : text;
    }
    final start = (idx - radius).clamp(0, text.length);
    final end = (idx + query.length + radius).clamp(0, text.length);
    return '${start > 0 ? '…' : ''}${text.substring(start, end).trim()}${end < text.length ? '…' : ''}';
  }
}

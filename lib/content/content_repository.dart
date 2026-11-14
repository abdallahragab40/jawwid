import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';

/// Which supplementary material is visible.
///
/// * `preview` (default for debug and profile builds) shows draft rule cards
///   and questions, clearly labelled as a development preview.
/// * `release` (default for release builds) shows only material whose review
///   status is `reviewed`. Source books, the curriculum and the reader are
///   always available.
///
/// Override with `--dart-define=RATTIL_CONTENT_CHANNEL=release|preview`.
enum ContentChannel { preview, release }

ContentChannel contentChannelFromEnvironment() {
  const value = String.fromEnvironment('RATTIL_CONTENT_CHANNEL');
  if (value == 'release') return ContentChannel.release;
  if (value == 'preview') return ContentChannel.preview;
  return kReleaseMode ? ContentChannel.release : ContentChannel.preview;
}

class ContentRepository {
  ContentRepository({
    required this.contentVersion,
    required this.editions,
    required this.groups,
    required this.topics,
    required this._allRules,
    required this._allQuestions,
    required this.makharij,
    required this.surahNames,
    required this.topicAliases,
    required this.pageText,
    required this.channel,
    this.lessons = const {},
    this.quranVerses = const {},
  });

  /// language -> topic id -> lesson (all review states; see [lesson]).
  final Map<String, Map<String, Lesson>> lessons;

  /// "s:a" -> full Uthmani verse (only verses used by the app).
  final Map<String, String> quranVerses;

  /// The native lesson for [topicId] in [language], if one exists and is
  /// visible in the current content channel.
  Lesson? lesson(String topicId, String language) {
    final l = lessons[language]?[topicId];
    if (l == null || !_visible(l.review)) return null;
    return l;
  }

  /// Whether any native lesson is visible in [language].
  bool hasLessons(String language) =>
      (lessons[language] ?? const {}).values.any((l) => _visible(l.review));

  final String contentVersion;
  final Map<String, Edition> editions;
  final List<TopicGroup> groups;
  final List<Topic> topics;
  final List<RuleCard> _allRules;
  final List<Question> _allQuestions;
  final MakharijData makharij;
  final Map<int, SurahName> surahNames;

  /// topicId -> language -> aliases
  final Map<String, Map<String, List<String>>> topicAliases;

  /// edition -> physical page -> Latin text (EN and ID only)
  final Map<String, Map<int, String>> pageText;
  final ContentChannel channel;

  bool get isPreview => channel == ContentChannel.preview;

  bool _visible(ReviewStatus s) =>
      channel == ContentChannel.preview || s == ReviewStatus.reviewed;

  List<RuleCard> get rules => [
    for (final r in _allRules)
      if (_visible(r.review)) r,
  ];
  List<Question> get questions {
    final visibleRuleIds = rules.map((r) => r.id).toSet();
    return [
      for (final q in _allQuestions)
        if (_visible(q.review) &&
            (q.type != QuestionType.identify ||
                q.ruleOptions.every(visibleRuleIds.contains)))
          q,
    ];
  }

  /// Counts of all supplementary items regardless of channel (for diagnostics).
  int get totalRuleCount => _allRules.length;
  int get totalQuestionCount => _allQuestions.length;

  Topic topic(String id) => topics.firstWhere((t) => t.id == id);
  Topic? topicOrNull(String? id) {
    if (id == null) return null;
    for (final t in topics) {
      if (t.id == id) return t;
    }
    return null;
  }

  RuleCard? rule(String id) {
    for (final r in rules) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<RuleCard> rulesForTopic(String topicId) => [
    for (final r in rules)
      if (r.topicId == topicId) r,
  ];
  List<Question> questionsForTopic(String topicId) => [
    for (final q in questions)
      if (q.topicId == topicId) q,
  ];

  TopicGroup groupOf(Topic t) => groups.firstWhere((g) => g.id == t.groupId);

  /// Topics whose page range in [edition] contains [page], in source order.
  /// Neighbouring topics may share a page (e.g. AR p.98).
  List<Topic> topicsAtPage(String edition, int page) => [
    for (final t in topics)
      if (t.pagesIn(edition)?.contains(page) ?? false) t,
  ];

  /// The first page of [topicId] in [edition], or null if the edition lacks it.
  int? startPage(String topicId, String edition) =>
      topic(topicId).pagesIn(edition)?.start;

  /// Maps a position in one edition to the equivalent position in another by
  /// stable topic id. Keeps the relative offset inside the topic when possible.
  /// Returns null when the topic is absent from [toEdition].
  int? equivalentPage({
    required String topicId,
    required String fromEdition,
    required int fromPage,
    required String toEdition,
  }) {
    final t = topic(topicId);
    final from = t.pagesIn(fromEdition);
    final to = t.pagesIn(toEdition);
    if (to == null) return null;
    if (from == null || !from.contains(fromPage)) return to.start;
    final offset = fromPage - from.start;
    return to.start + (offset < to.length ? offset : to.length - 1);
  }

  static Future<ContentRepository> load({
    AssetBundle? bundle,
    ContentChannel? channel,
  }) async {
    final b = bundle ?? rootBundle;
    Future<Map<String, dynamic>> read(String name) async =>
        jsonDecode(await b.loadString('assets/content/$name'))
            as Map<String, dynamic>;
    final results = await Future.wait([
      read('editions.json'),
      read('curriculum.json'),
      read('rules.json'),
      read('quiz.json'),
      read('makharij.json'),
      read('quran.json'),
      read('search_terms.json'),
      read('search_pages.json'),
      for (final l in const ['ar', 'ckb', 'en', 'id']) read('lessons_$l.json'),
    ]);
    return fromJson(
      editions: results[0],
      curriculum: results[1],
      rules: results[2],
      quiz: results[3],
      makharij: results[4],
      quran: results[5],
      searchTerms: results[6],
      searchPages: results[7],
      lessons: {
        for (var i = 0; i < 4; i++)
          const ['ar', 'ckb', 'en', 'id'][i]: results[8 + i],
      },
      channel: channel ?? contentChannelFromEnvironment(),
    );
  }

  static ContentRepository fromJson({
    required Map<String, dynamic> editions,
    required Map<String, dynamic> curriculum,
    required Map<String, dynamic> rules,
    required Map<String, dynamic> quiz,
    required Map<String, dynamic> makharij,
    required Map<String, dynamic> quran,
    required Map<String, dynamic> searchTerms,
    required Map<String, dynamic> searchPages,
    required ContentChannel channel,
    Map<String, Map<String, dynamic>> lessons = const {},
  }) {
    final eds = {
      for (final e in editions['editions'] as List)
        (e as Map<String, dynamic>)['id'] as String: Edition.fromJson(e),
    };
    final groups = <TopicGroup>[];
    final groupOfTopic = <String, String>{};
    for (final g in curriculum['groups'] as List) {
      final m = g as Map<String, dynamic>;
      final ids = (m['topics'] as List).cast<String>();
      groups.add(
        TopicGroup(
          id: m['id'] as String,
          title: Localized.strings(m['title']),
          topicIds: ids,
        ),
      );
      for (final id in ids) {
        groupOfTopic[id] = m['id'] as String;
      }
    }
    final topics = <Topic>[];
    for (final t in curriculum['topics'] as List) {
      final m = t as Map<String, dynamic>;
      final pages = <String, PageRange?>{};
      (m['pages'] as Map<String, dynamic>).forEach((k, v) {
        pages[k] = v == null
            ? null
            : PageRange((v as List)[0] as int, v[1] as int);
      });
      final partial = <String, Localized<String>>{};
      ((m['partial'] as Map<String, dynamic>?) ?? const {}).forEach(
        (k, v) => partial[k] = Localized.strings(v),
      );
      topics.add(
        Topic(
          id: m['id'] as String,
          order: (m['order'] as num).toInt(),
          groupId: groupOfTopic[m['id']]!,
          title: Localized.statusTexts(m['title']),
          pages: pages,
          partialNotes: partial,
        ),
      );
    }
    topics.sort((a, b) => a.order.compareTo(b.order));

    final surahs = <int, SurahName>{};
    (quran['surahNames'] as Map<String, dynamic>).forEach((k, v) {
      final m = v as Map<String, dynamic>;
      surahs[int.parse(k)] = SurahName(m['ar'] as String, m['latin'] as String);
    });

    final aliases = <String, Map<String, List<String>>>{};
    (searchTerms['topics'] as Map<String, dynamic>).forEach((topicId, v) {
      aliases[topicId] = (v as Map<String, dynamic>).map(
        (lang, list) => MapEntry(lang, (list as List).cast<String>()),
      );
    });

    final pageText = <String, Map<int, String>>{};
    (searchPages['editions'] as Map<String, dynamic>).forEach((ed, pages) {
      pageText[ed] = (pages as Map<String, dynamic>).map(
        (p, t) => MapEntry(int.parse(p), t as String),
      );
    });

    return ContentRepository(
      contentVersion: curriculum['contentVersion'] as String,
      editions: eds,
      groups: groups,
      topics: topics,
      allRules: [
        for (final r in rules['rules'] as List)
          RuleCard.fromJson(r as Map<String, dynamic>),
      ],
      allQuestions: [
        for (final q in quiz['questions'] as List)
          Question.fromJson(q as Map<String, dynamic>),
      ],
      makharij: MakharijData.fromJson(makharij),
      surahNames: surahs,
      topicAliases: aliases,
      pageText: pageText,
      channel: channel,
      lessons: {
        for (final e in lessons.entries)
          e.key: {
            for (final l
                in ((e.value['lessons'] as Map<String, dynamic>?) ?? const {})
                    .entries)
              l.key: Lesson.fromJson(e.key, l.value as Map<String, dynamic>),
          },
      },
      quranVerses: (quran['verses'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }
}

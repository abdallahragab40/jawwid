/// Typed models for the bundled, read-only content.
library;

/// How a piece of text came to be in the app.
enum TextStatus {
  /// Typed from the page image of the edition. Needs proofreading.
  sourceTranscribed,

  /// Taken from the edition's PDF text layer.
  sourceExtracted,

  /// Written for the app. Needs subject (and, for Kurdish, language) review.
  authored,

  /// Approved by a qualified reviewer.
  reviewed;

  static TextStatus parse(String? s) => TextStatus.values.firstWhere(
    (v) => v.name == s,
    orElse: () => TextStatus.authored,
  );
}

enum ReviewStatus {
  draft,
  reviewed;

  static ReviewStatus parse(String? s) =>
      s == 'reviewed' ? ReviewStatus.reviewed : ReviewStatus.draft;
}

class StatusText {
  const StatusText(this.text, this.status, {this.page});
  final String text;
  final TextStatus status;
  final int? page;

  static StatusText fromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return StatusText(
      m['text'] as String,
      TextStatus.parse(m['status'] as String?),
      page: (m['page'] as num?)?.toInt(),
    );
  }
}

/// A language-keyed map (`ar`, `ckb`, `en`, `id`).
class Localized<T> {
  const Localized(this.values);
  final Map<String, T> values;

  T? operator [](String lang) => values[lang];

  /// The value for [lang]; falls back to Arabic, then to any value.
  T of(String lang) => values[lang] ?? values['ar'] ?? values.values.first;

  static Localized<String> strings(dynamic j) => Localized(
    (j as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String)),
  );

  static Localized<StatusText> statusTexts(dynamic j) => Localized(
    (j as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, StatusText.fromJson(v)),
    ),
  );
}

class PrintedNumbering {
  const PrintedNumbering({
    required this.firstNumbered,
    required this.lastNumbered,
    required this.offset,
    this.overrides = const {},
  });

  /// Physical page -> number actually printed (null = no visible number),
  /// where the book deviates from the regular sequence.
  final Map<int, int?> overrides;
  final int firstNumbered;
  final int lastNumbered;

  /// printed = physical - offset (0 in all four editions).
  final int offset;
}

class Edition {
  const Edition({
    required this.id,
    required this.title,
    required this.level,
    required this.asset,
    required this.pageCount,
    required this.numbering,
    required this.author,
    required this.translator,
    required this.isRtl,
    required this.introPage,
    required this.referencesPage,
    required this.topicListPage,
    this.blankPages = const {},
  });

  final String id;
  final String title;
  final String level;
  final String asset;
  final int pageCount;
  final PrintedNumbering numbering;
  final String author;
  final String? translator;
  final bool isRtl;
  final int introPage;
  final int referencesPage;
  final int? topicListPage;

  /// Physical pages with no content (the white page after the cover, before
  /// the back cover). The reader gives them no space; the PDF is unchanged.
  final Set<int> blankPages;

  /// The page to show instead of a blank one: the next page with content,
  /// or the previous one at the end of the book.
  int nearestContentPage(int physical) {
    if (!blankPages.contains(physical)) return physical;
    for (var p = physical + 1; p <= pageCount; p++) {
      if (!blankPages.contains(p)) return p;
    }
    for (var p = physical - 1; p >= 1; p--) {
      if (!blankPages.contains(p)) return p;
    }
    return physical;
  }

  /// The page number printed on physical page [physical] (1-based), or null
  /// when that page carries no printed number (covers, blank pages).
  int? printedNumberOf(int physical) {
    if (physical < 1 || physical > pageCount) return null;
    if (numbering.overrides.containsKey(physical)) {
      return numbering.overrides[physical];
    }
    if (physical < numbering.firstNumbered ||
        physical > numbering.lastNumbered) {
      return null;
    }
    return physical - numbering.offset;
  }

  /// The physical page that carries printed number [printed], or null.
  /// Prefers the page in the regular sequence; a number missing from the
  /// page itself (see [PrintedNumbering.overrides]) still resolves to the
  /// page at that position in the sequence.
  int? physicalForPrinted(int printed) {
    final physical = printed + numbering.offset;
    if (physical < numbering.firstNumbered ||
        physical > numbering.lastNumbered) {
      return null;
    }
    return physical;
  }

  static Edition fromJson(Map<String, dynamic> j) {
    final n = j['numbering'] as Map<String, dynamic>;
    final fm = j['frontMatter'] as Map<String, dynamic>;
    return Edition(
      blankPages: {
        for (final p in (j['blankPages'] as List?) ?? const [])
          (p as num).toInt(),
      },
      id: j['id'] as String,
      title: j['title'] as String,
      level: j['level'] as String,
      asset: j['asset'] as String,
      pageCount: (j['pageCount'] as num).toInt(),
      numbering: PrintedNumbering(
        firstNumbered: (n['firstNumbered'] as num).toInt(),
        lastNumbered: (n['lastNumbered'] as num).toInt(),
        offset: (n['offset'] as num).toInt(),
        overrides: {
          for (final e
              in ((n['printedOverrides'] as Map<String, dynamic>?) ?? const {})
                  .entries)
            int.parse(e.key): (e.value as num?)?.toInt(),
        },
      ),
      author: j['author'] as String,
      translator: j['translator'] as String?,
      isRtl: j['direction'] == 'rtl',
      introPage: (fm['intro'] as num).toInt(),
      referencesPage: (fm['references'] as num).toInt(),
      topicListPage: (fm['topicList'] as num?)?.toInt(),
    );
  }
}

class PageRange {
  const PageRange(this.start, this.end);
  final int start;
  final int end;
  int get length => end - start + 1;
  bool contains(int page) => page >= start && page <= end;
}

class Topic {
  const Topic({
    required this.id,
    required this.order,
    required this.groupId,
    required this.title,
    required this.pages,
    required this.partialNotes,
  });

  final String id;
  final int order;
  final String groupId;
  final Localized<StatusText> title;

  /// Physical page ranges per edition; `null` when the edition has no equivalent.
  final Map<String, PageRange?> pages;

  /// Per edition: a note (keyed by UI language) explaining partial coverage.
  final Map<String, Localized<String>> partialNotes;

  PageRange? pagesIn(String edition) => pages[edition];
  bool isAvailableIn(String edition) => pages[edition] != null;
  bool isPartialIn(String edition) => partialNotes.containsKey(edition);
}

class TopicGroup {
  const TopicGroup({
    required this.id,
    required this.title,
    required this.topicIds,
  });
  final String id;
  final Localized<String> title;
  final List<String> topicIds;
}

/// A verified Qur'anic excerpt. The text is copied verbatim from Tanzil by
/// tools/build_content.py; [highlights] are UTF-16 ranges into [text] that
/// always cover whole letters including their marks.
class QuranExcerpt {
  const QuranExcerpt({
    required this.surah,
    required this.ayah,
    required this.text,
    required this.isWholeAyah,
    required this.highlights,
  });

  final int surah;
  final int ayah;
  final String text;
  final bool isWholeAyah;
  final List<(int, int)> highlights;

  static QuranExcerpt fromJson(Map<String, dynamic> j) => QuranExcerpt(
    surah: (j['surah'] as num).toInt(),
    ayah: (j['ayah'] as num).toInt(),
    text: j['text'] as String,
    isWholeAyah: j['isWholeAyah'] as bool? ?? false,
    highlights: [
      for (final h in j['highlights'] as List)
        ((h as List)[0] as int, h[1] as int),
    ],
  );
}

class RuleCard {
  const RuleCard({
    required this.id,
    required this.topicId,
    required this.title,
    required this.definition,
    required this.letters,
    required this.lettersExcept,
    required this.example,
    required this.explanation,
    required this.review,
  });

  final String id;
  final String topicId;
  final Localized<String> title;
  final Localized<StatusText> definition;
  final String? letters;
  final String? lettersExcept;
  final QuranExcerpt example;
  final Localized<String> explanation;
  final ReviewStatus review;

  static RuleCard fromJson(Map<String, dynamic> j) => RuleCard(
    id: j['id'] as String,
    topicId: j['topic'] as String,
    title: Localized.strings(j['title']),
    definition: Localized.statusTexts(j['definition']),
    letters: j['letters'] as String?,
    lettersExcept: j['lettersExcept'] as String?,
    example: QuranExcerpt.fromJson(j['example'] as Map<String, dynamic>),
    explanation: Localized.strings(j['explanation']),
    review: ReviewStatus.parse((j['review'] as Map?)?['status'] as String?),
  );
}

enum QuestionType { identify, choice, trueFalse }

/// One answer option for a [QuestionType.choice] question.
class ChoiceOption {
  const ChoiceOption({this.number, this.arabic, this.counts, this.text});
  final String? number;
  final String? arabic;
  final String? counts;

  /// An answer written in each interface language.
  final Localized<String>? text;
}

class Question {
  const Question({
    required this.id,
    required this.type,
    required this.topicId,
    required this.ruleId,
    required this.example,
    required this.ruleOptions,
    required this.answerRuleId,
    required this.prompt,
    required this.choices,
    required this.answerIndex,
    required this.answerBool,
    required this.explanation,
    required this.review,
  });

  final String id;
  final QuestionType type;
  final String topicId;
  final String? ruleId;
  final QuranExcerpt? example;
  final List<String> ruleOptions;
  final String? answerRuleId;
  final Localized<String>? prompt;
  final List<ChoiceOption> choices;
  final int? answerIndex;
  final bool? answerBool;
  final Localized<String> explanation;
  final ReviewStatus review;

  /// Rule card this question practises (the answer for identify questions).
  String? get relatedRuleId => answerRuleId ?? ruleId;

  static Question fromJson(Map<String, dynamic> j) {
    final type = switch (j['type']) {
      'identify' => QuestionType.identify,
      'truefalse' => QuestionType.trueFalse,
      _ => QuestionType.choice,
    };
    return Question(
      id: j['id'] as String,
      type: type,
      topicId: j['topic'] as String,
      ruleId: j['rule'] as String?,
      example: j['example'] == null
          ? null
          : QuranExcerpt.fromJson(j['example'] as Map<String, dynamic>),
      ruleOptions: type == QuestionType.identify
          ? (j['options'] as List).cast<String>()
          : const [],
      answerRuleId: type == QuestionType.identify
          ? j['answer'] as String
          : null,
      prompt: j['prompt'] == null ? null : Localized.strings(j['prompt']),
      choices: type == QuestionType.choice
          ? [
              for (final o in j['options'] as List)
                ChoiceOption(
                  number: (o as Map)['number'] as String?,
                  arabic: o['arabic'] as String?,
                  counts: o['counts'] as String?,
                  text: o['text'] == null ? null : Localized.strings(o['text']),
                ),
            ]
          : const [],
      answerIndex: type == QuestionType.choice
          ? (j['answer'] as num).toInt()
          : null,
      answerBool: type == QuestionType.trueFalse ? j['answer'] as bool : null,
      explanation: Localized.strings(j['explanation']),
      review: ReviewStatus.parse((j['review'] as Map?)?['status'] as String?),
    );
  }
}

class Landmark {
  const Landmark({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
  });
  final String id;
  final double x;
  final double y;
  final Localized<String> label;
}

class MakhrajArea {
  const MakhrajArea({
    required this.id,
    required this.name,
    required this.pointIds,
  });
  final String id;
  final Localized<String> name;
  final List<String> pointIds;
}

class MakhrajPoint {
  const MakhrajPoint({
    required this.id,
    required this.areaId,
    required this.letters,
    required this.landmarkIds,
    required this.unmarked,
    required this.pages,
    required this.name,
    required this.text,
  });

  final String id;
  final String areaId;
  final String letters;
  final List<String> landmarkIds;

  /// True when the book's diagram has no marker for this point.
  final bool unmarked;
  final Map<String, int> pages;
  final Localized<String> name;
  final Localized<StatusText> text;
}

class MakharijData {
  const MakharijData({
    required this.imageAsset,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageSourcePages,
    required this.landmarks,
    required this.areas,
    required this.points,
  });

  final String imageAsset;
  final int imageWidth;
  final int imageHeight;
  final Map<String, int> imageSourcePages;
  final List<Landmark> landmarks;
  final List<MakhrajArea> areas;
  final List<MakhrajPoint> points;

  Landmark landmark(String id) => landmarks.firstWhere((l) => l.id == id);
  MakhrajPoint point(String id) => points.firstWhere((p) => p.id == id);

  static MakharijData fromJson(Map<String, dynamic> j) {
    final img = j['image'] as Map<String, dynamic>;
    Map<String, int> intMap(dynamic m) => (m as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    );
    return MakharijData(
      imageAsset: img['asset'] as String,
      imageWidth: (img['width'] as num).toInt(),
      imageHeight: (img['height'] as num).toInt(),
      imageSourcePages: intMap(img['sourcePages']),
      landmarks: [
        for (final l in j['landmarks'] as List)
          Landmark(
            id: (l as Map)['id'] as String,
            x: (l['x'] as num).toDouble(),
            y: (l['y'] as num).toDouble(),
            label: Localized.strings(l['label']),
          ),
      ],
      areas: [
        for (final a in j['areas'] as List)
          MakhrajArea(
            id: (a as Map)['id'] as String,
            name: Localized.strings(a['name']),
            pointIds: (a['points'] as List).cast<String>(),
          ),
      ],
      points: [
        for (final p in j['points'] as List)
          MakhrajPoint(
            id: (p as Map)['id'] as String,
            areaId: p['area'] as String,
            letters: p['letters'] as String,
            landmarkIds: (p['landmarks'] as List).cast<String>(),
            unmarked: p['unmarked'] as bool? ?? false,
            pages: intMap(p['pages']),
            name: Localized.strings(p['name']),
            text: Localized.statusTexts(p['text']),
          ),
      ],
    );
  }
}

class SurahName {
  const SurahName(this.arabic, this.latin);
  final String arabic;
  final String latin;
}

// ---------------------------------------------------------------------------
// Native lessons (full text of each topic, transcribed or extracted from the
// edition, see tools/build_lessons.py). The PDF page stays the reference.

/// One inline run of lesson text.
class LessonSpan {
  const LessonSpan({this.text, this.emphasis, this.arabic, this.quran});

  /// Plain text.
  final String? text;

  /// Emphasised text (the books' red).
  final String? emphasis;

  /// Arabic (non-Qur'anic) text, always shown right-to-left.
  final String? arabic;

  /// A verified Qur'anic excerpt.
  final QuranExcerpt? quran;

  /// Plain text of this span, for search and accessibility.
  String get plain => text ?? emphasis ?? arabic ?? quran?.text ?? '';

  static LessonSpan fromJson(Map<String, dynamic> j) => LessonSpan(
    text: j['x'] as String?,
    emphasis: j['e'] as String?,
    arabic: j['a'] as String?,
    quran: j['q'] == null
        ? null
        : QuranExcerpt.fromJson(j['q'] as Map<String, dynamic>),
  );

  static List<LessonSpan> listFromJson(dynamic j) => [
    for (final s in (j as List?) ?? const [])
      LessonSpan.fromJson(s as Map<String, dynamic>),
  ];
}

enum LessonBlockType { h1, h2, h3, p, li, ol, note, def, table, img, crop }

class LessonBlock {
  const LessonBlock({
    required this.type,
    required this.page,
    this.spans = const [],
    this.term = const [],
    this.number,
    this.rows = const [],
    this.imageKey,
    this.asset,
    this.aspectRatio,
  });

  final LessonBlockType type;

  /// For [LessonBlockType.crop]: the illustration cropped from the book page.
  final String? asset;
  final double? aspectRatio;

  /// Physical PDF page this block was taken from.
  final int page;
  final List<LessonSpan> spans;

  /// For [LessonBlockType.def]: the label ("Definition").
  final List<LessonSpan> term;

  /// For [LessonBlockType.ol]: the number as printed.
  final String? number;

  /// For [LessonBlockType.table]: rows of cells; the first row is the header.
  final List<List<List<LessonSpan>>> rows;
  final String? imageKey;

  /// Plain text of the block, for search.
  String get plain {
    final parts = <String>[
      for (final s in term) s.plain,
      for (final s in spans) s.plain,
      for (final r in rows)
        for (final c in r)
          for (final s in c) s.plain,
    ];
    return parts.join(' ');
  }

  static LessonBlock fromJson(Map<String, dynamic> j) => LessonBlock(
    type: LessonBlockType.values.byName(j['t'] as String),
    page: (j['page'] as num).toInt(),
    spans: LessonSpan.listFromJson(j['s']),
    term: LessonSpan.listFromJson(j['k']),
    number: j['n'] as String?,
    rows: [
      for (final r in (j['rows'] as List?) ?? const [])
        [for (final c in r as List) LessonSpan.listFromJson(c)],
    ],
    imageKey: j['key'] as String?,
    asset: j['asset'] as String?,
    aspectRatio: j['w'] == null ? null : (j['w'] as num) / (j['h'] as num),
  );
}

class Lesson {
  const Lesson({
    required this.topicId,
    required this.language,
    required this.status,
    required this.review,
    required this.blocks,
  });

  final String topicId;
  final String language;
  final TextStatus status;
  final ReviewStatus review;
  final List<LessonBlock> blocks;

  static Lesson fromJson(String language, Map<String, dynamic> j) => Lesson(
    topicId: j['topic'] as String,
    language: language,
    status: TextStatus.parse(j['status'] as String?),
    review: ReviewStatus.parse(j['review'] as String?),
    blocks: [
      for (final b in j['blocks'] as List)
        LessonBlock.fromJson(b as Map<String, dynamic>),
    ],
  );
}

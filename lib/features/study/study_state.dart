import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_repository.dart';
import '../../content/language.dart';
import '../../core/json_store.dart';
import '../practice/saved_session.dart';

enum ReaderTheme { light, sepia, night }

const lessonTextScaleMin = 0.85;
const lessonTextScaleMax = 1.5;

/// App colour scheme: follow the device, or always light / dark.
enum AppThemeChoice { system, light, dark }

/// Reading progress is separate from quiz performance.
enum TopicProgress { none, read, completed }

/// Preferred next activity; never locks lessons or changes earned progress.
enum LearningIntent { guided, revision, explore }

class Bookmark {
  const Bookmark({
    required this.id,
    required this.edition,
    required this.page,
    required this.createdAt,
  });
  final String id;
  final String edition;
  final int page;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'edition': edition,
    'page': page,
    'createdAt': createdAt.toIso8601String(),
  };
  static Bookmark fromJson(Map<String, dynamic> j) => Bookmark(
    id: j['id'] as String,
    edition: j['edition'] as String,
    page: (j['page'] as num).toInt(),
    createdAt:
        DateTime.tryParse(j['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class Note {
  const Note({
    required this.id,
    required this.edition,
    required this.page,
    required this.topicId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.lessonBlock,
    this.sectionTitle,
  });
  final String id;
  final String edition;
  final int page;
  final String? topicId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? lessonBlock;
  final String? sectionTitle;

  Note copyWith({String? text, DateTime? updatedAt}) => Note(
    id: id,
    edition: edition,
    page: page,
    topicId: topicId,
    text: text ?? this.text,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lessonBlock: lessonBlock,
    sectionTitle: sectionTitle,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'edition': edition,
    'page': page,
    'topicId': topicId,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lessonBlock': lessonBlock,
    'sectionTitle': sectionTitle,
  };
  static Note fromJson(Map<String, dynamic> j) => Note(
    id: j['id'] as String,
    edition: j['edition'] as String,
    page: (j['page'] as num).toInt(),
    topicId: j['topicId'] as String?,
    text: j['text'] as String? ?? '',
    lessonBlock: (j['lessonBlock'] as num?)?.toInt(),
    sectionTitle: j['sectionTitle'] as String?,
    createdAt:
        DateTime.tryParse(j['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt:
        DateTime.tryParse(j['updatedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class QuizRecord {
  const QuizRecord({
    required this.attempts,
    required this.correct,
    required this.lastCorrect,
    required this.lastAt,
    this.reviewStage = 0,
    this.nextReviewAt,
  });
  final int attempts;
  final int correct;
  final bool lastCorrect;
  final DateTime lastAt;
  final int reviewStage;
  final DateTime? nextReviewAt;

  bool isDue(DateTime now) =>
      nextReviewAt == null || !nextReviewAt!.isAfter(now);

  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'correct': correct,
    'lastCorrect': lastCorrect,
    'lastAt': lastAt.toIso8601String(),
    'reviewStage': reviewStage,
    'nextReviewAt': nextReviewAt?.toIso8601String(),
  };
  static QuizRecord fromJson(Map<String, dynamic> j) => QuizRecord(
    reviewStage: ((j['reviewStage'] as num?)?.toInt() ?? 0).clamp(0, 4),
    nextReviewAt: DateTime.tryParse(j['nextReviewAt'] as String? ?? ''),
    attempts: (j['attempts'] as num?)?.toInt() ?? 0,
    correct: (j['correct'] as num?)?.toInt() ?? 0,
    lastCorrect: j['lastCorrect'] as bool? ?? false,
    lastAt:
        DateTime.tryParse(j['lastAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class LastRead {
  const LastRead({
    required this.edition,
    required this.page,
    required this.topicId,
    required this.at,
  });
  final String edition;
  final int page;
  final String? topicId;
  final DateTime at;
  Map<String, dynamic> toJson() => {
    'edition': edition,
    'page': page,
    'topicId': topicId,
    'at': at.toIso8601String(),
  };
  static LastRead? fromJson(dynamic j) {
    if (j is! Map) return null;
    return LastRead(
      edition: j['edition'] as String,
      page: (j['page'] as num).toInt(),
      topicId: j['topicId'] as String?,
      at:
          DateTime.tryParse(j['at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class StudyState {
  const StudyState({
    this.language = AppLanguage.ar,
    this.readerTheme = ReaderTheme.light,
    this.dimNightPages = false,
    this.positions = const {},
    this.lessonPositions = const {},
    this.lastRead,
    this.bookmarks = const [],
    this.notes = const [],
    this.topicProgress = const {},
    this.quiz = const {},
    this.savedSession,
    this.recentSearches = const {},
    this.favoriteRules = const {},
    this.streakEnabled = false,
    this.studyDays = const {},
    this.learningDays = const {},
    this.weeklyGoal = 3,
    this.hapticsEnabled = true,
    this.reminderEnabled = false,
    this.reminderMinutes = 20 * 60,
    this.appTheme = AppThemeChoice.system,
    this.lessonTextScale = 1.0,
    this.welcomed = false,
    this.learningIntent = LearningIntent.guided,
  });

  /// Arabic on first launch, regardless of device language.
  final AppLanguage language;
  final ReaderTheme readerTheme;

  /// Night theme only: uniformly dims page images (hue-preserving).
  final bool dimNightPages;

  /// Remembered reading position per edition.
  final Map<String, int> positions;
  final Map<String, int> lessonPositions;
  final LastRead? lastRead;
  final List<Bookmark> bookmarks;
  final List<Note> notes;
  final Map<String, TopicProgress> topicProgress;
  final Map<String, QuizRecord> quiz;
  final SavedSession? savedSession;
  final Map<String, List<String>> recentSearches;
  final Set<String> favoriteRules;
  final bool streakEnabled;

  /// Days (yyyy-mm-dd, local) on which the learner read or practised.
  final Set<String> studyDays;

  /// Days with an answer or explicit lesson completion, not just a page open.
  final Set<String> learningDays;
  final int weeklyGoal;

  /// Light touch feedback on taps that change something.
  final bool hapticsEnabled;

  /// Daily study reminder (local notification), off until the learner asks.
  final bool reminderEnabled;

  /// Time of the reminder, in minutes after local midnight.
  final int reminderMinutes;

  final AppThemeChoice appTheme;

  /// Extra scale for lesson text, on top of the system text size.
  final double lessonTextScale;

  /// The welcome screen has been seen (first launch only).
  final bool welcomed;
  final LearningIntent learningIntent;

  StudyState copyWith({
    AppLanguage? language,
    ReaderTheme? readerTheme,
    bool? dimNightPages,
    Map<String, int>? positions,
    Map<String, int>? lessonPositions,
    LastRead? lastRead,
    List<Bookmark>? bookmarks,
    List<Note>? notes,
    Map<String, TopicProgress>? topicProgress,
    Map<String, QuizRecord>? quiz,
    SavedSession? savedSession,
    bool clearSavedSession = false,
    Map<String, List<String>>? recentSearches,
    Set<String>? favoriteRules,
    bool? streakEnabled,
    Set<String>? studyDays,
    Set<String>? learningDays,
    int? weeklyGoal,
    bool? hapticsEnabled,
    bool? reminderEnabled,
    int? reminderMinutes,
    AppThemeChoice? appTheme,
    double? lessonTextScale,
    bool? welcomed,
    LearningIntent? learningIntent,
  }) => StudyState(
    language: language ?? this.language,
    readerTheme: readerTheme ?? this.readerTheme,
    dimNightPages: dimNightPages ?? this.dimNightPages,
    positions: positions ?? this.positions,
    lessonPositions: lessonPositions ?? this.lessonPositions,
    lastRead: lastRead ?? this.lastRead,
    bookmarks: bookmarks ?? this.bookmarks,
    notes: notes ?? this.notes,
    topicProgress: topicProgress ?? this.topicProgress,
    quiz: quiz ?? this.quiz,
    savedSession: clearSavedSession ? null : savedSession ?? this.savedSession,
    recentSearches: recentSearches ?? this.recentSearches,
    favoriteRules: favoriteRules ?? this.favoriteRules,
    streakEnabled: streakEnabled ?? this.streakEnabled,
    studyDays: studyDays ?? this.studyDays,
    learningDays: learningDays ?? this.learningDays,
    weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    appTheme: appTheme ?? this.appTheme,
    lessonTextScale: lessonTextScale ?? this.lessonTextScale,
    welcomed: welcomed ?? this.welcomed,
    learningIntent: learningIntent ?? this.learningIntent,
  );

  TopicProgress progressOf(String topicId) =>
      topicProgress[topicId] ?? TopicProgress.none;

  bool isBookmarked(String edition, int page) =>
      bookmarks.any((b) => b.edition == edition && b.page == page);

  List<Note> notesAt(String edition, int page) => [
    for (final n in notes)
      if (n.edition == edition && n.page == page) n,
  ];

  /// Consecutive study days ending today or yesterday (no guilt: a missed day
  /// simply ends the count; the UI never scolds).
  int currentStreak(DateTime now) {
    // UTC is used only as a calendar-date label, preserving now's local date.
    var day = DateTime.utc(now.year, now.month, now.day);
    if (!studyDays.contains(dayKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (studyDays.contains(dayKey(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'language': language.code,
    'readerTheme': readerTheme.name,
    'dimNightPages': dimNightPages,
    'positions': positions,
    'lessonPositions': lessonPositions,
    'lastRead': lastRead?.toJson(),
    'bookmarks': [for (final b in bookmarks) b.toJson()],
    'notes': [for (final n in notes) n.toJson()],
    'topicStatus': {
      for (final e in topicProgress.entries) e.key: {'status': e.value.name},
    },
    'quiz': {for (final e in quiz.entries) e.key: e.value.toJson()},
    'savedSession': savedSession?.toJson(),
    'recentSearches': recentSearches,
    'favoriteRules': favoriteRules.toList()..sort(),
    'streak': {'enabled': streakEnabled, 'days': (studyDays.toList()..sort())},
    'learningDays': learningDays.toList()..sort(),
    'weeklyGoal': weeklyGoal,
    'haptics': hapticsEnabled,
    'reminder': {'enabled': reminderEnabled, 'minutes': reminderMinutes},
    'appTheme': appTheme.name,
    'lessonTextScale': lessonTextScale,
    'welcomed': welcomed,
    'learningIntent': learningIntent.name,
  };

  static StudyState fromJson(Map<String, dynamic> j) {
    final positions = <String, int>{};
    ((j['positions'] as Map?) ?? const {}).forEach((k, v) {
      if (v is num) positions[k as String] = v.toInt();
    });
    final progress = <String, TopicProgress>{};
    ((j['topicStatus'] as Map?) ?? const {}).forEach((k, v) {
      final s = v is Map ? v['status'] : v;
      progress[k as String] = TopicProgress.values.firstWhere(
        (p) => p.name == s,
        orElse: () => TopicProgress.none,
      );
    });
    final quiz = <String, QuizRecord>{};
    ((j['quiz'] as Map?) ?? const {}).forEach((k, v) {
      if (v is Map<String, dynamic>) quiz[k as String] = QuizRecord.fromJson(v);
    });
    final streak = (j['streak'] as Map?) ?? const {};
    final reminder = (j['reminder'] as Map?) ?? const {};
    final minutes = (reminder['minutes'] as num?)?.toInt() ?? 20 * 60;
    return StudyState(
      learningIntent: LearningIntent.values.firstWhere(
        (v) => v.name == j['learningIntent'],
        orElse: () => LearningIntent.guided,
      ),
      language: AppLanguage.fromCode(j['language'] as String?),
      readerTheme: ReaderTheme.values.firstWhere(
        (t) => t.name == j['readerTheme'],
        orElse: () => ReaderTheme.light,
      ),
      dimNightPages: j['dimNightPages'] as bool? ?? false,
      positions: positions,
      lessonPositions: {
        for (final e in ((j['lessonPositions'] as Map?) ?? const {}).entries)
          if (e.key is String && e.value is int && e.value >= 0)
            e.key as String: e.value as int,
      },
      lastRead: LastRead.fromJson(j['lastRead']),
      bookmarks: [
        for (final b in (j['bookmarks'] as List?) ?? const [])
          Bookmark.fromJson(b as Map<String, dynamic>),
      ],
      notes: [
        for (final n in (j['notes'] as List?) ?? const [])
          Note.fromJson(n as Map<String, dynamic>),
      ],
      topicProgress: progress,
      quiz: quiz,
      savedSession: SavedSession.fromJson(j['savedSession']),
      favoriteRules: {
        for (final id in (j['favoriteRules'] as List?) ?? const [])
          if (id is String) id,
      },
      recentSearches: {
        for (final e in ((j['recentSearches'] as Map?) ?? const {}).entries)
          if (e.key is String && e.value is List)
            e.key as String: (e.value as List)
                .whereType<String>()
                .where((s) => s.trim().isNotEmpty && s.length <= 120)
                .take(8)
                .toList(),
      },
      streakEnabled: streak['enabled'] as bool? ?? false,
      studyDays: {
        for (final d in (streak['days'] as List?) ?? const []) d as String,
      },
      learningDays: {
        for (final day in (j['learningDays'] as List?) ?? const [])
          if (day is String) day,
      },
      weeklyGoal: ((j['weeklyGoal'] as num?)?.toInt() ?? 3).clamp(1, 7),
      hapticsEnabled: j['haptics'] as bool? ?? true,
      reminderEnabled: reminder['enabled'] as bool? ?? false,
      reminderMinutes: minutes.clamp(0, 24 * 60 - 1),
      appTheme: AppThemeChoice.values.firstWhere(
        (t) => t.name == j['appTheme'],
        orElse: () => AppThemeChoice.system,
      ),
      // Data saved before the welcome screen existed means it is not a
      // first launch.
      welcomed: j['welcomed'] as bool? ?? j.containsKey('language'),
      lessonTextScale: ((j['lessonTextScale'] as num?)?.toDouble() ?? 1.0)
          .clamp(lessonTextScaleMin, lessonTextScaleMax),
    );
  }
}

// ---------------------------------------------------------------------------
// Providers. `contentProvider`, `storeProvider` and `initialStudyStateProvider`
// are overridden at start-up (see main.dart) and in tests.

final contentProvider = Provider<ContentRepository>(
  (ref) => throw UnimplementedError('contentProvider'),
);
final storeProvider = Provider<JsonStore?>((ref) => null);
final initialStudyStateProvider = Provider<StudyState>(
  (ref) => const StudyState(),
);
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final studyProvider = NotifierProvider<StudyController, StudyState>(
  StudyController.new,
);

final languageProvider = Provider<AppLanguage>(
  (ref) => ref.watch(studyProvider.select((s) => s.language)),
);

enum StudySaveStatus { saved, pending, failed }

final studySaveStatusProvider =
    NotifierProvider<StudySaveStatusController, StudySaveStatus>(
      StudySaveStatusController.new,
    );

class StudySaveStatusController extends Notifier<StudySaveStatus> {
  @override
  StudySaveStatus build() => StudySaveStatus.saved;

  void update(StudySaveStatus value) => state = value;
}

class StudyController extends Notifier<StudyState> {
  Timer? _debounce;
  JsonStore? _store;
  late StudyState _latest;
  bool _dirty = false;

  @override
  StudyState build() {
    _store = ref.read(storeProvider);
    _latest = ref.read(initialStudyStateProvider);
    ref.onDispose(() {
      _debounce?.cancel();
      // A disposed Ref cannot read providers. All dependencies and the latest
      // snapshot are captured while alive, including a previously failed save.
      if (_dirty) _writeLatest(notify: false);
    });
    return _latest;
  }

  DateTime get _now => ref.read(clockProvider)();

  void _set(StudyState next, {bool debounce = false}) {
    _latest = next;
    _dirty = true;
    state = next;
    if (debounce) {
      if (ref.read(studySaveStatusProvider) != StudySaveStatus.failed) {
        _saveStatus(StudySaveStatus.pending);
      }
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), flush);
    } else {
      flush();
    }
  }

  void flushPending() {
    if (_dirty) flush();
  }

  void _saveStatus(StudySaveStatus status) =>
      ref.read(studySaveStatusProvider.notifier).update(status);

  void _writeLatest({required bool notify}) {
    try {
      _store?.saveSync(_latest.toJson());
      _dirty = false;
      if (notify) _saveStatus(StudySaveStatus.saved);
    } catch (_) {
      // Keep the in-memory changes and dirty snapshot available for retry;
      // ordinary edits must not throw through UI callbacks or timer callbacks.
      _dirty = true;
      if (notify) _saveStatus(StudySaveStatus.failed);
    }
  }

  /// Writes the current state to disk (synchronously; the document is small).
  Future<void> flush({bool deferStatus = false}) {
    _debounce?.cancel();
    if (_dirty) {
      _writeLatest(notify: !deferStatus);
      if (deferStatus) {
        // Reader disposal can run while the widget tree is locked. Persist
        // immediately, then publish feedback after that lifecycle completes.
        scheduleMicrotask(() {
          if (ref.mounted) {
            _saveStatus(
              _dirty ? StudySaveStatus.failed : StudySaveStatus.saved,
            );
          }
        });
      }
    }
    return Future.value();
  }

  void restoreBackup(StudyState restored) {
    final next = restored.copyWith(
      reminderEnabled: state.reminderEnabled,
      welcomed: true,
    );
    // Commit to storage before replacing the live state. A failed write must
    // not leave the screen claiming that imported progress was restored.
    _store?.saveSync(next.toJson());
    _debounce?.cancel();
    _latest = next;
    _dirty = false;
    state = next;
    _saveStatus(StudySaveStatus.saved);
  }

  void toggleFavoriteRule(String id) {
    if (ref.read(contentProvider).rule(id) == null) return;
    final favorites = {...state.favoriteRules};
    if (!favorites.add(id)) favorites.remove(id);
    _set(state.copyWith(favoriteRules: favorites));
  }

  Note addLessonNote(String topicId, int block, String text) {
    final lang = state.language;
    final lesson = ref.read(contentProvider).lesson(topicId, lang.code);
    if (lesson == null ||
        block < 0 ||
        block >= lesson.blocks.length ||
        text.trim().isEmpty) {
      throw ArgumentError('Invalid lesson note');
    }
    final section = lesson.blocks[block];
    final note = Note(
      id: 'n${_now.microsecondsSinceEpoch}',
      edition: lang.editionId,
      page: section.page,
      topicId: topicId,
      text: text.trim(),
      createdAt: _now,
      updatedAt: _now,
      lessonBlock: block,
      sectionTitle: section.plain,
    );
    _set(state.copyWith(notes: [note, ...state.notes]));
    return note;
  }

  void saveSession(SavedSession? session) => _set(
    state.copyWith(savedSession: session, clearSavedSession: session == null),
  );

  void rememberSearch(String query) {
    final text = query.trim();
    if (text.length < 2 || text.length > 120) return;
    final lang = state.language.code;
    final previous = state.recentSearches[lang] ?? const <String>[];
    _set(
      state.copyWith(
        recentSearches: {
          ...state.recentSearches,
          lang: [text, ...previous.where((q) => q != text)].take(8).toList(),
        },
      ),
    );
  }

  void clearRecentSearches() => _set(
    state.copyWith(
      recentSearches: {...state.recentSearches, state.language.code: const []},
    ),
  );

  void setWeeklyGoal(int days) =>
      _set(state.copyWith(weeklyGoal: days.clamp(1, 7)));

  void setLanguage(AppLanguage language) =>
      _set(state.copyWith(language: language));
  void setReaderTheme(ReaderTheme theme) =>
      _set(state.copyWith(readerTheme: theme));
  void setDimNightPages(bool dim) => _set(state.copyWith(dimNightPages: dim));
  void setStreakEnabled(bool enabled) =>
      _set(state.copyWith(streakEnabled: enabled));
  void setHapticsEnabled(bool enabled) =>
      _set(state.copyWith(hapticsEnabled: enabled));
  void setReminder({bool? enabled, int? minutes}) =>
      _set(state.copyWith(reminderEnabled: enabled, reminderMinutes: minutes));

  void setLearningIntent(LearningIntent intent) =>
      _set(state.copyWith(learningIntent: intent));

  void setWelcomed() => _set(state.copyWith(welcomed: true));

  void setAppTheme(AppThemeChoice theme) =>
      _set(state.copyWith(appTheme: theme));

  void setLessonTextScale(double scale) => _set(
    state.copyWith(
      lessonTextScale: scale.clamp(lessonTextScaleMin, lessonTextScaleMax),
    ),
    debounce: true,
  );

  /// Records the visible page. Marks the page's topic as read the first time
  /// it is opened (never downgrades "completed").
  void recordPosition(String edition, int page) {
    final content = ref.read(contentProvider);
    final topics = content.topicsAtPage(edition, page);
    final topicId = topics.isEmpty ? null : topics.first.id;
    final progress = Map<String, TopicProgress>.from(state.topicProgress);
    for (final t in topics) {
      if ((progress[t.id] ?? TopicProgress.none) == TopicProgress.none) {
        progress[t.id] = TopicProgress.read;
      }
    }
    _set(
      state.copyWith(
        positions: {...state.positions, edition: page},
        lastRead: LastRead(
          edition: edition,
          page: page,
          topicId: topicId,
          at: _now,
        ),
        topicProgress: progress,
        studyDays: {...state.studyDays, StudyState.dayKey(_now)},
      ),
      debounce: true,
    );
  }

  /// Opening a topic's native lesson counts as reading it.
  void recordLessonOpened(String topicId) {
    final progress = Map<String, TopicProgress>.from(state.topicProgress);
    if ((progress[topicId] ?? TopicProgress.none) == TopicProgress.none) {
      progress[topicId] = TopicProgress.read;
    }
    // "Continue" on Home returns to this lesson.
    final edition = state.language.editionId;
    final start = ref
        .read(contentProvider)
        .topicOrNull(topicId)
        ?.pagesIn(edition)
        ?.start;
    _set(
      state.copyWith(
        lastRead: start == null
            ? null
            : LastRead(
                edition: edition,
                page: start,
                topicId: topicId,
                at: _now,
              ),
        topicProgress: progress,
        studyDays: {...state.studyDays, StudyState.dayKey(_now)},
      ),
    );
  }

  void recordLessonSection(String key, int block) {
    if (state.lessonPositions[key] == block) return;
    _set(
      state.copyWith(lessonPositions: {...state.lessonPositions, key: block}),
      debounce: true,
    );
  }

  void setTopicCompleted(String topicId, bool completed) {
    final progress = Map<String, TopicProgress>.from(state.topicProgress);
    progress[topicId] = completed
        ? TopicProgress.completed
        : TopicProgress.read;
    _set(
      state.copyWith(
        topicProgress: progress,
        learningDays: completed
            ? {...state.learningDays, StudyState.dayKey(_now)}
            : state.learningDays,
      ),
    );
  }

  void toggleBookmark(String edition, int page) {
    if (state.isBookmarked(edition, page)) {
      _set(
        state.copyWith(
          bookmarks: [
            for (final b in state.bookmarks)
              if (!(b.edition == edition && b.page == page)) b,
          ],
        ),
      );
    } else {
      final b = Bookmark(
        id: 'b${_now.microsecondsSinceEpoch}',
        edition: edition,
        page: page,
        createdAt: _now,
      );
      _set(state.copyWith(bookmarks: [b, ...state.bookmarks]));
    }
  }

  void removeBookmark(String id) => _set(
    state.copyWith(
      bookmarks: [
        for (final b in state.bookmarks)
          if (b.id != id) b,
      ],
    ),
  );

  void restoreBookmark(Bookmark bookmark, {int? index}) {
    if (state.bookmarks.any((b) => b.id == bookmark.id) ||
        state.isBookmarked(bookmark.edition, bookmark.page)) {
      return;
    }
    final bookmarks = [...state.bookmarks];
    bookmarks.insert((index ?? 0).clamp(0, bookmarks.length), bookmark);
    _set(state.copyWith(bookmarks: bookmarks));
  }

  Note addNote(String edition, int page, String text) {
    final topics = ref.read(contentProvider).topicsAtPage(edition, page);
    final note = Note(
      id: 'n${_now.microsecondsSinceEpoch}',
      edition: edition,
      page: page,
      topicId: topics.isEmpty ? null : topics.first.id,
      text: text,
      createdAt: _now,
      updatedAt: _now,
    );
    _set(state.copyWith(notes: [note, ...state.notes]));
    return note;
  }

  void updateNote(String id, String text) => _set(
    state.copyWith(
      notes: [
        for (final n in state.notes)
          n.id == id ? n.copyWith(text: text, updatedAt: _now) : n,
      ],
    ),
  );

  void deleteNote(String id) => _set(
    state.copyWith(
      notes: [
        for (final n in state.notes)
          if (n.id != id) n,
      ],
    ),
  );

  void restoreNote(Note note, {int? index}) {
    if (state.notes.any((n) => n.id == note.id)) return;
    final notes = [...state.notes];
    notes.insert((index ?? 0).clamp(0, notes.length), note);
    _set(state.copyWith(notes: notes));
  }

  void recordAnswer(
    String questionId,
    bool correct, {
    SavedSession? checkpoint,
    bool finishSession = false,
  }) {
    final prev = state.quiz[questionId];
    final now = _now;
    final stage = correct
        ? prev != null && !prev.isDue(now)
              ? prev.reviewStage
              : ((prev?.reviewStage ?? 0) + 1).clamp(1, 4)
        : 0;
    final days = const [1, 1, 3, 7, 14][stage];
    final rec = QuizRecord(
      attempts: (prev?.attempts ?? 0) + 1,
      correct: (prev?.correct ?? 0) + (correct ? 1 : 0),
      lastCorrect: correct,
      lastAt: now,
      reviewStage: stage,
      nextReviewAt: correct && prev != null && !prev.isDue(now)
          ? prev.nextReviewAt
          : now.add(Duration(days: days)),
    );
    _set(
      state.copyWith(
        quiz: {...state.quiz, questionId: rec},
        savedSession: checkpoint,
        clearSavedSession: finishSession,
        learningDays: {...state.learningDays, StudyState.dayKey(now)},
        studyDays: {...state.studyDays, StudyState.dayKey(_now)},
      ),
    );
  }

  void resetPractice() =>
      _set(state.copyWith(quiz: const {}, clearSavedSession: true));
}

/// Per-topic quiz performance, derived from the latest answer to each question.
class TopicPerformance {
  const TopicPerformance(this.answered, this.correctLatest, this.total);
  final int answered;
  final int correctLatest;
  final int total;
}

final topicPerformanceProvider = Provider.family<TopicPerformance, String>((
  ref,
  topicId,
) {
  final content = ref.watch(contentProvider);
  final quiz = ref.watch(studyProvider.select((s) => s.quiz));
  final qs = content.questionsForTopic(topicId);
  var answered = 0, correct = 0;
  for (final q in qs) {
    final r = quiz[q.id];
    if (r == null) continue;
    answered++;
    if (r.lastCorrect) correct++;
  }
  return TopicPerformance(answered, correct, qs.length);
});

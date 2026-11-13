import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_repository.dart';
import '../../content/language.dart';
import '../../core/json_store.dart';

enum ReaderTheme { light, sepia, night }

/// Reading progress is separate from quiz performance.
enum TopicProgress { none, read, completed }

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
  });
  final String id;
  final String edition;
  final int page;
  final String? topicId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({String? text, DateTime? updatedAt}) => Note(
    id: id,
    edition: edition,
    page: page,
    topicId: topicId,
    text: text ?? this.text,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'edition': edition,
    'page': page,
    'topicId': topicId,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  static Note fromJson(Map<String, dynamic> j) => Note(
    id: j['id'] as String,
    edition: j['edition'] as String,
    page: (j['page'] as num).toInt(),
    topicId: j['topicId'] as String?,
    text: j['text'] as String? ?? '',
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
  });
  final int attempts;
  final int correct;
  final bool lastCorrect;
  final DateTime lastAt;

  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'correct': correct,
    'lastCorrect': lastCorrect,
    'lastAt': lastAt.toIso8601String(),
  };
  static QuizRecord fromJson(Map<String, dynamic> j) => QuizRecord(
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
    this.lastRead,
    this.bookmarks = const [],
    this.notes = const [],
    this.topicProgress = const {},
    this.quiz = const {},
    this.streakEnabled = false,
    this.studyDays = const {},
    this.hapticsEnabled = true,
    this.reminderEnabled = false,
    this.reminderMinutes = 20 * 60,
  });

  /// Arabic on first launch, regardless of device language.
  final AppLanguage language;
  final ReaderTheme readerTheme;

  /// Night theme only: uniformly dims page images (hue-preserving).
  final bool dimNightPages;

  /// Remembered reading position per edition.
  final Map<String, int> positions;
  final LastRead? lastRead;
  final List<Bookmark> bookmarks;
  final List<Note> notes;
  final Map<String, TopicProgress> topicProgress;
  final Map<String, QuizRecord> quiz;
  final bool streakEnabled;

  /// Days (yyyy-mm-dd, local) on which the learner read or practised.
  final Set<String> studyDays;

  /// Light touch feedback on taps that change something.
  final bool hapticsEnabled;

  /// Daily study reminder (local notification), off until the learner asks.
  final bool reminderEnabled;

  /// Time of the reminder, in minutes after local midnight.
  final int reminderMinutes;

  StudyState copyWith({
    AppLanguage? language,
    ReaderTheme? readerTheme,
    bool? dimNightPages,
    Map<String, int>? positions,
    LastRead? lastRead,
    List<Bookmark>? bookmarks,
    List<Note>? notes,
    Map<String, TopicProgress>? topicProgress,
    Map<String, QuizRecord>? quiz,
    bool? streakEnabled,
    Set<String>? studyDays,
    bool? hapticsEnabled,
    bool? reminderEnabled,
    int? reminderMinutes,
  }) => StudyState(
    language: language ?? this.language,
    readerTheme: readerTheme ?? this.readerTheme,
    dimNightPages: dimNightPages ?? this.dimNightPages,
    positions: positions ?? this.positions,
    lastRead: lastRead ?? this.lastRead,
    bookmarks: bookmarks ?? this.bookmarks,
    notes: notes ?? this.notes,
    topicProgress: topicProgress ?? this.topicProgress,
    quiz: quiz ?? this.quiz,
    streakEnabled: streakEnabled ?? this.streakEnabled,
    studyDays: studyDays ?? this.studyDays,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
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
    var day = DateTime(now.year, now.month, now.day);
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
    'lastRead': lastRead?.toJson(),
    'bookmarks': [for (final b in bookmarks) b.toJson()],
    'notes': [for (final n in notes) n.toJson()],
    'topicStatus': {
      for (final e in topicProgress.entries) e.key: {'status': e.value.name},
    },
    'quiz': {for (final e in quiz.entries) e.key: e.value.toJson()},
    'streak': {'enabled': streakEnabled, 'days': (studyDays.toList()..sort())},
    'haptics': hapticsEnabled,
    'reminder': {'enabled': reminderEnabled, 'minutes': reminderMinutes},
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
      language: AppLanguage.fromCode(j['language'] as String?),
      readerTheme: ReaderTheme.values.firstWhere(
        (t) => t.name == j['readerTheme'],
        orElse: () => ReaderTheme.light,
      ),
      dimNightPages: j['dimNightPages'] as bool? ?? false,
      positions: positions,
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
      streakEnabled: streak['enabled'] as bool? ?? false,
      studyDays: {
        for (final d in (streak['days'] as List?) ?? const []) d as String,
      },
      hapticsEnabled: j['haptics'] as bool? ?? true,
      reminderEnabled: reminder['enabled'] as bool? ?? false,
      reminderMinutes: minutes.clamp(0, 24 * 60 - 1),
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

class StudyController extends Notifier<StudyState> {
  Timer? _debounce;

  @override
  StudyState build() {
    ref.onDispose(() {
      // Never lose a pending (debounced) position on shutdown.
      if (_debounce?.isActive ?? false) flush();
      _debounce?.cancel();
    });
    return ref.read(initialStudyStateProvider);
  }

  DateTime get _now => ref.read(clockProvider)();

  void _set(StudyState next, {bool debounce = false}) {
    state = next;
    if (debounce) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), flush);
    } else {
      flush();
    }
  }

  /// Writes the current state to disk (synchronously; the document is small).
  Future<void> flush() {
    _debounce?.cancel();
    ref.read(storeProvider)?.saveSync(state.toJson());
    return Future.value();
  }

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
          topicId: topicId ?? state.lastRead?.topicId,
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

  void setTopicCompleted(String topicId, bool completed) {
    final progress = Map<String, TopicProgress>.from(state.topicProgress);
    progress[topicId] = completed
        ? TopicProgress.completed
        : TopicProgress.read;
    _set(state.copyWith(topicProgress: progress));
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

  void recordAnswer(String questionId, bool correct) {
    final prev = state.quiz[questionId];
    final rec = QuizRecord(
      attempts: (prev?.attempts ?? 0) + 1,
      correct: (prev?.correct ?? 0) + (correct ? 1 : 0),
      lastCorrect: correct,
      lastAt: _now,
    );
    _set(
      state.copyWith(
        quiz: {...state.quiz, questionId: rec},
        studyDays: {...state.studyDays, StudyState.dayKey(_now)},
      ),
    );
  }

  void resetPractice() => _set(state.copyWith(quiz: const {}));
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

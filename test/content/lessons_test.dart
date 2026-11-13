import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/models.dart';
import 'package:rattil/features/search/search_engine.dart';

import '../helpers.dart';

bool _isMark(int r) =>
    (r >= 0x0610 && r <= 0x061A) ||
    (r >= 0x064B && r <= 0x065F) ||
    r == 0x0670 ||
    (r >= 0x06D6 && r <= 0x06ED);

Iterable<LessonSpan> _allSpans(Lesson l) sync* {
  for (final b in l.blocks) {
    yield* b.term;
    yield* b.spans;
    for (final r in b.rows) {
      for (final c in r) {
        yield* c;
      }
    }
  }
}

void main() {
  final c = loadContent();
  const langs = ['ar', 'ckb', 'en', 'id'];

  test('every lesson block lies inside its topic\'s page range', () {
    for (final lang in langs) {
      for (final l in (c.lessons[lang] ?? const <String, Lesson>{}).values) {
        final range = c.topic(l.topicId).pagesIn(lang)!;
        for (final b in l.blocks) {
          expect(
            range.contains(b.page),
            isTrue,
            reason: '${l.topicId}/$lang page ${b.page}',
          );
        }
      }
    }
  });

  test(
    'lesson Qur\'anic excerpts are verified Tanzil text with whole-letter highlights',
    () {
      var n = 0;
      for (final lang in langs) {
        for (final l in (c.lessons[lang] ?? const <String, Lesson>{}).values) {
          for (final s in _allSpans(l)) {
            final q = s.quran;
            if (q == null) continue;
            n++;
            final verse = c.quranVerses['${q.surah}:${q.ayah}'];
            expect(verse, isNotNull, reason: q.text);
            expect(
              verse!.contains(q.text),
              isTrue,
              reason: 'excerpt is verbatim: ${q.text}',
            );
            for (final (a, b) in q.highlights) {
              expect(_isMark(q.text.codeUnitAt(a)), isFalse);
              if (b < q.text.length) {
                expect(_isMark(q.text.codeUnitAt(b)), isFalse);
              }
            }
          }
        }
      }
      expect(n, greaterThan(400));
    },
  );

  test('no raw markup leaks into lesson text', () {
    for (final lang in langs) {
      for (final l in (c.lessons[lang] ?? const <String, Lesson>{}).values) {
        for (final s in _allSpans(l)) {
          expect(
            s.plain.contains('{{') ||
                s.plain.contains('}}') ||
                s.plain.contains('**'),
            isFalse,
            reason: '${l.topicId}/$lang: ${s.plain}',
          );
        }
      }
    }
  });

  test('every topic has a native lesson in every edition that covers it', () {
    for (final t in c.topics) {
      for (final lang in langs) {
        final covered = t.pagesIn(lang) != null;
        expect(c.lesson(t.id, lang) != null, covered, reason: '${t.id}/$lang');
      }
    }
  });

  test(
    'topic 10 has a lesson in all four languages; release channel hides drafts',
    () {
      for (final lang in langs) {
        expect(c.lesson('t10', lang), isNotNull, reason: lang);
      }
      final release = loadContent(channel: ContentChannel.release);
      expect(release.lesson('t10', 'ar'), isNull);
      expect(release.hasLessons('ar'), isFalse);
    },
  );

  group('lesson full-text search', () {
    final engine = SearchEngine(c);
    test('Arabic, with or without diacritics', () {
      for (final q in [
        'الإخفاء الحقيقي',
        'الاخفاء الحقيقي',
        'الإِخْفَاءُ الحَقِيقِيُّ',
      ]) {
        final hits = engine.searchLessons(q, 'ar');
        expect(hits, isNotEmpty, reason: q);
        expect(hits.first.topicId, 't10');
        expect(hits.first.page, inInclusiveRange(41, 47));
      }
    });
    test('Kurdish exact and Arabic-keyboard spellings', () {
      expect(
        engine.searchLessons('ئیخفائی حەقیقی', 'ckb').first.topicId,
        't10',
      );
      final folded = engine.searchLessons(
        'ئیخفائی حەقیقي',
        'ckb',
      ); // Arabic yeh
      expect(folded, isNotEmpty);
    });
    test('English and Indonesian', () {
      expect(engine.searchLessons('real hiding', 'en').first.page, 48);
      expect(engine.searchLessons('ikhfa haqiqy', 'id').first.page, 49);
    });
    test('irrelevant and too-short queries return nothing', () {
      for (final lang in langs) {
        expect(engine.searchLessons('bluetooth', lang), isEmpty);
        expect(engine.searchLessons('ال', lang), isEmpty);
      }
    });
  });
}

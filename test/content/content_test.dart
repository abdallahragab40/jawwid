import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/models.dart';

import '../helpers.dart';

const editions = ['ar', 'ckb', 'en', 'id'];

bool _isMark(int r) =>
    (r >= 0x0610 && r <= 0x061A) ||
    (r >= 0x064B && r <= 0x065F) ||
    r == 0x0670 ||
    (r >= 0x06D6 && r <= 0x06ED);

void main() {
  final c = loadContent();

  group('editions', () {
    test('page counts match the source PDFs', () {
      expect(
        {for (final e in editions) e: c.editions[e]!.pageCount},
        {'ar': 102, 'ckb': 112, 'en': 109, 'id': 112},
      );
    });

    test('printed page numbers vs physical PDF indices', () {
      final ar = c.editions['ar']!;
      expect(
        ar.printedNumberOf(1),
        isNull,
        reason: 'front cover is unnumbered',
      );
      expect(ar.printedNumberOf(2), isNull, reason: 'blank page is unnumbered');
      expect(ar.printedNumberOf(3), 3);
      expect(ar.printedNumberOf(42), 42);
      expect(ar.printedNumberOf(99), 99);
      expect(ar.printedNumberOf(100), isNull);
      expect(ar.printedNumberOf(102), isNull, reason: 'back cover');
      expect(ar.printedNumberOf(0), isNull);
      expect(ar.printedNumberOf(103), isNull);
      expect(ar.physicalForPrinted(42), 42);
      // Book anomalies: AR physical 36 visibly prints ٤٠; CKB 42 prints none.
      expect(ar.printedNumberOf(36), 40);
      expect(ar.physicalForPrinted(40), 40);
      expect(ar.physicalForPrinted(36), 36);
      expect(c.editions['ckb']!.printedNumberOf(42), isNull);
      expect(ar.physicalForPrinted(2), isNull);
      expect(ar.physicalForPrinted(100), isNull);
      expect(c.editions['ckb']!.physicalForPrinted(110), 110);
      expect(c.editions['en']!.physicalForPrinted(108), isNull);
      expect(c.editions['id']!.printedNumberOf(110), 110);
      for (final e in editions) {
        final ed = c.editions[e]!;
        for (var p = 1; p <= ed.pageCount; p++) {
          final printed = ed.printedNumberOf(p);
          if (printed != null && !ed.numbering.overrides.containsKey(p)) {
            expect(ed.physicalForPrinted(printed), p);
          }
        }
      }
    });
  });

  group('curriculum', () {
    test('30 topics in source order, grouped contiguously in 8 groups', () {
      expect(c.topics.length, 30);
      expect([
        for (final t in c.topics) t.order,
      ], List.generate(30, (i) => i + 1));
      expect(c.groups.length, 8);
      final flattened = [for (final g in c.groups) ...g.topicIds];
      expect(flattened, [for (final t in c.topics) t.id]);
    });

    test('every topic has a title in all four languages', () {
      for (final t in c.topics) {
        for (final l in editions) {
          expect(t.title[l]?.text.trim(), isNotEmpty, reason: '${t.id} $l');
        }
      }
    });

    test('page ranges lie inside each edition and follow source order', () {
      for (final e in editions) {
        final ed = c.editions[e]!;
        var lastStart = 0;
        for (final t in c.topics) {
          final r = t.pagesIn(e);
          if (r == null) continue;
          expect(
            r.start,
            inInclusiveRange(
              ed.numbering.firstNumbered,
              ed.numbering.lastNumbered,
            ),
            reason: '${t.id} $e',
          );
          expect(r.end, greaterThanOrEqualTo(r.start));
          expect(
            r.end,
            lessThan(ed.referencesPage),
            reason: '${t.id} $e ends before the references',
          );
          // t22 (Sakt) in the English edition is covered inside the Waqf section.
          if (!(e == 'en' && t.id == 't22')) {
            expect(
              r.start,
              greaterThanOrEqualTo(lastStart),
              reason: 'order ${t.id} $e',
            );
            lastStart = r.start;
          }
        }
      }
    });

    test('verified start pages (spot checks against the page images)', () {
      int s(String t, String e) => c.topic(t).pagesIn(e)!.start;
      expect(
        [s('t01', 'ar'), s('t01', 'ckb'), s('t01', 'en'), s('t01', 'id')],
        [5, 5, 4, 5],
      );
      expect(
        [s('t10', 'ar'), s('t10', 'ckb'), s('t10', 'en'), s('t10', 'id')],
        [41, 47, 41, 42],
      );
      expect(
        [s('t15', 'ar'), s('t15', 'ckb'), s('t15', 'en'), s('t15', 'id')],
        [58, 67, 60, 63],
      );
      expect(
        [s('t20', 'ar'), s('t20', 'ckb'), s('t20', 'en'), s('t20', 'id')],
        [79, 89, 86, 88],
      );
      expect(
        [s('t30', 'ar'), s('t30', 'ckb'), s('t30', 'en'), s('t30', 'id')],
        [98, 109, 106, 109],
      );
    });

    test(
      'documented gaps: Alqab absent from EN and ID; partial coverage notes',
      () {
        final absent = [
          for (final t in c.topics)
            for (final e in editions)
              if (!t.isAvailableIn(e)) '${t.id}:$e',
        ];
        expect(absent, ['t07:en', 't07:id']);
        expect(c.topic('t22').isPartialIn('en'), isTrue);
        expect(c.topic('t14').isPartialIn('en'), isTrue);
        for (final t in c.topics) {
          for (final note in t.partialNotes.values) {
            for (final l in editions) {
              expect(note[l], isNotNull, reason: '${t.id} partial note $l');
            }
          }
        }
      },
    );

    test('topicsAtPage finds the topic and shared pages', () {
      expect(c.topicsAtPage('ar', 46).map((t) => t.id), ['t10']);
      expect(c.topicsAtPage('ar', 98).map((t) => t.id), ['t29', 't30']);
      expect(c.topicsAtPage('ar', 3), isEmpty, reason: 'introduction');
    });

    test(
      'equivalent page across editions keeps the offset inside the topic',
      () {
        // AR p.46 is the 6th page of t10 (41–47) -> CKB t10 is 47–55 -> 52.
        expect(
          c.equivalentPage(
            topicId: 't10',
            fromEdition: 'ar',
            fromPage: 46,
            toEdition: 'ckb',
          ),
          52,
        );
        // Clamped when the target topic is shorter.
        expect(
          c.equivalentPage(
            topicId: 't04',
            fromEdition: 'ckb',
            fromPage: 13,
            toEdition: 'ar',
          ),
          10,
        );
        // Absent topic -> null (never a silent jump).
        expect(
          c.equivalentPage(
            topicId: 't07',
            fromEdition: 'ar',
            fromPage: 24,
            toEdition: 'en',
          ),
          isNull,
        );
      },
    );
  });

  group('rules, examples and questions', () {
    test(
      '22 rule cards, each linked to an existing topic, with definitions',
      () {
        expect(c.rules.length, 22);
        for (final r in c.rules) {
          expect(c.topicOrNull(r.topicId), isNotNull);
          for (final l in editions) {
            expect(r.title[l], isNotNull, reason: '${r.id} title $l');
            expect(r.definition[l], isNotNull, reason: '${r.id} definition $l');
            expect(
              r.explanation[l],
              isNotNull,
              reason: '${r.id} explanation $l',
            );
            final d = r.definition[l]!;
            if (d.status != TextStatus.authored) {
              expect(d.page, isNotNull, reason: '${r.id} $l source page');
              expect(
                c.topic(r.topicId).pagesIn(l)!.contains(d.page!),
                isTrue,
                reason: '${r.id} $l page ${d.page} inside its topic',
              );
            }
          }
        }
      },
    );

    test('highlights cover whole letters with their marks', () {
      final excerpts = [
        for (final r in c.rules) r.example,
        for (final q in c.questions) ?q.example,
      ];
      // 22 rule cards, 21 hand-written identify questions, 17 concept
      // questions with an example, and 151 drafted identify questions.
      expect(excerpts.length, 22 + 21 + 17 + 151);
      for (final e in excerpts) {
        expect(e.highlights, isNotEmpty);
        for (final (s, end) in e.highlights) {
          expect(s, inInclusiveRange(0, e.text.length - 1));
          expect(end, inInclusiveRange(s + 1, e.text.length));
          expect(
            _isMark(e.text.codeUnitAt(s)),
            isFalse,
            reason: 'starts on a mark: ${e.text}',
          );
          if (end < e.text.length) {
            expect(
              _isMark(e.text.codeUnitAt(end)),
              isFalse,
              reason: 'splits a mark: ${e.text}',
            );
          }
        }
      }
    });

    test('surah names exist for every reference', () {
      for (final r in c.rules) {
        expect(c.surahNames[r.example.surah], isNotNull);
      }
    });

    test('every topic has practice, and text options exist in all '
        'four languages', () {
      for (final t in c.topics) {
        expect(
          c.questionsForTopic(t.id).length,
          greaterThanOrEqualTo(2),
          reason: t.id,
        );
      }
      for (final q in c.questions) {
        for (final o in q.choices) {
          if (o.text == null) continue;
          for (final l in const ['ar', 'ckb', 'en', 'id']) {
            expect(o.text![l], isNotEmpty, reason: '${q.id} $l');
          }
        }
      }
    });

    test('questions reference existing rules and have valid answers', () {
      // 99 hand-written, 151 drafted identify, 27 drafted articulation,
      // 15 drafted sort.
      expect(c.questions.length, 99 + 151 + 27 + 15);
      expect({for (final q in c.questions) q.id}.length, c.questions.length);
      for (final q in c.questions) {
        switch (q.type) {
          case QuestionType.identify:
            expect(q.ruleOptions, contains(q.answerRuleId));
            for (final id in q.ruleOptions) {
              expect(c.rule(id), isNotNull, reason: q.id);
            }
          case QuestionType.choice:
            expect(q.answerIndex, inInclusiveRange(0, q.choices.length - 1));
            expect(q.prompt, isNotNull);
          case QuestionType.trueFalse:
            expect(q.answerBool, isNotNull);
          case QuestionType.sort:
            expect(q.groups.length, greaterThanOrEqualTo(2), reason: q.id);
            expect(q.prompt, isNotNull);
            final letters = [for (final i in q.items) i.arabic];
            expect(letters.toSet().length, letters.length, reason: q.id);
            for (var g = 0; g < q.groups.length; g++) {
              expect(q.items.where((i) => i.group == g), isNotEmpty);
              for (final l in editions) {
                expect(q.groups[g][l], isNotEmpty, reason: '${q.id} $l');
              }
            }
        }
        for (final l in editions) {
          expect(q.explanation[l], isNotNull, reason: '${q.id} $l');
        }
      }
    });

    test('release channel hides unreviewed supplementary material', () {
      final release = loadContent(channel: ContentChannel.release);
      expect(release.rules, isEmpty, reason: 'no card has been reviewed yet');
      expect(release.questions, isEmpty);
      expect(release.totalRuleCount, 22);
      expect(
        release.topics.length,
        30,
        reason: 'the books and curriculum are always available',
      );
    });
  });

  group('makharij', () {
    test('5 areas and 17 points with descriptions in four languages', () {
      final m = c.makharij;
      expect(m.areas.length, 5);
      expect(m.points.length, 17);
      expect(
        [for (final a in m.areas) ...a.pointIds],
        [for (final p in m.points) p.id],
      );
      for (final p in m.points) {
        for (final l in editions) {
          expect(p.text[l]?.text, isNotEmpty, reason: '${p.id} $l');
          expect(p.pages[l], isNotNull);
        }
        for (final id in p.landmarkIds) {
          expect(m.landmark(id), isNotNull);
        }
        expect(p.unmarked, p.landmarkIds.isEmpty);
      }
      for (final l in m.landmarks) {
        expect(l.x, inInclusiveRange(0, 1));
        expect(l.y, inInclusiveRange(0, 1));
      }
    });
  });

  test('blank pages are known per edition, outside every topic, and a jump '
      'to one lands on the nearest page with content', () {
    final c = loadContent();
    const expected = {
      'ar': {2, 100, 101},
      'ckb': {2, 111},
      'en': {2, 108},
      'id': {2, 111},
    };
    for (final e in c.editions.values) {
      expect(e.blankPages, expected[e.id], reason: e.id);
      for (final b in e.blankPages) {
        expect(e.printedNumberOf(b), isNull, reason: '${e.id} p$b');
        for (final t in c.topics) {
          final r = t.pagesIn(e.id);
          if (r != null) expect(r.contains(b), isFalse, reason: t.id);
        }
      }
      expect(e.nearestContentPage(2), 3, reason: 'after the cover');
      expect(e.nearestContentPage(1), 1, reason: 'the cover itself');
    }
    // Before the back cover, a blank run moves forward to the back cover.
    expect(c.editions['ar']!.nearestContentPage(100), 102);
    expect(c.editions['en']!.nearestContentPage(108), 109);
  });
}

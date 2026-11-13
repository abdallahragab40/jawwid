import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/features/search/search_engine.dart';

import '../helpers.dart';

void main() {
  final content = loadContent();
  final engine = SearchEngine(content);

  List<String> topicIds(String q) => [
    for (final h in engine.searchTerms(q))
      if (h.kind == SearchHitKind.topic) h.topicId!,
  ];
  List<String> ruleIds(String q) => [
    for (final h in engine.searchTerms(q))
      if (h.kind == SearchHitKind.rule) h.ruleId!,
  ];

  group('Arabic', () {
    test('الإخفاء finds the noon-sakinah lesson and the ikhfaa rule cards', () {
      expect(topicIds('الإخفاء').first, 't10');
      expect(ruleIds('الإخفاء'), containsAll(['r05', 'r07']));
    });
    test('with and without diacritics or hamza give the same top result', () {
      for (final q in ['الإِخْفَاءُ', 'الاخفاء', 'اخفاء', 'إخفاء']) {
        expect(topicIds(q).first, 't10', reason: q);
        expect(ruleIds(q).first, 'r05', reason: q);
      }
    });
    test('القلقلة finds the characteristics lesson and the qalqalah card', () {
      for (final q in ['القلقلة', 'القَلْقَلَة', 'قلقلة']) {
        expect(topicIds(q).first, 't08', reason: q);
        expect(ruleIds(q), contains('r10'), reason: q);
      }
    });
    test('multi-word query', () {
      expect(topicIds('النون الساكنة').first, 't10');
      expect(ruleIds('الإدغام بلا غنة').first, 'r03');
    });
  });

  group('Kurdish', () {
    test('exact Kurdish spelling finds the topic', () {
      expect(topicIds('قەڵەوکردن').first, 't14');
      expect(topicIds('شاردنەوە').first, 't10');
      expect(ruleIds('شاردنەوەی لێوی').first, 'r07');
      expect(topicIds('سەکت').first, 't22');
    });
    test('Arabic code points for kaf/yeh match Kurdish text', () {
      // ك (U+0643) and ي (U+064A) typed on an Arabic keyboard.
      expect(topicIds('ئەحكامەكانی نونی ساكن').first, 't10');
    });
    test(
      'Arabic-keyboard look-alikes match only as lower-ranked folded hits',
      () {
        final strict = engine.searchTerms('قەڵەوکردن').first;
        final folded = engine.searchTerms('قەلەوکردن').first; // ل instead of ڵ
        expect(folded.topicId, 't14');
        expect(folded.quality, MatchQuality.folded);
        expect(strict.quality, isNot(MatchQuality.folded));
        expect(folded.score, lessThan(strict.score));
      },
    );
  });

  group('English and Indonesian', () {
    test('English terms', () {
      expect(topicIds('ikhfaa').first, 't10');
      expect(ruleIds('Ikhfaa Shafawi').first, 'r07');
      expect(topicIds('qalqalah').first, 't08');
      expect(topicIds("isti'adhah").first, 't04');
      expect(topicIds('istiadhah').first, 't04');
    });
    test('Indonesian terms', () {
      expect(topicIds('ikhfa').first, 't10');
      expect(topicIds('tebal dan tipis').first, 't14');
      expect(ruleIds('mad lin').first, 'r22');
    });
  });

  group('noise and false matches', () {
    test('irrelevant queries return nothing', () {
      for (final q in ['pizza', 'bluetooth', 'كمبيوتر', 'xyz123']) {
        expect(engine.searchTerms(q), isEmpty, reason: q);
        expect(engine.searchPages(q), isEmpty, reason: q);
      }
    });
    test('queries that are too short are ignored', () {
      expect(engine.searchTerms('ا'), isEmpty);
      expect(
        engine.searchTerms('ال'),
        isEmpty,
        reason: 'the article alone must not match everything',
      );
      expect(engine.searchTerms(' '), isEmpty);
    });
    test('a short Latin fragment does not match inside unrelated words', () {
      // "lin" must not match "linguistics" through substring noise in titles.
      expect(ruleIds('lin'), isNot(contains('r01')));
    });
  });

  group('page text (English and Indonesian editions only)', () {
    test('hits open the right pages', () {
      final en = engine.searchPages('ikhfaa', edition: 'en');
      expect(en.map((h) => h.page), containsAll([48, 49]));
      for (final h in en) {
        expect(h.edition, 'en');
        expect(h.page, inInclusiveRange(1, content.editions['en']!.pageCount));
      }
      final id = engine.searchPages('qalqalah', edition: 'id');
      expect(id.map((h) => h.page), contains(34));
      expect(id.firstWhere((h) => h.page == 34).topicId, 't08');
    });
    test(
      'no page index exists for Arabic or Kurdish (coverage is stated in the UI)',
      () {
        expect(content.pageText.keys.toSet(), {'en', 'id'});
        expect(engine.searchPages('الإخفاء'), isEmpty);
      },
    );
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/core/numerals.dart';
import 'package:rattil/core/text_normalize.dart';

import '../helpers.dart';

void main() {
  test('lesson anchors survive storage and old saves default safely', () {
    final state = const StudyState(lessonPositions: {'en:t10:123': 18});
    final restored = StudyState.fromJson(
      jsonDecode(jsonEncode(state.toJson())),
    );
    expect(restored.copyWith(welcomed: true).lessonPositions['en:t10:123'], 18);
    expect(StudyState.fromJson({}).lessonPositions, isEmpty);
    expect(
      StudyState.fromJson({
        'lessonPositions': {'bad': -1, 'text': 'x'},
      }).lessonPositions,
      isEmpty,
    );
  });
  group('numerals', () {
    test(
      'Arabic and Kurdish use Arabic-Indic digits (as printed in both books)',
      () {
        expect(localizeDigits('Page 42', 'ar'), 'Page ٤٢');
        expect(localizeDigits('109', 'ckb'), '١٠٩');
        expect(formatInt(7, 'ar'), '٧');
      },
    );
    test('English and Indonesian keep Western digits', () {
      expect(localizeDigits('42', 'en'), '42');
      expect(localizeDigits('42', 'id'), '42');
    });
    test('asciiDigits reads Arabic-Indic and Persian digits', () {
      expect(asciiDigits('٤٢'), '42');
      expect(asciiDigits('۴۲'), '42');
      expect(int.parse(asciiDigits('١٠٢')), 102);
    });
  });

  group('search normalisation', () {
    test('ignores tashkeel, tatweel and alef-hamza variants', () {
      expect(normalizeStrict('الإِخْفَاءُ'), normalizeStrict('الاخفاء'));
      expect(normalizeStrict('القَلْقَلَة'), normalizeStrict('القلقلة'));
      expect(normalizeStrict('ٱلْعَٰلَمِينَ'), normalizeStrict('العلمين'));
      expect(normalizeStrict('مــد'), normalizeStrict('مد'));
    });
    test('unifies Arabic and Persian code points for kaf and yeh', () {
      expect(normalizeStrict('ك'), normalizeStrict('ک'));
      expect(normalizeStrict('ي'), normalizeStrict('ی'));
      expect(normalizeStrict('ى'), normalizeStrict('ی'));
    });
    test('keeps meaningful Kurdish letters distinct in strict mode', () {
      for (final (a, b) in [
        ('ڕ', 'ر'),
        ('ڵ', 'ل'),
        ('ێ', 'ی'),
        ('ۆ', 'و'),
        ('ە', 'ه'),
      ]) {
        expect(
          normalizeStrict(a),
          isNot(normalizeStrict(b)),
          reason: '$a vs $b',
        );
        expect(normalizeLoose(a), normalizeLoose(b), reason: 'loose $a vs $b');
      }
      // Hamza seat used to begin Kurdish vowels is never dropped.
      expect(normalizeStrict('ئیزهار').startsWith('ئ'), isTrue);
      // Distinct Kurdish consonants are never folded, even loosely.
      for (final (a, b) in [
        ('پ', 'ب'),
        ('چ', 'ج'),
        ('ژ', 'ز'),
        ('گ', 'ک'),
        ('ڤ', 'ف'),
      ]) {
        expect(normalizeLoose(a), isNot(normalizeLoose(b)), reason: '$a vs $b');
      }
    });
    test('folds Latin case, accents and transliteration marks', () {
      expect(normalizeStrict("Isti'adhah"), 'istiadhah');
      expect(normalizeStrict('Ḥafṣ'), 'hafs');
      expect(normalizeStrict('Mad ʿAridh'), 'mad aridh');
    });
    test('definite article is optional for Arabic words', () {
      expect(
        searchTokens(normalizeStrict('الإخفاء')),
        contains(normalizeStrict('اخفاء')),
      );
    });
  });

  group('JsonStore', () {
    test('saves atomically and survives a restart', () async {
      final dir = tempDir();
      final a = JsonStore(dir);
      await a.save({
        'language': 'ckb',
        'positions': {'ckb': 54},
      });
      final b = JsonStore(dir); // a fresh instance, as after an app restart
      final data = await b.load();
      expect(data['language'], 'ckb');
      expect(data['positions'], {'ckb': 54});
      expect(data['schemaVersion'], JsonStore.currentSchemaVersion);
      expect(
        File('${dir.path}/rattil_user_data.json.tmp').existsSync(),
        isFalse,
      );
    });

    test('falls back to the backup if the main file is corrupt', () async {
      final dir = tempDir();
      final s = JsonStore(dir);
      await s.save({'language': 'en'});
      await s.save({'language': 'id'}); // the first save becomes the backup
      File('${dir.path}/rattil_user_data.json').writeAsStringSync('{not json');
      expect((await s.load())['language'], 'en');
    });

    test('migrates schema v1 data without losing it', () {
      final v1 = {
        'schemaVersion': 1,
        'language': 'ar',
        'lastPage': 46,
        'completed': ['t10', 't11'],
        'bookmarks': [
          {
            'id': 'b1',
            'edition': 'ar',
            'page': 46,
            'createdAt': '2026-01-01T00:00:00.000',
          },
        ],
      };
      final out = JsonStore.migrate(
        jsonDecode(jsonEncode(v1)) as Map<String, dynamic>,
      );
      expect(out['schemaVersion'], 2);
      expect(out['positions'], {'ar': 46});
      expect(out['topicStatus'], {
        't10': {'status': 'completed'},
        't11': {'status': 'completed'},
      });
      expect((out['bookmarks'] as List).length, 1);
      expect(out.containsKey('lastPage'), isFalse);
    });

    test('a missing file yields an empty, current-schema document', () async {
      final out = await JsonStore(tempDir()).load();
      expect(out['schemaVersion'], JsonStore.currentSchemaVersion);
    });
  });
}

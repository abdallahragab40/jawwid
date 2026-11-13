/// Conservative text normalisation for the *search index only*.
///
/// Nothing here is ever applied to displayed or stored text.
///
/// Two tiers:
/// * [normalizeStrict] removes differences that carry no meaning for search
///   (tashkeel, tatweel, alef-hamza variants, Arabic vs. Persian kaf/yeh code
///   points, ZWNJ, Latin case and accents). It keeps letters that are distinct
///   in Kurdish — ڕ/ر, ڵ/ل, ێ/ی, ۆ/و, ە/ه, ئ — distinct.
/// * [normalizeLoose] additionally folds those Kurdish letters onto their
///   Arabic-keyboard look-alikes. Matches found only this way rank lower, so a
///   user typing on an Arabic keyboard still finds Kurdish terms, while exact
///   Kurdish spelling always ranks first.
library;

import 'numerals.dart';

bool _isArabicMark(int r) =>
    (r >= 0x0610 && r <= 0x061A) ||
    (r >= 0x064B && r <= 0x065F) ||
    r == 0x0670 ||
    (r >= 0x06D6 && r <= 0x06ED) ||
    (r >= 0x08D3 && r <= 0x08FF);

const Map<int, String> _strictMap = {
  0x0622: 'ا', // آ
  0x0623: 'ا', // أ
  0x0625: 'ا', // إ
  0x0671: 'ا', // ٱ
  0x0672: 'ا',
  0x0673: 'ا',
  0x0643: 'ک', // Arabic kaf -> Kurdish/Persian keheh
  0x064A: 'ی', // Arabic yeh -> Farsi yeh
  0x0649: 'ی', // alef maqsura -> Farsi yeh
  0x0624: 'و', // ؤ
  0x0629: 'ه', // ة (not used in Kurdish)
  0x0640: '', // tatweel
  0x200C: '', // ZWNJ
  0x200D: '', // ZWJ
  0x200F: '', // RLM
  0x200E: '', // LRM
};

const Map<int, String> _looseMap = {
  0x0695: 'ر', // ڕ
  0x06B5: 'ل', // ڵ
  0x06CE: 'ی', // ێ
  0x06C6: 'و', // ۆ
  0x06D5: 'ه', // ە
};

const Map<String, String> _latinFold = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ā': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ē': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ī': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ō': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ū': 'u',
  'ḥ': 'h',
  'ṣ': 's',
  'ḍ': 'd',
  'ṭ': 't',
  'ẓ': 'z',
  'ḏ': 'dh',
  'ṯ': 'th',
};

String _normalize(String input, {required bool loose}) {
  final s = asciiDigits(input).toLowerCase();
  final b = StringBuffer();
  for (final r in s.runes) {
    if (_isArabicMark(r)) continue;
    final strict = _strictMap[r];
    if (strict != null) {
      b.write(strict);
      continue;
    }
    if (loose) {
      final l = _looseMap[r];
      if (l != null) {
        b.write(l);
        continue;
      }
    }
    final ch = String.fromCharCode(r);
    final latin = _latinFold[ch];
    if (latin != null) {
      b.write(latin);
      continue;
    }
    // Apostrophe-like marks used in transliteration are dropped.
    if (ch == "'" ||
        ch == '’' ||
        ch == 'ʿ' ||
        ch == 'ʾ' ||
        ch == '`' ||
        ch == '‘') {
      continue;
    }
    // Punctuation and separators become spaces.
    if ('-_()[]{}«»"،,.;:!?؟/\\|*•…–—'.contains(ch)) {
      b.write(' ');
      continue;
    }
    b.write(ch);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String normalizeStrict(String input) => _normalize(input, loose: false);

String normalizeLoose(String input) => _normalize(input, loose: true);

/// Splits a normalised string into words, also yielding each Arabic word
/// without a leading definite article so "اخفاء" matches "الإخفاء".
List<String> searchTokens(String normalized) {
  final out = <String>[];
  for (final w in normalized.split(' ')) {
    if (w.isEmpty) continue;
    out.add(w);
    if (w.length > 3 && w.startsWith('ال')) out.add(w.substring(2));
  }
  return out;
}

/// Number of letters ignoring spaces; used to reject queries that are too short.
int meaningfulLength(String normalized) =>
    normalized.replaceAll(' ', '').runes.length;

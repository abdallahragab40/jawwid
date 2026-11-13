/// Locale-aware digit rendering.
///
/// Both the Arabic and the Kurdish (Sorani) editions print Arabic-Indic digits
/// (U+0660–U+0669, verified on the page footers), so the interface uses the same
/// forms for `ar` and `ckb`. English and Indonesian use Western digits.
/// The `intl` package has no data for `ckb`, so we do not rely on it here.
library;

const _arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

bool usesArabicIndicDigits(String languageCode) =>
    languageCode == 'ar' || languageCode == 'ckb';

/// Replaces ASCII digits in [input] with the digits used by [languageCode].
String localizeDigits(String input, String languageCode) {
  if (!usesArabicIndicDigits(languageCode)) return input;
  final b = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      b.write(_arabicIndic[unit - 0x30]);
    } else {
      b.writeCharCode(unit);
    }
  }
  return b.toString();
}

String formatInt(int value, String languageCode) =>
    localizeDigits(value.toString(), languageCode);

/// Converts Arabic-Indic and Extended Arabic-Indic (Persian) digits to ASCII.
String asciiDigits(String input) {
  final b = StringBuffer();
  for (final r in input.runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      b.writeCharCode(0x30 + r - 0x0660);
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      b.writeCharCode(0x30 + r - 0x06F0);
    } else {
      b.writeCharCode(r);
    }
  }
  return b.toString();
}

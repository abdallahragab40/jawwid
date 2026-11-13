import '../content/language.dart';
import '../content/models.dart';
import '../core/numerals.dart';
import '../l10n/generated/app_localizations.dart';

/// Name of an edition in the current interface language.
String editionName(AppLocalizations l10n, String editionId) =>
    switch (editionId) {
      'ar' => l10n.editionArabic,
      'ckb' => l10n.editionKurdish,
      'en' => l10n.editionEnglish,
      'id' => l10n.editionIndonesian,
      _ => editionId,
    };

/// The label for a physical page: its printed number when it has one,
/// otherwise "cover" / "unnumbered page". Printed numbers are distinct from
/// physical PDF indices conceptually; in these four editions they coincide
/// on every numbered page.
String printedPageLabel(
  AppLocalizations l10n,
  Edition e,
  int physical,
  AppLanguage lang,
) {
  final printed = e.printedNumberOf(physical);
  if (printed != null) return l10n.pageLabel(formatInt(printed, lang.code));
  if (physical == 1) return l10n.pageCover;
  if (physical == e.pageCount) return l10n.pageBackCover;
  return l10n.pageUnnumbered;
}

String pageRangeLabel(AppLocalizations l10n, PageRange r, AppLanguage lang) =>
    r.start == r.end
    ? l10n.pageLabel(formatInt(r.start, lang.code))
    : l10n.pageRangeLabel(
        formatInt(r.start, lang.code),
        formatInt(r.end, lang.code),
      );

String topicTitle(Topic t, AppLanguage lang) => t.title.of(lang.code).text;

String n(int value, AppLanguage lang) => formatInt(value, lang.code);

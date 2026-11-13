import '../content/language.dart';

/// Single place for the product name. Change these values to rebrand; no
/// other file hard-codes the name.
abstract final class Branding {
  /// Name shown in Arabic-script interfaces (Arabic, Kurdish).
  static const String nameArabicScript = 'جَوِّد';

  /// Name shown in Latin-script interfaces (English, Indonesian). The platform
  /// launcher labels (Android `res/values*/strings.xml`, iOS
  /// `*.lproj/InfoPlist.strings`) carry the same two forms.
  static const String nameLatin = 'Jawwid';

  /// Subtitle per interface language. These are the titles of the source
  /// editions themselves.
  static const Map<String, String> subtitle = {
    'ar': 'تبسيط التجويد',
    'ckb': 'ئاسانکردنی تەجوید',
    'en': 'Simplifying Tajweed',
    'id': 'Tajwid Ringkas',
  };

  /// Font for the Arabic-script name: Noto Naskh keeps the fatha, shadda and
  /// kasra close to the letters (Amiri sets them far apart at display sizes).
  /// Same face as the app icon. Null keeps the surrounding heading font.
  static String? nameFontFamily(AppLanguage language) =>
      language.usesArabicScript ? 'NotoNaskhArabic' : null;

  static String name(AppLanguage language) =>
      language.usesArabicScript ? nameArabicScript : nameLatin;

  static String subtitleFor(AppLanguage language) => subtitle[language.code]!;
}

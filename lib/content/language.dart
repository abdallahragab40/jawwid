import 'package:flutter/widgets.dart';

/// The four interface languages. Each one also identifies its book edition.
enum AppLanguage {
  ar('ar', TextDirection.rtl, 'العربية'),
  ckb('ckb', TextDirection.rtl, 'کوردی'),
  en('en', TextDirection.ltr, 'English'),
  id('id', TextDirection.ltr, 'Bahasa Indonesia');

  const AppLanguage(this.code, this.direction, this.nativeName);

  final String code;
  final TextDirection direction;

  /// The language's own name, shown in the language picker in every locale.
  final String nativeName;

  Locale get locale => Locale(code);

  bool get isRtl => direction == TextDirection.rtl;

  /// Arabic-script languages share Arabic-script typography.
  bool get usesArabicScript => this == ar || this == ckb;

  /// Edition id equals the language code in this app.
  String get editionId => code;

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
    (l) => l.code == code,
    orElse: () => AppLanguage.ar,
  );
}

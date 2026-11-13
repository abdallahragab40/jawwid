import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled fonts' licences and the Tanzil notice to Flutter's
/// licence registry, so they appear on the licences page.
void registerBundledLicenses() {
  const fonts = {
    'NotoNaskhArabic-OFL.txt': 'Noto Naskh Arabic',
    'NotoSansArabic-OFL.txt': 'Noto Sans Arabic',
    'Amiri-OFL.txt': 'Amiri',
    'AmiriQuran-OFL.txt': 'Amiri Quran',
    'Literata-OFL.txt': 'Literata',
    'Inter-OFL.txt': 'Inter',
  };
  LicenseRegistry.addLicense(() async* {
    for (final e in fonts.entries) {
      final text = await rootBundle.loadString(
        'assets/fonts/licenses/${e.key}',
      );
      yield LicenseEntryWithLineBreaks([e.value], text);
    }
    yield const LicenseEntryWithLineBreaks(
      ['Tanzil Quran Text'],
      'Tanzil Quran Text (Uthmani, Version 1.1)\nCopyright (C) 2007-2026 Tanzil Project\n'
      'License: Creative Commons Attribution 3.0\n\n'
      'Permission is granted to copy and distribute verbatim copies of this text, but CHANGING IT IS NOT ALLOWED.\n'
      'This Quran text can be used in any website or application, provided that its source (Tanzil Project) '
      'is clearly indicated, and a link is made to tanzil.net to enable users to keep track of changes.\n\n'
      'Jawwid shows verbatim excerpts of individual verses as examples. https://tanzil.net',
    );
  });
}

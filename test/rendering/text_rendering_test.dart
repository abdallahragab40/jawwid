// Renders Arabic, Kurdish and Qur'anic text with the bundled fonts to PNG
// images, so shaping, joining across coloured spans and mark placement can be
// inspected visually. Run with:
//   flutter test test/rendering --update-goldens
// The images are written to test/rendering/goldens/ and copied into
// docs/evidence/ for review.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/theme.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/widgets/quran_excerpt_view.dart';

import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);
  final content = loadContent();

  Widget frame(Widget child, {double width = 900}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildFullTheme(AppLanguage.ar, Brightness.light),
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.topCenter,
        child: RepaintBoundary(
          key: const Key('shot'),
          child: Container(
            width: width,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );

  testWidgets('Qur\'anic examples: highlighted letters keep joining and marks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 3400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final rows = <Widget>[];
    for (final r in content.rules) {
      final spans = quranSpans(
        r.example,
        RattilType.quran(size: 34, color: RattilColors.ink),
        highlight: LessonColors.highlight,
        highlightBg: LessonColors.highlightBg,
      );
      rows.add(
        Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                r.id,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text.rich(
                  TextSpan(
                    style: RattilType.quran(size: 34, color: RattilColors.ink),
                    children: spans,
                  ),
                ),
              ),
            ),
            // The same excerpt without highlighting, for side-by-side comparison.
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  r.example.text,
                  style: RattilType.quran(
                    size: 34,
                    color: RattilColors.inkMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    await tester.pumpWidget(frame(Column(children: rows)));
    await expectLater(
      find.byKey(const Key('shot')),
      matchesGoldenFile('goldens/quran_highlights.png'),
    );
  });

  testWidgets('Kurdish and Arabic glyph specimen in every Arabic-script role', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const kurdish =
        'ڕ ڵ ێ ۆ ە ڤ پ چ ژ گ ک ی ئ — قەڵەوکردن، شاردنەوە، ڕەوم، ئیشمام، پێناسەی زانستی تەجوید';
    const arabic =
        'الإِخْفَاءُ الحَقِيقِيُّ: النُّطْقُ بِالحَرْفِ بِصِفَةٍ بَيْنَ الإِظْهَارِ وَالإِدْغَامِ — ٠١٢٣٤٥٦٧٨٩';
    Widget line(
      String label,
      String family,
      String text, {
      double size = 26,
      FontWeight w = FontWeight.w400,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: family,
                fontSize: size,
                fontWeight: w,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pumpWidget(
      frame(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            line(
              'Noto Naskh Arabic 400 — Kurdish prose',
              'NotoNaskhArabic',
              kurdish,
            ),
            line(
              'Noto Naskh Arabic 700',
              'NotoNaskhArabic',
              kurdish,
              w: FontWeight.w700,
            ),
            line(
              'Noto Sans Arabic 500 — Kurdish controls',
              'NotoSansArabic',
              kurdish,
              size: 20,
              w: FontWeight.w500,
            ),
            line(
              'Amiri 700 — Kurdish headings',
              'Amiri',
              kurdish,
              w: FontWeight.w700,
            ),
            line(
              'Noto Naskh Arabic — Arabic with full tashkeel',
              'NotoNaskhArabic',
              arabic,
            ),
            line(
              'Noto Sans Arabic — Arabic controls',
              'NotoSansArabic',
              arabic,
              size: 20,
            ),
            line(
              'Amiri 700 — Arabic headings',
              'Amiri',
              arabic,
              w: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('shot')),
      matchesGoldenFile('goldens/arabic_kurdish_specimen.png'),
    );
  });
}

// Large-size comparison used to confirm that colouring letters inside a word
// keeps joining and every combining mark (see docs/validation.md).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/theme.dart';
import 'package:rattil/widgets/quran_excerpt_view.dart';
import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);
  final c = loadContent();
  testWidgets(
    'highlight variants keep every mark: colour only / colour+background / plain',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final ids = ['r08', 'r02', 'r16'];
      final rows = <Widget>[];
      for (final id in ids) {
        final e = c.rule(id)!.example;
        final base = RattilType.quran(size: 64, color: Colors.black);
        Widget t(List<InlineSpan> s) => Directionality(
          textDirection: TextDirection.rtl,
          child: Text.rich(TextSpan(style: base, children: s)),
        );
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              t(
                quranSpans(
                  e,
                  base,
                  highlight: Colors.red,
                  highlightBg: Colors.transparent,
                ),
              ), // color only
              t(
                quranSpans(
                  e,
                  base,
                  highlight: Colors.red,
                  highlightBg: const Color(0x33FF0000),
                ),
              ), // color + bg
              t([TextSpan(text: e.text)]),
            ],
          ),
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: RepaintBoundary(
              key: const Key('s'),
              child: Container(
                color: Colors.white,
                child: Column(children: rows),
              ),
            ),
          ),
        ),
      );
      await expectLater(
        find.byKey(const Key('s')),
        matchesGoldenFile('goldens/highlight_variants.png'),
      );
    },
  );
}

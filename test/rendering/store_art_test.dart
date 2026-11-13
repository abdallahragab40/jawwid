// Store artwork, rendered with the app's own fonts and colours:
//   * Google Play feature graphic (1024 × 500), Arabic and English
//   * captioned store screenshots (1290 × 2796, accepted by both stores),
//     built from the simulator screenshots in docs/screenshots/
//
//   flutter test test/rendering/store_art_test.dart --update-goldens
//
// Output: docs/store/. Retake docs/screenshots/ first (integration_test/
// screenshots_test.dart) — after the content review, so the store images do
// not show the "Development preview" badge.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/theme.dart';

import '../helpers.dart';
import 'app_icon_test.dart';

const _out = '../../docs/store';

class _Copy {
  const _Copy(this.file, this.ar, this.en);
  final String file; // screenshot name without the language prefix
  final String ar;
  final String en;
}

const _shots = [
  _Copy('01_home', 'تعلّم التجويد خطوة بخطوة', 'Learn Tajweed step by step'),
  _Copy(
    '11_lesson',
    'دروس واضحة من نصّ الكتاب',
    'Clear lessons from the book itself',
  ),
  _Copy(
    '07_feedback',
    'تدرّب، واعرف سبب كل إجابة',
    'Practise, and see why each answer is right',
  ),
  _Copy(
    '15_sort',
    'تمارين ممتعة لتثبيت الحروف',
    'Playful drills for the letter groups',
  ),
  _Copy(
    '08_makharij',
    'مخارج الحروف بالرسم التوضيحي',
    'Articulation points, illustrated',
  ),
  _Copy(
    '04_reader',
    'صفحات الكتاب الأصلية دائمًا معك',
    'The original book pages, always at hand',
  ),
];

TextStyle _headline(bool ar, double size) => TextStyle(
  fontFamily: ar ? 'NotoNaskhArabic' : 'Literata',
  fontWeight: FontWeight.w700,
  fontSize: size,
  height: ar ? 1.5 : 1.2,
  color: RattilColors.paper,
);

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.ar});
  final bool ar;

  @override
  Widget build(BuildContext context) {
    final points = ar
        ? 'دروس  •  تدريب  •  الكتاب الأصلي'
        : 'Lessons  •  Practice  •  The original book';
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [RattilColors.emerald500, RattilColors.emerald900],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Row(
            children: [
              const SizedBox.square(
                dimension: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(64)),
                  child: AppIconArt(),
                ),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ar ? 'جَوِّد' : 'Jawwid',
                      style: _headline(ar, ar ? 96 : 84),
                    ),
                    Text(
                      ar ? 'تبسيط التجويد' : 'Simplifying Tajweed',
                      style: _headline(
                        ar,
                        34,
                      ).copyWith(color: RattilColors.goldLight),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      points,
                      style: TextStyle(
                        fontFamily: ar ? 'NotoSansArabic' : 'Inter',
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: RattilColors.paper.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreShot extends StatelessWidget {
  const _StoreShot({
    required this.ar,
    required this.caption,
    required this.shot,
  });
  final bool ar;
  final String caption;
  final ui.Image shot;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RattilColors.emerald700, RattilColors.emerald900],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 150),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: _headline(ar, ar ? 92 : 86),
              ),
            ),
            const SizedBox(height: 90),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(70),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 60,
                          offset: Offset(0, 24),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: RawImage(image: shot, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _render(
  WidgetTester tester,
  Size size,
  Widget child,
  String name,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(RepaintBoundary(child: child));
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('$_out/$name.png'),
  );
}

void main() {
  setUpAll(loadAppFonts);

  for (final ar in [true, false]) {
    final lang = ar ? 'ar' : 'en';
    testWidgets('Play feature graphic ($lang)', (tester) async {
      await _render(
        tester,
        const Size(1024, 500),
        _FeatureGraphic(ar: ar),
        'feature_graphic_$lang',
      );
    });

    for (final (i, c) in _shots.indexed) {
      testWidgets('store screenshot ${i + 1} ($lang)', (tester) async {
        // English has no feedback shot; it uses the question itself.
        final file = (!ar && c.file == '07_feedback') ? '06_practice' : c.file;
        final bytes = File(
          'docs/screenshots/${lang}_$file.png',
        ).readAsBytesSync();
        final image = await tester.runAsync(() async {
          final codec = await ui.instantiateImageCodec(bytes);
          return (await codec.getNextFrame()).image;
        });
        await _render(
          tester,
          const Size(1290, 2796),
          _StoreShot(ar: ar, caption: ar ? c.ar : c.en, shot: image!),
          'screenshot_${lang}_${i + 1}',
        );
      });
    }
  }
}

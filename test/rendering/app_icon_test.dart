// Renders the app icon with the real bundled Amiri font (Flutter shapes the
// Arabic word correctly; the image tools available here cannot).
//   flutter test test/rendering/app_icon_test.dart --update-goldens
//   python3 tools/make_icons.py      # → iOS AppIcon set + Android mipmaps
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/theme.dart';

import '../helpers.dart';

/// The icon artwork. [foregroundOnly] draws the star and the word on a
/// transparent field, scaled into the Android adaptive-icon safe zone.
class AppIconArt extends StatelessWidget {
  const AppIconArt({super.key, this.foregroundOnly = false});
  final bool foregroundOnly;

  @override
  Widget build(BuildContext context) {
    // Laid out at one fixed size (the full icon's 884 px field) and scaled as
    // a whole, so the word keeps its proportion to the star at any size.
    final art = FittedBox(child: SizedBox.square(dimension: 884, child: _art));
    if (foregroundOnly) {
      // Adaptive icons show the middle 66% of a 108dp canvas.
      return Padding(padding: const EdgeInsets.all(190), child: art);
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 0.85,
          colors: [RattilColors.emerald500, RattilColors.emerald900],
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(70), child: art),
    );
  }

  static final Widget _art = Stack(
    alignment: Alignment.center,
    children: [
      const Positioned.fill(child: CustomPaint(painter: _StarPainter())),
      Padding(
        // Optical centring of the word with its marks (fatha, shadda, kasra).
        padding: const EdgeInsets.only(top: 110),
        child: Text(
          'جَوِّد',
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontWeight: FontWeight.w700,
            fontSize: 285,
            height: 1,
            color: RattilColors.paper,
          ),
        ),
      ),
    ],
  );
}

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final gold = Paint()
      ..color = RattilColors.goldLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035
      ..strokeJoin = StrokeJoin.miter;
    // Eight-pointed star: two squares, one turned by 45°.
    for (final turn in [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = turn + math.pi / 4 + i * math.pi / 2;
        final p = c + Offset(math.cos(a), math.sin(a)) * r * 0.97;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gold);
    }
    canvas.drawCircle(
      c,
      r * 0.62,
      Paint()
        ..color = RattilColors.goldSoft.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.012,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  setUpAll(loadAppFonts);

  for (final (name, fg) in [('app_icon_1024', false), ('app_icon_fg', true)]) {
    testWidgets('app icon artwork: $name', (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: RepaintBoundary(child: AppIconArt(foregroundOnly: fg)),
        ),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}

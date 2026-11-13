import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A restrained geometric rosette, echoing the corner rosettes of the books'
/// section headings. Purely decorative: excluded from semantics.
class Rosette extends StatelessWidget {
  const Rosette({super.key, this.size = 28, this.color, this.petals = 8});
  final double size;
  final Color? color;
  final int petals;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _RosettePainter(
        color ?? (context.isDark ? RattilColors.goldLight : RattilColors.gold),
        petals,
      ),
    ),
  );
}

class _RosettePainter extends CustomPainter {
  _RosettePainter(this.color, this.petals);
  final Color color;
  final int petals;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, size.width / 28)
      ..isAntiAlias = true;
    final fill = Paint()..color = color.withValues(alpha: 0.16);

    // Eight-pointed star made of two overlapping squares.
    for (var k = 0; k < 2; k++) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = (math.pi / 2) * i + (math.pi / 4) * k;
        final p = c + Offset(math.cos(a), math.sin(a)) * r * 0.92;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
    // Petal ring.
    for (var i = 0; i < petals; i++) {
      final a = (2 * math.pi / petals) * i;
      final p = c + Offset(math.cos(a), math.sin(a)) * r * 0.48;
      canvas.drawCircle(p, r * 0.14, stroke);
    }
    canvas.drawCircle(
      c,
      r * 0.2,
      Paint()..color = color.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _RosettePainter old) =>
      old.color != color || old.petals != petals;
}

/// A small label tag with angled ends, like the books' "definition:" labels.
class LabelTag extends StatelessWidget {
  const LabelTag(
    this.text, {
    super.key,
    this.color,
    this.textColor,
    this.emphasis = false,
  });
  final String text;
  final Color? color;
  final Color? textColor;

  /// Uses the books' emphasis red for the text, as the books do for labels.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final bg =
        color ?? (dark ? const Color(0xFF22302B) : RattilColors.goldFaint);
    final fg =
        textColor ??
        (emphasis
            ? (dark ? const Color(0xFFF2A39C) : RattilColors.emphasis)
            : (dark ? RattilColors.goldLight : const Color(0xFF6B5320)));
    // Sized to its text and aligned to the reading start, so it never
    // stretches across a list and wraps instead of overflowing.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      heightFactor: 1,
      child: CustomPaint(
        painter: _TagPainter(
          bg,
          dark ? RattilColors.nightLine : RattilColors.goldSoft,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 3, 14, 4),
          child: Text(
            text,
            style: context.type.ui(
              size: 13,
              weight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPainter extends CustomPainter {
  _TagPainter(this.fill, this.border);
  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final notch = math.min(8.0, size.height / 2);
    final path = Path()
      ..moveTo(notch, 0)
      ..lineTo(size.width - notch, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - notch, size.height)
      ..lineTo(notch, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TagPainter old) =>
      old.fill != fill || old.border != border;
}

/// Section heading with a small rosette, used on native screens.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 10),
    child: Row(
      children: [
        const Rosette(size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: context.type.heading(size: 19)),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Thin gold rule with a centred rosette, for separating major blocks.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.isDark
        ? RattilColors.nightLine
        : RattilColors.goldSoft;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(child: Divider(color: color)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Rosette(size: 16),
            ),
            Expanded(child: Divider(color: color)),
          ],
        ),
      ),
    );
  }
}

/// "Development preview" marker for unreviewed supplementary content.
/// Only rendered in the preview content channel.
class PreviewBadge extends StatelessWidget {
  const PreviewBadge(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF3A3220) : const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: dark ? const Color(0xFF6A5A2A) : const Color(0xFFE8CF8A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_outlined,
            size: 14,
            color: dark ? const Color(0xFFE8CF8A) : const Color(0xFF7A5B00),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: context.type.ui(
                size: 11.5,
                weight: FontWeight.w600,
                color: dark ? const Color(0xFFE8CF8A) : const Color(0xFF7A5B00),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

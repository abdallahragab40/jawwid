import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A circular progress ring that animates to [value], with [child] centred.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.stroke = 7,
    this.color,
    this.child,
    this.semanticsLabel,
  });
  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final Widget? child;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Semantics(
      label: semanticsLabel,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: stroke,
                  strokeCap: StrokeCap.round,
                  backgroundColor: dark
                      ? RattilColors.nightLine
                      : RattilColors.emerald50,
                  color:
                      color ??
                      (dark
                          ? RattilColors.emeraldLight
                          : RattilColors.emerald700),
                ),
              ),
              ?child,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../core/numerals.dart';
import '../features/study/study_state.dart';
import '../l10n/generated/app_localizations.dart';

/// A− [slider] A+ control for the lesson text size.
class LessonTextSizeControl extends StatelessWidget {
  const LessonTextSizeControl({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final double value;
  final ValueChanged<double> onChanged;

  static const _step = 0.05;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = Localizations.localeOf(context).languageCode;
    // ٪ and Arabic-Indic digits in Arabic and Kurdish.
    String percent(double v) {
      final digits = formatInt((v * 100).round(), code);
      return code == 'ar' || code == 'ckb' ? '$digits٪' : '$digits%';
    }

    double clamp(double v) => v.clamp(lessonTextScaleMin, lessonTextScaleMax);
    return Row(
      children: [
        IconButton(
          tooltip: l10n.textSmaller,
          icon: Text(
            'A',
            style: context.type.ui(size: 14, weight: FontWeight.w700),
          ),
          onPressed: value <= lessonTextScaleMin
              ? null
              : () => onChanged(clamp(value - _step)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: lessonTextScaleMin,
            max: lessonTextScaleMax,
            divisions: ((lessonTextScaleMax - lessonTextScaleMin) / _step)
                .round(),
            label: percent(value),
            semanticFormatterCallback: percent,
            onChanged: onChanged,
          ),
        ),
        IconButton(
          tooltip: l10n.textLarger,
          icon: Text(
            'A',
            style: context.type.ui(size: 22, weight: FontWeight.w700),
          ),
          onPressed: value >= lessonTextScaleMax
              ? null
              : () => onChanged(clamp(value + _step)),
        ),
      ],
    );
  }
}

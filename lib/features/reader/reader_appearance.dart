import 'package:flutter/material.dart';

import '../study/study_state.dart';

/// Visual treatment of the reader.
///
/// The book pages carry educational colour (red rule letters, coloured
/// articulation diagrams, tables). Pages are therefore never inverted or
/// recoloured per hue:
///  * light – original page colours on a soft paper backdrop;
///  * sepia – a mild warm multiply over the page. Measured on colours sampled
///    from the books, hue shift stays small and every educational colour stays
///    distinguishable (docs/validation.md, "Reader themes");
///  * night – dark controls and backdrop with the ORIGINAL page colours. An
///    optional uniform dimming (all channels scaled equally, hue preserved)
///    can be switched on by the learner.
class ReaderAppearance {
  const ReaderAppearance({
    required this.backdrop,
    required this.chrome,
    required this.onChrome,
    required this.onChromeMuted,
    required this.filter,
    required this.pageShadow,
  });

  final Color backdrop;
  final Color chrome;
  final Color onChrome;
  final Color onChromeMuted;
  final ColorFilter? filter;
  final BoxShadow? pageShadow;

  /// Sepia multiply colour. Whites become warm paper; R/G/B channels are
  /// scaled by 0.973 / 0.937 / 0.863.
  static const sepiaMultiply = Color(0xFFF8EFDC);

  /// Night dimming factor (uniform on R, G and B).
  static const nightDim = 0.82;

  static ReaderAppearance of(ReaderTheme theme, {required bool dim}) =>
      switch (theme) {
        ReaderTheme.light => const ReaderAppearance(
          backdrop: Color(0xFFE9E4D8),
          chrome: Color(0xF2FBF8F1),
          onChrome: Color(0xFF1E2723),
          onChromeMuted: Color(0xFF55635D),
          filter: null,
          pageShadow: BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ),
        ReaderTheme.sepia => const ReaderAppearance(
          backdrop: Color(0xFFE6DAC1),
          chrome: Color(0xF2F5EBD6),
          onChrome: Color(0xFF3B2F1E),
          onChromeMuted: Color(0xFF6E5E45),
          filter: ColorFilter.mode(sepiaMultiply, BlendMode.multiply),
          pageShadow: BoxShadow(
            color: Color(0x2E3B2F1E),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ),
        ReaderTheme.night => ReaderAppearance(
          backdrop: const Color(0xFF101513),
          chrome: const Color(0xF2161D1A),
          onChrome: const Color(0xFFE9E4D8),
          onChromeMuted: const Color(0xFFA9B3AD),
          filter: dim
              ? const ColorFilter.matrix(<double>[
                  nightDim, 0, 0, 0, 0, //
                  0, nightDim, 0, 0, 0, //
                  0, 0, nightDim, 0, 0, //
                  0, 0, 0, 1, 0,
                ])
              : null,
          pageShadow: null,
        ),
      };
}

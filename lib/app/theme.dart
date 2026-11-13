import 'package:flutter/material.dart';

import '../content/language.dart';

/// Brand palette, taken from the books' covers and page furniture.
/// Brand colours are never used to convey educational meaning.
abstract final class RattilColors {
  static const emerald900 = Color(0xFF0A4637);
  static const emerald700 = Color(0xFF125F4C);
  static const emerald500 = Color(0xFF2E7D66);
  static const emerald100 = Color(0xFFDCEBE4);
  static const emerald50 = Color(0xFFEEF5F1);
  static const gold = Color(0xFFA9843A);

  /// Gold for text and small marks on light surfaces: [gold] itself is only
  /// 3.3:1 on paper, this is 5:1 (WCAG AA for body text).
  static const goldText = Color(0xFF86662A);
  static const goldSoft = Color(0xFFE6D6AE);
  static const goldFaint = Color(0xFFF4ECD8);
  static const paper = Color(0xFFFBF8F1);
  static const paperDeep = Color(0xFFF3EDDF);
  static const ink = Color(0xFF1E2723);
  static const inkMuted = Color(0xFF55635D);
  static const line = Color(0xFFE2DACA);

  /// Outline for controls that must stay visible (3:1 on paper).
  static const lineStrong = Color(0xFF9A8E76);

  // Dark surfaces.
  static const night = Color(0xFF0F1513);
  static const nightRaised = Color(0xFF18211E);
  static const nightLine = Color(0xFF2A3531);
  static const nightInk = Color(0xFFE9E4D8);
  static const nightMuted = Color(0xFFA9B3AD);
  static const emeraldLight = Color(0xFF62B89D);
  static const goldLight = Color(0xFFD5B46B);

  /// Emphasis red, used where the books use red for emphasis (labels such as
  /// "definition"), never as decoration.
  static const emphasis = Color(0xFFA5302A);
}

/// Colours that carry educational meaning (highlighted letters in Qur'anic
/// examples). Kept apart from the brand palette on purpose.
abstract final class LessonColors {
  static const highlight = Color(0xFFC0262D);
  static const highlightBg = Color(0x1FC0262D);
  static const highlightDark = Color(0xFFFF8A80);
  static const highlightBgDark = Color(0x29FF8A80);
  static const correct = Color(0xFF1B7A4B);
  static const incorrect = Color(0xFFB3261E);
  static const correctDark = Color(0xFF5CC08E);
  static const incorrectDark = Color(0xFFF28B82);

  static Color correctFor(Brightness b) =>
      b == Brightness.dark ? correctDark : correct;
  static Color incorrectFor(Brightness b) =>
      b == Brightness.dark ? incorrectDark : incorrect;
}

/// One accent per curriculum unit (g1–g8), so units are easy to tell apart.
/// Navigation aid only: never used to convey Tajweed meaning.
abstract final class UnitColors {
  static const _light = [
    Color(0xFF1F6F5C),
    Color(0xFF2A6C86),
    Color(0xFF85661F),
    Color(0xFFA4502E),
    Color(0xFF7A3E6C),
    Color(0xFF4A5296),
    Color(0xFF5E6B24),
    Color(0xFF8A4A4A),
  ];
  static const _dark = [
    Color(0xFF6CC3A6),
    Color(0xFF7EC0DA),
    Color(0xFFD9B865),
    Color(0xFFEB9B7A),
    Color(0xFFD49BC6),
    Color(0xFFA2A9EB),
    Color(0xFFBAC97A),
    Color(0xFFDDA0A0),
  ];

  /// Accent of the unit at [index] (0-based, wraps around).
  static Color of(int index, Brightness b) =>
      (b == Brightness.dark ? _dark : _light)[index % _light.length];
}

/// Typography roles. Arabic-script text is set larger with taller lines so its
/// perceived size and weight match the Latin text beside it.
class RattilType {
  RattilType(this.language, this.brightness);
  final AppLanguage language;
  final Brightness brightness;

  bool get _ar => language.usesArabicScript;
  Color get _ink =>
      brightness == Brightness.dark ? RattilColors.nightInk : RattilColors.ink;
  Color get _muted => brightness == Brightness.dark
      ? RattilColors.nightMuted
      : RattilColors.inkMuted;

  static const arabicFallback = ['NotoNaskhArabic', 'NotoSansArabic', 'Amiri'];
  static const latinFallback = ['Inter', 'Literata'];

  String get uiFamily => _ar ? 'NotoSansArabic' : 'Inter';
  String get proseFamily => _ar ? 'NotoNaskhArabic' : 'Literata';
  String get headingFamily => _ar ? 'Amiri' : 'Literata';

  List<String> get _fallback => _ar ? latinFallback : arabicFallback;

  TextStyle ui({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: uiFamily,
    fontFamilyFallback: _fallback,
    fontSize: _ar ? size * 1.04 : size,
    height: _ar ? 1.45 : 1.3,
    fontWeight: weight,
    color: color ?? _ink,
  );

  TextStyle prose({
    double size = 17,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: proseFamily,
    fontFamilyFallback: _fallback,
    fontSize: _ar ? size * 1.12 : size,
    height: _ar ? 1.9 : 1.55,
    fontWeight: weight,
    color: color ?? _ink,
  );

  TextStyle heading({double size = 22, Color? color}) => TextStyle(
    fontFamily: headingFamily,
    fontFamilyFallback: _fallback,
    fontSize: _ar ? size * 1.18 : size,
    height: _ar ? 1.5 : 1.25,
    fontWeight: FontWeight.w700,
    color: color ?? _ink,
  );

  TextStyle muted({double size = 13.5}) => ui(size: size, color: _muted);

  /// Arabic book terms embedded in any interface language (letters, terms).
  TextStyle arabicTerm({
    double size = 18,
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: 'NotoNaskhArabic',
    fontFamilyFallback: const ['Amiri', 'NotoSansArabic'],
    fontSize: size,
    height: 1.8,
    fontWeight: weight,
    color: color ?? _ink,
  );

  /// Qur'anic examples: always Amiri Quran, always RTL (applied by the widget).
  static TextStyle quran({double size = 28, required Color color}) => TextStyle(
    fontFamily: 'AmiriQuran',
    fontFamilyFallback: const ['Amiri', 'NotoNaskhArabic'],
    fontSize: size,
    height: 2.1,
    color: color,
  );

  /// Labels drawn over diagrams.
  TextStyle diagramLabel({Color? color}) =>
      ui(size: 12.5, weight: FontWeight.w600, color: color);
}

ThemeData buildTheme(AppLanguage language, Brightness brightness) {
  final type = RattilType(language, brightness);
  final dark = brightness == Brightness.dark;
  final scheme = dark
      ? const ColorScheme.dark(
          primary: RattilColors.emeraldLight,
          onPrimary: Color(0xFF062A21),
          secondary: RattilColors.goldLight,
          onSecondary: Color(0xFF2A2006),
          surface: RattilColors.night,
          onSurface: RattilColors.nightInk,
          surfaceContainerLowest: RattilColors.night,
          surfaceContainerLow: RattilColors.nightRaised,
          surfaceContainer: RattilColors.nightRaised,
          surfaceContainerHigh: Color(0xFF1F2925),
          outline: RattilColors.nightLine,
          outlineVariant: RattilColors.nightLine,
          error: Color(0xFFFFB4AB),
        )
      : const ColorScheme.light(
          primary: RattilColors.emerald700,
          onPrimary: Colors.white,
          primaryContainer: RattilColors.emerald100,
          onPrimaryContainer: RattilColors.emerald900,
          secondary: RattilColors.gold,
          onSecondary: Colors.white,
          secondaryContainer: RattilColors.goldFaint,
          onSecondaryContainer: Color(0xFF3B2D0C),
          surface: RattilColors.paper,
          onSurface: RattilColors.ink,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: Color(0xFFFFFDF8),
          surfaceContainer: RattilColors.paperDeep,
          surfaceContainerHigh: Color(0xFFEEE6D4),
          outline: RattilColors.line,
          outlineVariant: RattilColors.line,
          error: Color(0xFFB3261E),
        );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
  );
  TextTheme textTheme = base.textTheme.copyWith(
    displaySmall: type.heading(size: 30),
    headlineMedium: type.heading(size: 26),
    headlineSmall: type.heading(size: 22),
    titleLarge: type.heading(size: 20),
    titleMedium: type.ui(size: 16, weight: FontWeight.w600),
    titleSmall: type.ui(size: 14, weight: FontWeight.w600),
    bodyLarge: type.prose(size: 17),
    bodyMedium: type.ui(size: 15),
    bodySmall: type.muted(size: 13),
    labelLarge: type.ui(size: 15, weight: FontWeight.w600),
    labelMedium: type.ui(size: 13, weight: FontWeight.w500),
    labelSmall: type.ui(size: 12, weight: FontWeight.w500),
  );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: type.heading(size: 20),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? RattilColors.nightRaised : Colors.white,
      indicatorColor: dark ? const Color(0xFF23423A) : RattilColors.emerald100,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? (dark ? RattilColors.emeraldLight : RattilColors.emerald700)
              : (dark ? RattilColors.nightMuted : RattilColors.inkMuted),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? type.ui(
                size: 12.5,
                weight: FontWeight.w700,
                color: dark
                    ? RattilColors.emeraldLight
                    : RattilColors.emerald700,
              )
            : type.ui(size: 12.5, weight: FontWeight.w600, color: type._muted),
      ),
      height: 68,
    ),
    cardTheme: CardThemeData(
      color: dark ? RattilColors.nightRaised : Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outline),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outline,
      space: 1,
      thickness: 1,
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: type.ui(size: 13, weight: FontWeight.w500),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: type.ui(size: 15, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: type.ui(size: 15, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 44),
        textStyle: type.ui(size: 15, weight: FontWeight.w600),
      ),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: type.ui(size: 16, weight: FontWeight.w500),
      subtitleTextStyle: type.muted(size: 13.5),
      minVerticalPadding: 10,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? RattilColors.nightRaised : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline),
      ),
      hintStyle: type.muted(size: 15),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: type.ui(size: 14, color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Convenience access to typography roles from a [BuildContext].
extension RattilTypeX on BuildContext {
  RattilType get type =>
      Theme.of(this).extension<RattilTypeHolder>()?.roles ??
      RattilType(AppLanguage.ar, Theme.of(this).brightness);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class RattilTypeHolder extends ThemeExtension<RattilTypeHolder> {
  const RattilTypeHolder(this.roles);
  final RattilType roles;
  @override
  RattilTypeHolder copyWith({RattilType? roles}) =>
      RattilTypeHolder(roles ?? this.roles);
  @override
  RattilTypeHolder lerp(
    covariant ThemeExtension<RattilTypeHolder>? other,
    double t,
  ) => this;
}

ThemeData buildFullTheme(AppLanguage language, Brightness brightness) =>
    buildTheme(language, brightness).copyWith(
      extensions: [RattilTypeHolder(RattilType(language, brightness))],
    );

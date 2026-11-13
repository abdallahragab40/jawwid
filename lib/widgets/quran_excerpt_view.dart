import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../content/language.dart';
import '../content/models.dart';
import '../core/numerals.dart';
import '../features/study/study_state.dart';
import '../l10n/generated/app_localizations.dart';

/// Builds the spans of an excerpt with its highlighted letters.
///
/// Highlights are applied as colour and background only, inside a single
/// paragraph with a single font, so Arabic joining and the position of
/// combining marks are preserved across span boundaries (verified visually,
/// see docs/validation.md). Ranges always cover a base letter together with
/// its marks.
List<InlineSpan> quranSpans(
  QuranExcerpt e,
  TextStyle base, {
  required Color highlight,
  required Color highlightBg,
}) {
  final spans = <InlineSpan>[];
  var cursor = 0;
  final hl = base.copyWith(color: highlight, backgroundColor: highlightBg);
  for (final (start, end) in e.highlights) {
    if (start > cursor) {
      spans.add(TextSpan(text: e.text.substring(cursor, start)));
    }
    spans.add(TextSpan(text: e.text.substring(start, end), style: hl));
    cursor = end;
  }
  if (cursor < e.text.length) {
    spans.add(TextSpan(text: e.text.substring(cursor)));
  }
  return spans;
}

/// The highlighted characters, joined, for accessibility descriptions.
String highlightedText(QuranExcerpt e) =>
    e.highlights.map((h) => e.text.substring(h.$1, h.$2)).join('، ');

String quranReference(
  QuranExcerpt e,
  AppLanguage lang,
  Map<int, SurahName> names,
) {
  final n = names[e.surah];
  if (lang.usesArabicScript) {
    return '[${n?.arabic ?? ''}: ${localizeDigits(e.ayah.toString(), lang.code)}]';
  }
  return '${n?.latin ?? 'Surah ${e.surah}'} ${e.surah}:${e.ayah}';
}

class QuranExcerptView extends ConsumerWidget {
  const QuranExcerptView({
    super.key,
    required this.excerpt,
    this.size = 30,
    this.showReference = true,
    this.center = true,
  });

  final QuranExcerpt excerpt;
  final double size;
  final bool showReference;
  final bool center;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final names = ref.watch(contentProvider).surahNames;
    final dark = context.isDark;
    final ink = dark ? RattilColors.nightInk : RattilColors.ink;
    final base = RattilType.quran(size: size, color: ink);
    final ref_ = quranReference(excerpt, lang, names);
    final semantics = l10n.quranExcerptSemantics(
      excerpt.text,
      highlightedText(excerpt),
      ref_,
    );

    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text.rich(
              TextSpan(
                style: base,
                children: [
                  const TextSpan(text: '﴿ '),
                  ...quranSpans(
                    excerpt,
                    base,
                    highlight: dark
                        ? LessonColors.highlightDark
                        : LessonColors.highlight,
                    highlightBg: dark
                        ? LessonColors.highlightBgDark
                        : LessonColors.highlightBg,
                  ),
                  const TextSpan(text: ' ﴾'),
                ],
              ),
              textAlign: center ? TextAlign.center : TextAlign.start,
            ),
          ),
          if (showReference) ...[
            const SizedBox(height: 2),
            Text(
              excerpt.isWholeAyah ? ref_ : l10n.quranExcerptFrom(ref_),
              style: context.type.muted(size: 12.5),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

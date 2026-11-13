import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/branding.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';

/// First launch: what the app offers, and the learner's language (Arabic is
/// preselected whatever the device language is).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final ctl = ref.read(studyProvider.notifier);
    final dark = context.isDark;
    final scheme = Theme.of(context).colorScheme;
    final green = dark ? RattilColors.emeraldLight : RattilColors.emerald700;

    Widget feature(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: green.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: context.type.ui(size: 15))),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          children: [
            const Center(child: Rosette(size: 76)),
            const SizedBox(height: 14),
            Text(
              Branding.name(lang),
              textAlign: TextAlign.center,
              style: context.type
                  .heading(size: 40)
                  .copyWith(
                    fontFamily: Branding.nameFontFamily(lang),
                    color: green,
                  ),
            ),
            Text(
              Branding.subtitleFor(lang),
              textAlign: TextAlign.center,
              style: context.type.ui(
                size: 16,
                weight: FontWeight.w600,
                color: dark ? RattilColors.goldLight : RattilColors.goldText,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.welcomeIntro(Branding.subtitleFor(lang)),
              textAlign: TextAlign.center,
              style: context.type.prose(size: 17),
            ),
            const SizedBox(height: 18),
            feature(Icons.menu_book_outlined, l10n.welcomeLessons),
            feature(Icons.auto_stories_outlined, l10n.welcomeBook),
            feature(Icons.bolt, l10n.welcomePractice),
            const SizedBox(height: 22),
            Text(
              l10n.welcomeChooseLanguage,
              style: context.type.heading(size: 18),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in AppLanguage.values)
                  ChoiceChip(
                    label: Text(
                      l.nativeName,
                      textDirection: l.direction,
                      style: TextStyle(
                        fontFamily: l.usesArabicScript
                            ? 'NotoSansArabic'
                            : 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: l == lang,
                    showCheckmark: false,
                    selectedColor: scheme.primaryContainer,
                    onSelected: (_) => ctl.setLanguage(l),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.welcomeLanguageLater, style: context.type.muted()),
            const SizedBox(height: 26),
            FilledButton(
              onPressed: ctl.setWelcomed,
              child: Text(l10n.welcomeStart),
            ),
          ],
        ),
      ),
    );
  }
}

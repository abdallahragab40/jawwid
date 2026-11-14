import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/language.dart';
import '../core/numerals.dart';
import '../core/reminder.dart';
import '../core/study_persistence.dart';
import '../widgets/study_save_banner.dart';
import '../features/study/study_state.dart';
import '../features/welcome/welcome_screen.dart';
import '../l10n/ckb_localizations.dart';
import '../l10n/generated/app_localizations.dart';
import 'branding.dart';
import 'shell.dart';
import 'theme.dart';

/// Shows app-wide messages (unit completed) above any screen.
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

class RattilApp extends ConsumerWidget {
  const RattilApp({super.key, this.home});

  /// Overrides the home widget (used by tests).
  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final appTheme = ref.watch(studyProvider.select((s) => s.appTheme));
    final welcomed = ref.watch(studyProvider.select((s) => s.welcomed));
    ref.listen(studyProvider.select((s) => s.topicProgress), (prev, next) {
      if (prev == null) return;
      final content = ref.read(contentProvider);
      bool done(Map<String, TopicProgress> p, String id) =>
          p[id] == TopicProgress.completed;
      for (final (i, g) in content.groups.indexed) {
        final availableIds = g.topicIds
            .where((id) => content.topic(id).isAvailableIn(language.editionId))
            .toList();
        final now =
            availableIds.isNotEmpty && availableIds.every((t) => done(next, t));
        final before =
            availableIds.isNotEmpty && availableIds.every((t) => done(prev, t));
        if (now && !before) {
          final l10n = lookupAppLocalizations(language.locale);
          appMessengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.unitCompleted(
                          formatInt(i + 1, language.code),
                          g.title.of(language.code),
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 4),
              ),
            );
        }
      }
    });
    ref.watch(reminderSyncProvider);
    ref.watch(studyPersistenceProvider);
    return MaterialApp(
      builder: (context, child) =>
          StudySaveBanner(child: child ?? const SizedBox.shrink()),
      scaffoldMessengerKey: appMessengerKey,
      onGenerateTitle: (_) => Branding.name(language),
      debugShowCheckedModeBanner: false,
      locale: language.locale,
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        // Kurdish first: flutter_localizations has no `ckb` resources.
        ...ckbFrameworkDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // The language is always the learner's choice (Arabic on first launch);
      // the device locale is never used to pick it.
      localeResolutionCallback: (_, _) => language.locale,
      theme: buildFullTheme(language, Brightness.light),
      darkTheme: buildFullTheme(language, Brightness.dark),
      themeMode: switch (appTheme) {
        AppThemeChoice.system => ThemeMode.system,
        AppThemeChoice.light => ThemeMode.light,
        AppThemeChoice.dark => ThemeMode.dark,
      },
      themeAnimationDuration: const Duration(milliseconds: 250),
      home:
          home ??
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: welcomed ? const RootShell() : const WelcomeScreen(),
          ),
    );
  }
}

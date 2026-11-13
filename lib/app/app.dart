import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/language.dart';
import '../core/reminder.dart';
import '../features/study/study_state.dart';
import '../features/welcome/welcome_screen.dart';
import '../l10n/ckb_localizations.dart';
import '../l10n/generated/app_localizations.dart';
import 'branding.dart';
import 'shell.dart';
import 'theme.dart';

class RattilApp extends ConsumerWidget {
  const RattilApp({super.key, this.home});

  /// Overrides the home widget (used by tests).
  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final appTheme = ref.watch(studyProvider.select((s) => s.appTheme));
    final welcomed = ref.watch(studyProvider.select((s) => s.welcomed));
    ref.watch(reminderSyncProvider);
    return MaterialApp(
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

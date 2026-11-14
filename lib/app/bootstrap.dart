import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../content/content_repository.dart';
import '../content/language.dart';
import '../core/json_store.dart';
import '../core/study_validation.dart';
import '../features/more/contact_screen.dart';
import '../features/more/backup_screen.dart';
import '../features/study/study_state.dart';
import '../l10n/ckb_localizations.dart';
import '../l10n/generated/app_localizations.dart';
import 'app.dart';
import 'branding.dart';
import 'theme.dart';

class BootstrapData {
  const BootstrapData({
    required this.content,
    required this.store,
    required this.study,
  });
  final ContentRepository content;
  final JsonStore store;
  final StudyState study;
}

Future<BootstrapData> loadBootstrapData() async {
  final content = await ContentRepository.load();
  final store = JsonStore(await getApplicationSupportDirectory());
  try {
    final study = store.loadValidated((json) {
      final state = StudyState.fromJson(json);
      validateStudyReferences(state, content);
      return state;
    });
    return BootstrapData(content: content, store: store, study: study);
  } on UnreadableStoreData {
    throw StudyDataUnavailable(content: content, store: store);
  }
}

/// Assets are ready, but neither local state file could be read. A confirmed
/// manual restore can repair this case; newer-version errors never use it.
class StudyDataUnavailable implements Exception {
  const StudyDataUnavailable({required this.content, required this.store});
  final ContentRepository content;
  final JsonStore store;
}

/// Draws a first frame while assets/storage load and permits non-destructive
/// retries. Invalid/newer data never silently turns into a fresh learner state.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.load = loadBootstrapData});
  final Future<BootstrapData> Function() load;
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<BootstrapData> _load;
  AppLanguage _language = AppLanguage.ar;

  Future<BootstrapData> _startLoad() =>
      Future.sync(widget.load).timeout(const Duration(seconds: 30));

  @override
  void initState() {
    super.initState();
    _load = _startLoad();
  }

  Future<void> _recover(
    BuildContext context,
    StudyDataUnavailable failure,
  ) async {
    final restored = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProviderScope(
          overrides: [
            contentProvider.overrideWithValue(failure.content),
            storeProvider.overrideWithValue(failure.store),
            initialStudyStateProvider.overrideWithValue(
              StudyState(language: _language, welcomed: true),
            ),
          ],
          child: const BackupScreen(recoveryMode: true),
        ),
      ),
    );
    if (restored == true && mounted) {
      setState(() {
        _load = _startLoad();
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<BootstrapData>(
    future: _load,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.requireData;
        return ProviderScope(
          overrides: [
            contentProvider.overrideWithValue(data.content),
            storeProvider.overrideWithValue(data.store),
            initialStudyStateProvider.overrideWithValue(data.study),
          ],
          child: const RattilApp(),
        );
      }
      final l10n = lookupAppLocalizations(_language.locale);
      final failed =
          snapshot.connectionState == ConnectionState.done && snapshot.hasError;
      final message = snapshot.error is UnsupportedStoreVersion
          ? l10n.startupUpdateRequired
          : l10n.startupFailed;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Branding.name(_language),
        locale: _language.locale,
        supportedLocales: [
          for (final language in AppLanguage.values) language.locale,
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...ckbFrameworkDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: buildFullTheme(_language, Brightness.light),
        darkTheme: buildFullTheme(_language, Brightness.dark),
        home: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          Branding.name(_language),
                          textAlign: TextAlign.center,
                          style: context.type.heading(size: 32),
                        ),
                        const SizedBox(height: 24),
                        if (!failed) ...[
                          Center(
                            child: CircularProgressIndicator(
                              semanticsLabel: l10n.startupLoading,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.startupLoading,
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          Text(message, textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () => setState(() {
                              _load = _startLoad();
                            }),
                            child: Text(l10n.startupRetry),
                          ),
                          if (snapshot.error
                              case final StudyDataUnavailable failure)
                            OutlinedButton.icon(
                              icon: const Icon(Icons.restore),
                              onPressed: () => _recover(context, failure),
                              label: Text(l10n.backupRestore),
                            ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FeedbackScreen(
                                  contentContext: 'Startup',
                                ),
                              ),
                            ),
                            child: Text(l10n.feedbackTitle),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final language in AppLanguage.values)
                                OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _language = language),
                                  child: Text(
                                    language.nativeName,
                                    textDirection: language.direction,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

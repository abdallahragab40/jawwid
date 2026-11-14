import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/app/bootstrap.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/core/study_backup.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import '../helpers.dart';

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));
  testWidgets(
    'startup draws loading UI, retries failure, then opens saved study state',
    (tester) async {
      var completer = Completer<BootstrapData>();
      var attempts = 0;
      await tester.pumpWidget(
        AppBootstrap(
          load: () {
            attempts++;
            return completer.future;
          },
        ),
      );
      expect(find.text(ar.startupLoading), findsOneWidget);
      completer.completeError(const UnreadableStoreData());
      await tester.pumpAndSettle();
      expect(find.text(ar.startupFailed), findsOneWidget);
      expect(attempts, 1);
      completer = Completer<BootstrapData>();
      await tester.tap(find.text(ar.startupRetry));
      await tester.pump();
      expect(find.text(ar.startupLoading), findsOneWidget);
      final dir = tempDir();
      addTearDown(() => dir.deleteSync(recursive: true));
      completer.complete(
        BootstrapData(
          content: loadContent(),
          store: JsonStore(dir),
          study: const StudyState(welcomed: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RattilApp), findsOneWidget);
      expect(find.text(ar.navHome), findsWidgets);
      expect(attempts, 2);
    },
  );

  testWidgets(
    'newer data displays update guidance and error text can change language',
    (tester) async {
      await tester.pumpWidget(
        AppBootstrap(load: () async => throw const UnsupportedStoreVersion(99)),
      );
      await tester.pumpAndSettle();
      expect(find.text(ar.startupUpdateRequired), findsOneWidget);
      expect(find.text(ar.backupRestore), findsNothing);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      final en = lookupAppLocalizations(const Locale('en'));
      expect(find.text(en.startupUpdateRequired), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'startup restores a manual backup only after confirmation and reopens the app',
    (tester) async {
      final dir = tempDir();
      addTearDown(() => dir.deleteSync(recursive: true));
      final store = JsonStore(dir);
      final file = File('${dir.path}/rattil_user_data.json')
        ..writeAsStringSync('{broken');
      final backup = File('${file.path}.bak')..writeAsStringSync('also broken');
      final content = loadContent();
      Future<BootstrapData> load() async {
        try {
          return BootstrapData(
            content: content,
            store: store,
            study: store.loadValidated(StudyState.fromJson),
          );
        } on UnreadableStoreData {
          throw StudyDataUnavailable(content: content, store: store);
        }
      }

      await tester.pumpWidget(AppBootstrap(load: load));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, ar.backupRestore),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, ar.backupRestore));
      await tester.pumpAndSettle();
      expect(find.text(ar.backupCopy), findsNothing);
      await tester.enterText(
        find.byType(TextField),
        encodeStudyBackup(
          const StudyState(
            language: AppLanguage.en,
            welcomed: true,
            reminderEnabled: true,
            topicProgress: {'t10': TopicProgress.completed},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, ar.backupRestore),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, ar.backupRestore));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ar.actionCancel));
      await tester.pumpAndSettle();
      expect(file.readAsStringSync(), '{broken');
      expect(backup.readAsStringSync(), 'also broken');
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, ar.backupRestore),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, ar.backupRestore));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, ar.backupRestore));
      await tester.pumpAndSettle();
      final restored = store.loadValidated(StudyState.fromJson);
      expect(restored.progressOf('t10'), TopicProgress.completed);
      expect(restored.reminderEnabled, isFalse);
      final en = lookupAppLocalizations(const Locale('en'));
      expect(find.text(en.navHome), findsWidgets);
      expect(find.byType(RattilApp), findsOneWidget);
    },
  );

  testWidgets('a stalled loader offers retry instead of loading forever', (
    tester,
  ) async {
    final stalled = Completer<BootstrapData>();
    await tester.pumpWidget(AppBootstrap(load: () => stalled.future));
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(find.text(ar.startupFailed), findsOneWidget);
    expect(find.text(ar.startupRetry), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'startup failure is accessible in all languages (${brightness.name})',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          tester.platformDispatcher.platformBrightnessTestValue = brightness;
          addTearDown(
            tester.platformDispatcher.clearPlatformBrightnessTestValue,
          );
          final dir = tempDir();
          addTearDown(() => dir.deleteSync(recursive: true));
          await tester.pumpWidget(
            AppBootstrap(
              load: () => throw StudyDataUnavailable(
                content: loadContent(),
                store: JsonStore(dir),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final lang in AppLanguage.values) {
            await tester.ensureVisible(find.text(lang.nativeName));
            await tester.pumpAndSettle();
            await tester.tap(find.text(lang.nativeName));
            await tester.pumpAndSettle();
            for (final guideline in [
              androidTapTargetGuideline,
              iOSTapTargetGuideline,
              labeledTapTargetGuideline,
              textContrastGuideline,
            ]) {
              final result = await guideline.evaluate(tester);
              expect(
                result.passed,
                isTrue,
                reason: '${lang.code}: ${result.reason}',
              );
            }
          }
        } finally {
          semantics.dispose();
        }
      },
    );
  }

  testWidgets('backgrounding flushes a pending reading position immediately', (
    tester,
  ) async {
    final dir = tempDir();
    addTearDown(() => dir.deleteSync(recursive: true));
    final store = JsonStore(dir);
    final container = await pumpApp(tester, store: store);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(studyProvider.notifier).recordPosition('ar', 46);
    // No timer pump between recording and pausing.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(
      JsonStore(dir).loadValidated(StudyState.fromJson).positions['ar'],
      46,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const SizedBox());
  });
}

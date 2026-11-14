import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/backup_files.dart';
import 'package:rattil/core/study_backup.dart';
import 'package:rattil/features/more/backup_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

import '../helpers.dart';

class _Files implements BackupFiles {
  String? input;
  String? saved;
  bool fail = false;
  @override
  Future<String?> open({required String title}) async => input;
  @override
  Future<bool> save(
    String text, {
    required String name,
    required String title,
  }) async {
    if (fail) throw StateError('write failed');
    saved = text;
    return true;
  }
}

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));
  Future<ProviderContainer> open(WidgetTester tester, _Files files) async {
    final container = await pumpApp(
      tester,
      initial: const StudyState(
        welcomed: true,
        topicProgress: {'t01': TopicProgress.completed},
      ),
    );
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ProviderScope(
          overrides: [backupFilesProvider.overrideWithValue(files)],
          child: const BackupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('file export contains current data and reports write failures', (
    tester,
  ) async {
    final files = _Files();
    await open(tester, files);
    await tester.tap(find.text(ar.backupSaveFile));
    await tester.pumpAndSettle();
    expect(
      decodeStudyBackup(files.saved!).progressOf('t01'),
      TopicProgress.completed,
    );
    expect(decodeStudyBackupEnvelope(files.saved!).exportedAt, isNotNull);
    expect(find.text(ar.backupFileSaved), findsOneWidget);
    files.fail = true;
    await tester.tap(find.text(ar.backupSaveFile));
    await tester.pumpAndSettle();
    expect(find.text(ar.backupFileError), findsOneWidget);
  });

  testWidgets(
    'file import previews counts, cancellation preserves progress, confirmation restores',
    (tester) async {
      final files = _Files()
        ..input = encodeStudyBackup(
          const StudyState(topicProgress: {'t02': TopicProgress.completed}),
          exportedAt: DateTime.utc(2026, 11, 14),
        );
      final container = await open(tester, files);
      await tester.tap(find.text(ar.backupOpenFile));
      await tester.pumpAndSettle();
      expect(find.textContaining('٢٠٢٦'), findsWidgets);
      expect(
        container.read(studyProvider).progressOf('t01'),
        TopicProgress.completed,
      );
      await tester.tap(find.text(ar.actionCancel));
      await tester.pumpAndSettle();
      expect(
        container.read(studyProvider).progressOf('t01'),
        TopicProgress.completed,
      );
      await tester.tap(find.text(ar.backupOpenFile));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, ar.backupRestore));
      await tester.pumpAndSettle();
      expect(
        container.read(studyProvider).progressOf('t02'),
        TopicProgress.completed,
      );
      expect(
        container.read(studyProvider).progressOf('t01'),
        TopicProgress.none,
      );
    },
  );

  testWidgets('cancelled picker and malformed backup do not change progress', (
    tester,
  ) async {
    final files = _Files();
    final container = await open(tester, files);
    await tester.tap(find.text(ar.backupOpenFile));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    files.input = '{}';
    await tester.tap(find.text(ar.backupOpenFile));
    await tester.pumpAndSettle();
    expect(find.text(ar.backupInvalid), findsOneWidget);
    expect(
      container.read(studyProvider).progressOf('t01'),
      TopicProgress.completed,
    );
  });
}

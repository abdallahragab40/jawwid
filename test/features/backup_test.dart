import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/study_backup.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/features/more/backup_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import '../helpers.dart';

class _WriteFailureStore extends JsonStore {
  _WriteFailureStore(super.directory);
  @override
  void saveSync(Map<String, dynamic> data) =>
      throw const FileSystemException('disk full');
}

void main() {
  testWidgets(
    'failed restore write keeps live progress unchanged and explains failure',
    (tester) async {
      final dir = tempDir();
      addTearDown(() => dir.deleteSync(recursive: true));
      final container = await pumpApp(
        tester,
        store: _WriteFailureStore(dir),
        initial: const StudyState(
          welcomed: true,
          topicProgress: {'t01': TopicProgress.completed},
        ),
      );
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(MaterialPageRoute(builder: (_) => const BackupScreen()));
      await tester.pumpAndSettle();
      final ar = lookupAppLocalizations(const Locale('ar'));
      await tester.enterText(
        find.byType(TextField),
        encodeStudyBackup(
          const StudyState(
            welcomed: true,
            topicProgress: {'t02': TopicProgress.completed},
          ),
        ),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, ar.backupRestore));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, ar.backupRestore));
      await tester.pumpAndSettle();
      expect(find.text(ar.backupWriteFailed), findsOneWidget);
      expect(
        container.read(studyProvider).progressOf('t01'),
        TopicProgress.completed,
      );
      expect(
        container.read(studyProvider).progressOf('t02'),
        TopicProgress.none,
      );
    },
  );

  testWidgets(
    'restore requires confirmation and malformed input preserves progress',
    (tester) async {
      final container = await pumpApp(
        tester,
        initial: const StudyState(
          welcomed: true,
          topicProgress: {'t01': TopicProgress.completed},
        ),
      );
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(MaterialPageRoute(builder: (_) => const BackupScreen()));
      await tester.pumpAndSettle();
      final ar = lookupAppLocalizations(const Locale('ar'));
      await tester.enterText(find.byType(TextField), '{}');
      await tester.tap(find.widgetWithText(OutlinedButton, ar.backupRestore));
      await tester.pumpAndSettle();
      expect(find.text(ar.backupInvalid), findsOneWidget);
      expect(
        container.read(studyProvider).progressOf('t01'),
        TopicProgress.completed,
      );
      await tester.enterText(
        find.byType(TextField),
        encodeStudyBackup(
          const StudyState(
            welcomed: true,
            topicProgress: {'t02': TopicProgress.completed},
          ),
        ),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, ar.backupRestore));
      await tester.pumpAndSettle();
      expect(find.text(ar.backupConfirm), findsOneWidget);
      expect(
        container.read(studyProvider).progressOf('t01'),
        TopicProgress.completed,
      );
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
}

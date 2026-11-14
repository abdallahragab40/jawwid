import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/features/more/more_screen.dart';
import 'package:rattil/features/more/contact_screen.dart';
import 'package:rattil/features/study/study_state.dart';

import '../helpers.dart';

void main() {
  testWidgets(
    'feedback diagnostics are optional and exclude private study data',
    (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Jawwid',
        packageName: 'app.jawwid.jawwid',
        version: '1.2.3',
        buildNumber: '4',
        buildSignature: '',
      );
      final container = await pumpApp(
        tester,
        probe: ReaderProbe(),
        initial: const StudyState(language: AppLanguage.en),
      );
      container
          .read(studyProvider.notifier)
          .addNote('en', 10, 'Private note never included');
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const FeedbackScreen(contentContext: 'Question q01 · en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Jawwid: 1.2.3+4'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Include app and content details'),
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Include app and content details'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Jawwid: 1.2.3+4'), findsOneWidget);
      expect(find.textContaining('Language/edition: en/en'), findsOneWidget);
      expect(find.textContaining('Private note never included'), findsNothing);
    },
  );
  testWidgets('Undo restores the deleted note without reverting later edits', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      probe: ReaderProbe(),
      initial: const StudyState(language: AppLanguage.en),
    );
    final ctl = container.read(studyProvider.notifier);
    final deleted = ctl.addNote('en', 10, 'Keep this exact note');
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(
      MaterialPageRoute<void>(builder: (_) => const BookmarksNotesScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).notes, isEmpty);
    ctl.setWeeklyGoal(7);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).notes.single.id, deleted.id);
    expect(
      container.read(studyProvider).notes.single.createdAt,
      deleted.createdAt,
    );
    expect(container.read(studyProvider).weeklyGoal, 7);
  });

  testWidgets(
    'Undo restores a bookmark and weekly goal is editable in Settings',
    (tester) async {
      final container = await pumpApp(
        tester,
        probe: ReaderProbe(),
        initial: const StudyState(language: AppLanguage.en),
      );
      final ctl = container.read(studyProvider.notifier);
      ctl.toggleBookmark('en', 10);
      final bookmark = container.read(studyProvider).bookmarks.single;
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(
        MaterialPageRoute<void>(builder: (_) => const BookmarksNotesScreen()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(container.read(studyProvider).bookmarks, isEmpty);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(container.read(studyProvider).bookmarks.single.id, bookmark.id);
      nav.pop();
      nav.push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, '5'));
      await tester.tap(find.widgetWithText(ChoiceChip, '5'));
      await tester.pumpAndSettle();
      expect(container.read(studyProvider).weeklyGoal, 5);
    },
  );
}

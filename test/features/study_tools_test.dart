import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/features/lessons/lesson_screen.dart';
import 'package:rattil/features/more/more_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import '../helpers.dart';

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  testWidgets('favorite rules survive restart and respect release visibility', (
    tester,
  ) async {
    var container = await pumpApp(tester);
    var nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    openRule(nav.context, 'r05');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(ar.ruleFavorite));
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).favoriteRules, {'r05'});
    final saved = StudyState.fromJson(
      jsonDecode(jsonEncode(container.read(studyProvider).toJson())),
    );
    await tester.pumpWidget(const SizedBox());
    container = await pumpApp(tester, initial: saved);
    await tester.tap(find.text(ar.navRules).last);
    await tester.pumpAndSettle();
    expect(find.text(ar.ruleFavorites), findsOneWidget);
    nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    openRule(nav.context, 'r05');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(ar.ruleFavorite));
    expect(container.read(studyProvider).favoriteRules, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, initial: saved, channel: ContentChannel.release);
    await tester.tap(find.text(ar.navRules).last);
    await tester.pumpAndSettle();
    expect(find.text(ar.ruleFavorites), findsNothing);
  });

  testWidgets('notes attach to a lesson section and reopen it from notes', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    openLesson(nav.context, 't10');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(ar.lessonContents));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(DraggableScrollableSheet),
            matching: find.byIcon(Icons.note_add_outlined),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Remember this section');
    await tester.tap(find.text(ar.actionSave));
    await tester.pumpAndSettle();
    final note = container.read(studyProvider).notes.single;
    expect(note.topicId, 't10');
    expect(note.lessonBlock, isNotNull);
    expect(note.sectionTitle, isNotEmpty);
    final restored = StudyState.fromJson(
      jsonDecode(jsonEncode(container.read(studyProvider).toJson())),
    );
    expect(restored.notes.single.sectionTitle, note.sectionTitle);
    container.read(studyProvider.notifier).updateNote(note.id, 'Updated');
    expect(
      container.read(studyProvider).notes.single.lessonBlock,
      note.lessonBlock,
    );
    nav.pop();
    await tester.pumpAndSettle();
    nav.push(MaterialPageRoute(builder: (_) => const BookmarksNotesScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.notesTab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.notesOpenSection));
    await tester.pumpAndSettle();
    final lesson = tester.widget<LessonScreen>(find.byType(LessonScreen));
    expect(lesson.topicId, 't10');
    expect(lesson.scrollToBlock, note.lessonBlock);
  });

  testWidgets(
    'cross-language notes retain source page without opening a different translation section',
    (tester) async {
      final content = loadContent();
      final block = content.lesson('t10', 'en')!.blocks.first;
      final now = DateTime(2026, 11, 13);
      await pumpApp(
        tester,
        initial: StudyState(
          language: AppLanguage.ar,
          notes: [
            Note(
              id: 'n1',
              edition: 'en',
              page: block.page,
              topicId: 't10',
              text: 'English note',
              createdAt: now,
              updatedAt: now,
              lessonBlock: 0,
              sectionTitle: block.plain,
            ),
          ],
        ),
      );
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(MaterialPageRoute(builder: (_) => const BookmarksNotesScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ar.notesTab));
      await tester.pumpAndSettle();
      expect(find.text(ar.notesOpenSection), findsNothing);
      expect(find.text(ar.notesOpenPage), findsOneWidget);
    },
  );
}

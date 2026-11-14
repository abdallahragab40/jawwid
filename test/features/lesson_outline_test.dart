import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/core/study_backup.dart';
import 'package:rattil/features/lessons/lesson_outline.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import '../helpers.dart';

void main() {
  test(
    'every outline points to unchanged lesson headings and effort is bounded',
    () {
      final content = loadContent();
      for (final lang in AppLanguage.values) {
        for (final lesson in content.lessons[lang.code]!.values) {
          for (final (index, section) in lessonOutline(lesson)) {
            expect(identical(lesson.blocks[index], section), isTrue);
            expect(section.plain, isNotEmpty);
          }
          expect(lessonReadingMinutes(lesson), inInclusiveRange(1, 180));
        }
      }
    },
  );

  test(
    'backups with unknown editions and out-of-range pages are rejected before restore',
    () {
      for (final positions in [
        {'unknown': 1},
        {'ar': 999},
        {'en': 0},
      ]) {
        expect(
          () => decodeStudyBackup(
            encodeStudyBackup(StudyState(positions: positions)),
            content: loadContent(),
          ),
          throwsFormatException,
        );
      }
      final valid = decodeStudyBackup(
        encodeStudyBackup(const StudyState(positions: {'ar': 42})),
        content: loadContent(),
      );
      expect(valid.positions['ar'], 42);
    },
  );

  testWidgets('English unit celebration does not require the absent topic', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      initial: const StudyState(language: AppLanguage.en),
    );
    final content = loadContent();
    final group = content.groups.firstWhere((g) => g.topicIds.contains('t07'));
    for (final id in group.topicIds.where(
      (id) => content.topic(id).isAvailableIn('en'),
    )) {
      container.read(studyProvider.notifier).setTopicCompleted(id, true);
      await tester.pumpAndSettle();
    }
    final en = lookupAppLocalizations(const Locale('en'));
    expect(
      find.text(
        en.unitCompleted(
          '${content.groups.indexOf(group) + 1}',
          group.title.of('en'),
        ),
      ),
      findsOneWidget,
    );
    expect(container.read(studyProvider).progressOf('t07'), TopicProgress.none);
  });

  testWidgets('English course progress excludes absent topic seven', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: const StudyState(
        language: AppLanguage.en,
        topicProgress: {'t07': TopicProgress.completed},
      ),
    );
    final en = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.text(en.navLessons).last);
    await tester.pumpAndSettle();
    expect(find.text(en.curriculumProgress('0', '0', '29')), findsOneWidget);
  });

  testWidgets(
    'lesson end provides heading review links and contents gives reading effort',
    (tester) async {
      await pumpApp(tester);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      openLesson(nav.context, 't10');
      await tester.pumpAndSettle();
      final ar = lookupAppLocalizations(const Locale('ar'));
      expect(find.text(ar.lessonReviewOutline), findsOneWidget);
      await tester.tap(find.byTooltip(ar.lessonContents));
      await tester.pumpAndSettle();
      final minutes = lessonReadingMinutes(loadContent().lesson('t10', 'ar')!);
      // The localized phrase exists once in the contents sheet.
      expect(
        find.text(
          ar.lessonReadingTime(
            minutes.toString().replaceAllMapped(
              RegExp(r'\d'),
              (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)],
            ),
          ),
        ),
        findsOneWidget,
      );
    },
  );
}

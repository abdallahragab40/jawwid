import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/features/practice/quiz_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/ckb_localizations.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

import 'helpers.dart';

AppLocalizations l10nOf(String code) => lookupAppLocalizations(Locale(code));

Future<void> tapText(
  WidgetTester tester,
  String text, {
  Finder? scrollable,
}) async {
  final f = find.text(text);
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      300,
      scrollable: scrollable ?? find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

Future<void> goBack(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).first).pop();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'first launch is Arabic even when the device language is English',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await pumpApp(tester, welcomed: false);
      final ar = l10nOf('ar');
      // The welcome screen comes first, already in Arabic.
      expect(find.text(ar.welcomeChooseLanguage), findsOneWidget);
      final wctx = tester.element(find.text(ar.welcomeStart));
      expect(Directionality.of(wctx), TextDirection.rtl);
      await tapText(tester, ar.welcomeStart);
      expect(find.text(ar.navHome), findsWidgets);
      expect(find.text(ar.homeStartTitle), findsOneWidget);
      final ctx = tester.element(find.text(ar.navHome).first);
      expect(Directionality.of(ctx), TextDirection.rtl);
      expect(Localizations.localeOf(ctx), const Locale('ar'));
    },
  );

  testWidgets('choosing a language on the welcome screen switches the app; '
      'data saved before the welcome screen existed skips it', (tester) async {
    final container = await pumpApp(tester, welcomed: false);
    await tapText(tester, 'English');
    final en = l10nOf('en');
    expect(find.text(en.welcomeChooseLanguage), findsOneWidget);
    await tapText(tester, en.welcomeStart);
    expect(find.text(en.navHome), findsWidgets);
    final saved = container.read(studyProvider);
    expect(saved.welcomed, isTrue);
    expect(saved.language, AppLanguage.en);
    expect(StudyState.fromJson(saved.toJson()).welcomed, isTrue);
    expect(StudyState.fromJson({'language': 'ar'}).welcomed, isTrue);
    expect(StudyState.fromJson({'schemaVersion': 1}).welcomed, isFalse);
  });

  testWidgets(
    'Arabic flow: home → topics → lesson → its book page → rule card → practice → saved progress',
    (tester) async {
      final dir = tempDir();
      final store = JsonStore(dir);
      final probe = ReaderProbe();
      final container = await pumpApp(tester, store: store, probe: probe);
      final ar = l10nOf('ar');

      // Home → Lessons tab.
      await tester.tap(find.text(ar.navLessons).last);
      await tester.pumpAndSettle();
      expect(find.text(ar.curriculumTitle), findsOneWidget);

      // Topics → topic 10 opens its lesson directly (no intermediate
      // "read the lesson" screen).
      await tapText(tester, 'أحكامُ النُّونِ السَّاكِنةِ والتَّنوين');
      expect(find.text(ar.lessonRead), findsNothing);
      expect(find.text(ar.topicOpenPages), findsNothing);
      expect(find.text(ar.lessonFromPage('٤١')), findsOneWidget);

      // The lesson's first section links to its book page: physical page 41.
      await tester.tap(find.text(ar.lessonViewInBook).first);
      await tester.pumpAndSettle();
      expect(probe.edition, 'ar');
      expect(probe.page, 41);
      expect(find.text(ar.pageLabel('٤١')), findsWidgets);
      // Turn to page 46 (as the viewer would report) and wait for the debounced save.
      probe.goTo!(46);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text(ar.pageLabel('٤٦')), findsWidgets);
      expect(container.read(studyProvider).positions['ar'], 46);
      expect(
        container.read(studyProvider).progressOf('t10'),
        TopicProgress.read,
      );

      // Back to the lesson → its related rule card (at the lesson end).
      await goBack(tester);
      final rule = find.text('الإخفاء الحقيقي');
      await tester.scrollUntilVisible(rule, 600, scrollable: _lessonScroll);
      await tester.pumpAndSettle();
      await tester.tap(rule);
      await tester.pumpAndSettle();
      expect(find.text(ar.ruleCardTitle), findsOneWidget);
      expect(
        find.text(ar.ruleSourceLine('النسخة العربية', '٤٦')),
        findsOneWidget,
      );

      // Rule card → practice → answer correctly.
      await tapText(tester, ar.rulePractice);
      final asked = await answerCurrentCorrectly(tester, AppLanguage.ar);
      expect(asked.relatedRuleId, 'r05');
      expect(find.text(ar.quizFeedbackCorrect), findsOneWidget);
      expect(container.read(studyProvider).quiz[asked.id]?.lastCorrect, isTrue);

      // Mark the lesson completed at the end of the lesson.
      await goBack(tester);
      await goBack(tester);
      final mark = find.text(ar.topicMarkCompleted);
      await tester.ensureVisible(mark);
      await tester.pumpAndSettle();
      await tester.tap(mark);
      await tester.pumpAndSettle();
      expect(
        container.read(studyProvider).progressOf('t10'),
        TopicProgress.completed,
      );
      await container.read(studyProvider.notifier).flush();

      // "Restart": a fresh app reading the same store keeps everything.
      final restored = StudyState.fromJson(JsonStore(dir).loadSync());
      expect(restored.language, AppLanguage.ar);
      expect(restored.positions['ar'], 46);
      expect(restored.progressOf('t10'), TopicProgress.completed);
      expect(restored.quiz[asked.id]?.lastCorrect, isTrue);
    },
  );

  testWidgets('home: start and continue open lessons; the whole book is a '
      'separate reference; no "Level two" wording', (tester) async {
    final probe = ReaderProbe();
    final container = await pumpApp(tester, probe: probe);
    final ar = l10nOf('ar');
    expect(find.textContaining('المستوى'), findsNothing);
    expect(find.text(ar.homeCurriculum), findsOneWidget);
    // Start → the first lesson.
    await tapText(tester, ar.homeStartTitle);
    expect(find.text(ar.lessonFromPage('٥')), findsOneWidget);
    expect(probe.page, isNull);
    await goBack(tester);
    // Open topic 10 from the topics tab, then come back: Continue → t10.
    await tester.tap(find.text(ar.navLessons).last);
    await tester.pumpAndSettle();
    expect(find.text(ar.curriculumTitle), findsOneWidget);
    expect(find.textContaining('المستوى'), findsNothing);
    await tapText(tester, 'أحكامُ النُّونِ السَّاكِنةِ والتَّنوين');
    expect(container.read(studyProvider).progressOf('t10'), TopicProgress.read);
    await goBack(tester);
    await tester.tap(find.text(ar.navHome).last);
    await tester.pumpAndSettle();
    await tapText(tester, ar.homeContinueTitle);
    expect(find.text(ar.lessonFromPage('٤١')), findsOneWidget);
    await goBack(tester);
    // The whole book opens the reader at the first page.
    await tapText(tester, ar.bookTitle);
    expect(probe.edition, 'ar');
    expect(probe.page, 1);
  });

  testWidgets('a topic without a lesson (absent from the English edition) '
      'opens the overview with the other editions', (tester) async {
    await pumpApp(tester, initial: const StudyState(language: AppLanguage.en));
    final en = l10nOf('en');
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(openTopic(nav.context, 't07'));
    await tester.pumpAndSettle();
    expect(find.text(en.topicAvailableIn), findsOneWidget);
    expect(find.text(en.lessonEnd), findsNothing);
  });

  testWidgets('lesson contents jump to a section; the lesson end marks the '
      'topic completed and moves to the next lesson', (tester) async {
    final container = await pumpApp(tester);
    final ar = l10nOf('ar');
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(openLesson(nav.context, 't10'));
    await tester.pumpAndSettle();
    // Contents sheet → the section «الإدغام» is brought into view.
    await tester.tap(find.byTooltip(ar.lessonContents));
    await tester.pumpAndSettle();
    final entry = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.textContaining('٢ – الإدغام'),
    );
    expect(entry, findsWidgets);
    await tester.tap(entry.first);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    // The end of the lesson.
    final end = find.text(ar.lessonEnd);
    await tester.scrollUntilVisible(end, 600, scrollable: _lessonScroll);
    await tester.pumpAndSettle();
    final mark = find.text(ar.topicMarkCompleted);
    await tester.ensureVisible(mark);
    await tester.tap(mark);
    await tester.pumpAndSettle();
    expect(
      container.read(studyProvider).progressOf('t10'),
      TopicProgress.completed,
    );
    final next = find.text(ar.lessonNext);
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).progressOf('t11'), TopicProgress.read);
    expect(find.text('أحكامُ المِيمِ السَّاكِنة'), findsWidgets);
  });

  testWidgets('English lesson navigation skips topic 7 (not in the edition)', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      initial: const StudyState(language: AppLanguage.en),
    );
    final en = l10nOf('en');
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(openLesson(nav.context, 't06'));
    await tester.pumpAndSettle();
    final next = find.text(en.lessonNext);
    await tester.scrollUntilVisible(next, 800, scrollable: _lessonScroll);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).progressOf('t08'), TopicProgress.read);
    expect(container.read(studyProvider).progressOf('t07'), TopicProgress.none);
  });

  testWidgets('settings: daily reminder is scheduled in the learner\'s '
      'language, follows time and language changes, and turns off', (
    tester,
  ) async {
    final reminders = FakeReminders();
    final container = await pumpApp(tester, reminders: reminders);
    final ar = l10nOf('ar');
    expect(reminders.scheduledMinutes, isNull, reason: 'off by default');
    await tester.tap(find.text(ar.navMore).last);
    await tester.pumpAndSettle();
    await tapText(tester, ar.settingsTitle);
    final reminder = find.text(ar.settingsReminder);
    await tester.scrollUntilVisible(
      reminder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(tester.element(reminder), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(reminder);
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).reminderEnabled, isTrue);
    expect(reminders.scheduledMinutes, 20 * 60);
    expect(reminders.scheduledBody, ar.reminderBody);
    // A new time and a new language re-schedule it.
    container.read(studyProvider.notifier).setReminder(minutes: 7 * 60 + 30);
    await tester.pumpAndSettle();
    expect(reminders.scheduledMinutes, 7 * 60 + 30);
    container.read(studyProvider.notifier).setLanguage(AppLanguage.id);
    await tester.pumpAndSettle();
    expect(reminders.scheduledBody, l10nOf('id').reminderBody);
    // Off → cancelled.
    container.read(studyProvider.notifier).setReminder(enabled: false);
    await tester.pumpAndSettle();
    expect(reminders.scheduledMinutes, isNull);
    // Saved and restored.
    final json = container.read(studyProvider).toJson();
    final back = StudyState.fromJson(json);
    expect(back.reminderMinutes, 7 * 60 + 30);
    expect(back.reminderEnabled, isFalse);
    expect(back.hapticsEnabled, isTrue);
  });

  testWidgets('settings: declined notification permission keeps the '
      'reminder off and says why; haptics can be turned off', (tester) async {
    final reminders = FakeReminders(granted: false);
    final container = await pumpApp(tester, reminders: reminders);
    final ar = l10nOf('ar');
    await tester.tap(find.text(ar.navMore).last);
    await tester.pumpAndSettle();
    await tapText(tester, ar.settingsTitle);
    final reminder = find.text(ar.settingsReminder);
    await tester.scrollUntilVisible(
      reminder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(tester.element(reminder), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(reminder);
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).reminderEnabled, isFalse);
    expect(find.text(ar.settingsReminderDenied), findsOneWidget);
    expect(reminders.scheduledMinutes, isNull);
    final haptics = find.text(ar.settingsHaptics);
    await tester.scrollUntilVisible(
      haptics,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(haptics);
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).hapticsEnabled, isFalse);
  });

  testWidgets('bookmarks and notes are saved and survive a restart', (
    tester,
  ) async {
    final dir = tempDir();
    final probe = ReaderProbe();
    final container = await pumpApp(
      tester,
      store: JsonStore(dir),
      probe: probe,
    );
    final ar = l10nOf('ar');
    // The whole book, from Home: opens at the first page.
    await tapText(tester, ar.bookTitle);
    expect(probe.page, 1);
    probe.goTo!(5);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(ar.readerAddBookmark));
    await tester.pumpAndSettle();
    expect(container.read(studyProvider).isBookmarked('ar', 5), isTrue);
    await tester.tap(find.byTooltip(ar.readerNotes));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'ملاحظة تجريبية: التجويد فرض كفاية علمًا',
    );
    await tester.tap(find.text(ar.notesAdd));
    await tester.pumpAndSettle();
    expect(
      container.read(studyProvider).notesAt('ar', 5).single.topicId,
      't01',
    );
    await container.read(studyProvider.notifier).flush();
    final restored = StudyState.fromJson(JsonStore(dir).loadSync());
    expect(restored.isBookmarked('ar', 5), isTrue);
    expect(restored.notesAt('ar', 5).single.text, startsWith('ملاحظة'));
  });

  testWidgets('switching language keeps the study context by topic id', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    final ctl = container.read(studyProvider.notifier);
    ctl.recordPosition('ar', 46); // inside t10 in the Arabic edition
    ctl.setTopicCompleted('t10', true);
    await tester.pumpAndSettle();

    ctl.setLanguage(AppLanguage.ckb);
    await tester.pumpAndSettle();
    final ckb = l10nOf('ckb');
    final ctx = tester.element(find.text(ckb.navHome).first);
    expect(Directionality.of(ctx), TextDirection.rtl);
    expect(MaterialLocalizations.of(ctx), isA<CkbMaterialLocalizations>());
    expect(MaterialLocalizations.of(ctx).backButtonTooltip, 'گەڕانەوە');
    // Continue card points at the equivalent Kurdish page (t10: AR 41–47 → CKB 47–55; 46 → 52).
    expect(find.textContaining(ckb.pageLabel('٥٢')), findsOneWidget);

    ctl.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    final en = l10nOf('en');
    expect(
      Directionality.of(tester.element(find.text(en.navHome).first)),
      TextDirection.ltr,
    );
    expect(
      find.textContaining(en.pageLabel('46')),
      findsOneWidget,
    ); // EN t10 is 41–49 → 46
    // Shared progress is kept across languages; positions stay per edition.
    expect(
      container.read(studyProvider).progressOf('t10'),
      TopicProgress.completed,
    );
    expect(container.read(studyProvider).positions['ar'], 46);

    ctl.setLanguage(AppLanguage.id);
    await tester.pumpAndSettle();
    expect(find.text(l10nOf('id').navHome), findsWidgets);
  });

  testWidgets(
    'a topic missing from an edition is explained, never silently replaced',
    (tester) async {
      final container = await pumpApp(tester);
      container.read(studyProvider.notifier).setLanguage(AppLanguage.en);
      await tester.pumpAndSettle();
      final en = l10nOf('en');
      await tester.tap(find.text(en.navLessons).last);
      await tester.pumpAndSettle();
      await tapText(tester, 'Titles of the Letters (Alqab al-Huruf)');
      expect(
        find.text(
          en.topicUnavailableInEdition(
            'Titles of the Letters (Alqab al-Huruf)',
            en.editionEnglish,
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(en.topicOpenPages), findsNothing);
      expect(find.text(en.editionArabic), findsOneWidget);
      expect(find.text(en.editionKurdish), findsOneWidget);
    },
  );

  testWidgets('release channel hides unreviewed cards and questions', (
    tester,
  ) async {
    await pumpApp(tester, channel: ContentChannel.release);
    final ar = l10nOf('ar');
    // Home: progress, but no practice tile until questions are reviewed.
    expect(find.text(ar.homeProgressTitle), findsOneWidget);
    expect(find.text(ar.practiceQuick), findsNothing);
    expect(find.text(ar.homePracticeTeaser), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(ar.navRules).last);
    await tester.pumpAndSettle();
    expect(find.text(ar.rulesAwaitingReview), findsOneWidget);
    expect(find.text(ar.previewBadge), findsNothing);
    await tester.tap(find.text(ar.navPractice).last);
    await tester.pumpAndSettle();
    expect(find.text(ar.practiceAwaitingReview), findsOneWidget);
  });

  testWidgets('release channel: the welcome screen does not promise '
      'practice that is not available yet', (tester) async {
    await pumpApp(tester, channel: ContentChannel.release, welcomed: false);
    final ar = l10nOf('ar');
    expect(find.text(ar.welcomeLessons), findsOneWidget);
    expect(find.text(ar.welcomePractice), findsNothing);
  });

  for (final lang in AppLanguage.values) {
    testWidgets(
      '${lang.code}: main screens lay out on a small phone with enlarged text',
      (tester) async {
        final container = await pumpApp(
          tester,
          size: const Size(320, 640),
          probe: ReaderProbe(),
        );
        container.read(studyProvider.notifier).setLanguage(lang);
        await tester.pumpAndSettle();
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        final l = l10nOf(lang.code);
        for (final tab in [
          l.navLessons,
          l.navRules,
          l.navPractice,
          l.navMore,
          l.navHome,
        ]) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$tab in ${lang.code}',
          );
        }
        // A rule card and a quiz question in this language.
        await tester.tap(find.text(l.navRules).last);
        await tester.pumpAndSettle();
        await tapText(tester, loadContent().rule('r01')!.title.of(lang.code));
        expect(find.text(l.ruleCardTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
        await goBack(tester);
        await tester.tap(find.text(l.navPractice).last);
        await tester.pumpAndSettle();
        await tapText(tester, l.practiceQuick);
        expect(find.byType(QuizScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Lessons with the widest tables, figures and the most examples.
        // The lesson lays out every block at once, so any overflow anywhere
        // in it is reported here.
        for (final t in ['t06', 't08', 't14', 't15', 't26']) {
          final nav = tester.state<NavigatorState>(
            find.byType(Navigator).first,
          );
          unawaited(openLesson(nav.context, t));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$t in ${lang.code}');
          nav.pop();
          await tester.pumpAndSettle();
        }
      },
    );
  }
}

/// The lesson's own vertical scroll view (tables have horizontal ones).
final _lessonScroll = find
    .descendant(
      of: find.byType(SingleChildScrollView).first,
      matching: find.byType(Scrollable),
    )
    .first;

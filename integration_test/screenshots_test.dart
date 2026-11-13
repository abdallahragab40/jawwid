// Screenshots of the key screens in all four languages and of the reader
// themes, taken on a simulator/device with the real PDFium renderer. The
// driver saves them to docs/screenshots/.
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart -d <device-id>
// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/app/licenses.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/app/shell.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/content/models.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/features/reader/reader_screen.dart';
import 'package:rattil/features/study/study_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshots in all four languages', (tester) async {
    registerBundledLicenses();
    final content = await ContentRepository.load(
      channel: ContentChannel.preview,
    );
    final container = ProviderContainer(
      overrides: [
        contentProvider.overrideWithValue(content),
        storeProvider.overrideWithValue(
          JsonStore(Directory.systemTemp.createTempSync('rattil_shots_')),
        ),
        initialStudyStateProvider.overrideWithValue(const StudyState()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RattilApp()),
    );

    Future<void> settle([int frames = 20]) async {
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> shot(String name) async {
      await settle(8);
      await binding.takeScreenshot(name);
    }

    await settle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    Future<void> popAll() async {
      nav.popUntil((r) => r.isFirst);
      await settle(8);
    }

    final ctl = container.read(studyProvider.notifier);

    // First launch is Arabic.
    await shot('ar_00_first_launch');

    // Scrolling in the real viewer updates the remembered position.
    openReader(nav.context, edition: 'ar', page: 41);
    await settle(25);
    // Not awaited: the animation completes on frames pumped by settle().
    unawaited(debugActiveViewerController!.goToPage(pageNumber: 44));
    await settle(15);
    expect(
      container.read(studyProvider).positions['ar'],
      44,
      reason: 'onPageChanged from the real viewer',
    );
    await popAll();

    // A realistic study state.
    ctl.recordPosition('ar', 6);
    ctl.setTopicCompleted('t01', true);
    ctl.setTopicCompleted('t02', true);
    ctl.recordPosition('ar', 46);
    ctl.toggleBookmark('ar', 46);
    ctl.recordAnswer('q01', true);
    ctl.recordAnswer('q02', false);
    await settle();

    for (final lang in AppLanguage.values) {
      ctl.setLanguage(lang);
      await popAll();
      final code = lang.code;
      final shell = tester.state<RootShellState>(find.byType(RootShell));

      shell.selectTab(Tabs.home);
      await shot('${code}_01_home');
      shell.selectTab(Tabs.lessons);
      await shot('${code}_02_lessons');

      openTopic(nav.context, 't10');
      await shot('${code}_03_topic');
      await popAll();

      final ed = lang.editionId;
      openReader(
        nav.context,
        edition: ed,
        page: content.topic('t10').pagesIn(ed)!.start + 1,
      );
      await settle(30);
      await shot('${code}_04_reader');
      await popAll();

      openRule(nav.context, 'r05');
      await shot('${code}_05_rule_card');
      await popAll();

      openQuiz(nav.context, topicId: 't10');
      await settle(10);
      await shot('${code}_06_practice');
      final option = find.text(content.rule('r01')!.title.of(code));
      if (option.evaluate().isNotEmpty) {
        await tester.tap(option.first);
        await settle(6);
        await shot('${code}_07_feedback');
      }
      await popAll();

      // Native lessons: the opening, a figure cropped from the book,
      // a rebuilt table, and the section index.
      unawaited(openLesson(nav.context, 't10'));
      await shot('${code}_11_lesson');
      await popAll();
      int firstBlock(String topic, LessonBlockType type, [int skip = 0]) =>
          content
              .lesson(topic, code)!
              .blocks
              .indexed
              .where((e) => e.$2.type == type)
              .elementAt(skip)
              .$1;
      unawaited(
        openLesson(
          nav.context,
          't08',
          block: firstBlock('t08', LessonBlockType.crop),
        ),
      );
      await settle(10);
      await shot('${code}_12_lesson_figure');
      await popAll();
      unawaited(
        openLesson(
          nav.context,
          't26',
          block: firstBlock('t26', LessonBlockType.table, 2),
        ),
      );
      await settle(10);
      await shot('${code}_13_lesson_table');
      await tester.tap(find.byIcon(Icons.toc));
      await settle(6);
      await shot('${code}_14_lesson_contents');
      await popAll();

      openMakharij(nav.context);
      await shot('${code}_08_makharij');
      await popAll();

      openSearch(nav.context);
      await settle(6);
      final query = switch (lang) {
        AppLanguage.ar => 'الإخفاء',
        AppLanguage.ckb => 'شاردنەوە',
        AppLanguage.en => 'ikhfaa',
        AppLanguage.id => 'ikhfa',
      };
      await tester.enterText(find.byType(TextField), query);
      await settle(6);
      FocusManager.instance.primaryFocus?.unfocus();
      await shot('${code}_09_search');
      await popAll();

      if (lang == AppLanguage.en) {
        openTopic(nav.context, 't07');
        await shot('en_10_topic_not_in_edition');
        await popAll();
      }
    }

    // Reader themes on a page with red rule letters and a table.
    ctl.setLanguage(AppLanguage.ar);
    await popAll();
    for (final theme in ReaderTheme.values) {
      ctl.setReaderTheme(theme);
      openReader(nav.context, edition: 'ar', page: 46);
      await settle(30);
      await shot('ar_reader_theme_${theme.name}');
      await popAll();
    }
    ctl.setReaderTheme(ReaderTheme.night);
    ctl.setDimNightPages(true);
    openReader(nav.context, edition: 'ar', page: 46);
    await settle(30);
    await shot('ar_reader_theme_night_dimmed');
    await popAll();
    ctl.setReaderTheme(ReaderTheme.light);
    ctl.setDimNightPages(false);
  });
}

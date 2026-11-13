// Screenshots of the main screens in the dark theme (Arabic and English),
// saved by the driver to docs/screenshots/dark_*.png.
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/dark_screenshots_test.dart -d <device-id>
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
import 'package:rattil/core/json_store.dart';
import 'package:rattil/features/study/study_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dark theme screenshots', (tester) async {
    registerBundledLicenses();
    final content = await ContentRepository.load(
      channel: ContentChannel.preview,
    );
    final container = ProviderContainer(
      overrides: [
        contentProvider.overrideWithValue(content),
        storeProvider.overrideWithValue(
          JsonStore(Directory.systemTemp.createTempSync('rattil_dark_')),
        ),
        initialStudyStateProvider.overrideWithValue(
          const StudyState(
            welcomed: true,
            appTheme: AppThemeChoice.dark,
            topicProgress: {
              't01': TopicProgress.completed,
              't02': TopicProgress.completed,
              't10': TopicProgress.read,
            },
          ),
        ),
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
    final ctl = container.read(studyProvider.notifier);
    final shell = tester.state<RootShellState>(find.byType(RootShell));

    for (final lang in const [AppLanguage.ar, AppLanguage.en]) {
      final code = lang.code;
      ctl.setLanguage(lang);
      await settle();
      shell.selectTab(Tabs.home);
      await shot('dark_${code}_home');
      shell.selectTab(Tabs.lessons);
      await shot('dark_${code}_lessons');
      shell.selectTab(Tabs.practice);
      await shot('dark_${code}_practice_tab');
      shell.selectTab(Tabs.home);

      unawaited(openLesson(nav.context, 't10'));
      await shot('dark_${code}_lesson');
      nav.popUntil((r) => r.isFirst);
      await settle(8);

      unawaited(openRule(nav.context, 'r05'));
      await shot('dark_${code}_rule_card');
      nav.popUntil((r) => r.isFirst);
      await settle(8);

      unawaited(openQuiz(nav.context, topicId: 't10'));
      await settle(10);
      // Pick a wrong option so both feedback colours show.
      final option = find.text(content.rule('r03')!.title.of(code));
      if (option.evaluate().isNotEmpty) {
        await tester.tap(option.first);
        await settle(6);
      }
      await shot('dark_${code}_quiz_feedback');
      nav.popUntil((r) => r.isFirst);
      await settle(8);
    }
  });
}

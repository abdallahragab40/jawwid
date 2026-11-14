// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/core/reminder.dart';
import 'package:rattil/features/more/backup_screen.dart';
import 'package:rattil/features/more/more_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

class _NoReminders implements ReminderService {
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> cancel() async {}
  @override
  Future<void> scheduleDaily({
    required int minutes,
    required String title,
    required String body,
    required String channelName,
  }) async {}
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('current product journeys in four languages and dark mode', (
    tester,
  ) async {
    final content = await ContentRepository.load(
      channel: ContentChannel.preview,
    );
    final container = ProviderContainer(
      overrides: [
        contentProvider.overrideWithValue(content),
        initialStudyStateProvider.overrideWithValue(
          const StudyState(welcomed: true),
        ),
        reminderServiceProvider.overrideWithValue(_NoReminders()),
        // No store override: this isolated session never writes actual learner data.
      ],
    );
    addTearDown(container.dispose);
    Future<void> settle() async {
      for (var frame = 0; frame < 20; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RattilApp()),
    );
    await settle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    final ctl = container.read(studyProvider.notifier);
    for (final (lang, theme) in [
      for (final lang in AppLanguage.values) (lang, AppThemeChoice.light),
      (AppLanguage.en, AppThemeChoice.dark),
    ]) {
      ctl.setLanguage(lang);
      ctl.setAppTheme(theme);
      final l10n = lookupAppLocalizations(lang.locale);
      final prefix = 'update_${lang.code}_${theme.name}';
      Future<void> shot(String name) async {
        await settle();
        debugPrint('Capturing ${prefix}_$name');
        await binding.takeScreenshot('${prefix}_$name');
      }

      await shot('home');
      unawaited(openRuleComparison(nav.context, ruleId: 'r05'));
      await shot('comparison');
      nav.pop();
      await settle();
      unawaited(
        nav.push(MaterialPageRoute(builder: (_) => const BackupScreen())),
      );
      await shot('backup');
      nav.pop();
      await settle();
      unawaited(
        nav.push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
      );
      await shot('settings');
      nav.pop();
      await settle();
      unawaited(openLesson(nav.context, 't10'));
      await settle();
      await tester.tap(find.byTooltip(l10n.lessonContents));
      await shot('lesson_contents');
      nav.pop();
      nav.pop();
      await settle();
      expect(tester.takeException(), isNull);
    }
  });
}

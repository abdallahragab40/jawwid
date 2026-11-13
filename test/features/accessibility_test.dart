import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/app/shell.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/content/models.dart';
import 'package:rattil/features/more/more_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

import '../helpers.dart';

/// Flutter's accessibility guidelines on every main screen.
Future<List<String>> _check(WidgetTester tester, String where) async {
  final problems = <String>[];
  for (final (name, g) in [
    ('tap target (Android 48dp)', androidTapTargetGuideline),
    ('tap target (iOS 44pt)', iOSTapTargetGuideline),
    ('labelled tap target', labeledTapTargetGuideline),
    ('text contrast', textContrastGuideline),
  ]) {
    final r = await g.evaluate(tester);
    if (!r.passed) problems.add('$where · $name:\n${r.reason}');
  }
  return problems;
}

void main() {
  for (final lang in AppLanguage.values) {
    testWidgets('${lang.code}: main screens meet the accessibility '
        'guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(
        tester,
        initial: StudyState(language: lang, welcomed: true),
      );
      final l = lookupAppLocalizations(lang.locale);
      final problems = <String>[];
      final shell = tester.state<RootShellState>(find.byType(RootShell));
      for (final (i, tab) in [
        'home',
        'lessons',
        'rules',
        'practice',
        'more',
      ].indexed) {
        shell.selectTab(i);
        await tester.pumpAndSettle();
        problems.addAll(await _check(tester, tab));
      }
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      Future<void> screen(String name, Future<void> Function() open) async {
        unawaited(open());
        await tester.pumpAndSettle();
        problems.addAll(await _check(tester, name));
        nav.popUntil((r) => r.isFirst);
        await tester.pumpAndSettle();
      }

      await screen('lesson', () => openLesson(nav.context, 't10'));
      await screen('rule card', () => openRule(nav.context, 'r05'));
      await screen('quiz', () => openQuiz(nav.context));
      await screen('makharij', () => openMakharij(nav.context));
      await screen('search', () => openSearch(nav.context));
      await screen(
        'settings',
        () =>
            nav.push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
      );
      expect(problems, isEmpty, reason: problems.join('\n\n'));
      expect(l.navHome, isNotEmpty);
      handle.dispose();
    });
  }

  testWidgets('welcome screen and a sort question meet the guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final container = await pumpApp(tester, welcomed: false);
    final problems = await _check(tester, 'welcome');
    container.read(studyProvider.notifier).setWelcomed();
    await tester.pumpAndSettle();
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    final ctl = container.read(studyProvider.notifier);
    for (final q in loadContent().questions) {
      if (q.type != QuestionType.sort) ctl.recordAnswer(q.id, true);
    }
    unawaited(openQuiz(nav.context));
    await tester.pumpAndSettle();
    problems.addAll(await _check(tester, 'sort question'));
    expect(problems, isEmpty, reason: problems.join('\n\n'));
    handle.dispose();
  });
}

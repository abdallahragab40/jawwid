import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/features/curriculum/curriculum_screen.dart';
import 'package:rattil/features/practice/quiz_screen.dart';
import 'package:rattil/features/rules/rule_comparison_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import '../helpers.dart';

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));
  test(
    'study preference survives storage and unknown preferences default safely',
    () {
      final state = const StudyState(learningIntent: LearningIntent.revision);
      expect(
        StudyState.fromJson(state.toJson()).learningIntent,
        LearningIntent.revision,
      );
      expect(
        StudyState.fromJson({'learningIntent': 'future'}).learningIntent,
        LearningIntent.guided,
      );
      expect(
        state.copyWith(weeklyGoal: 5).learningIntent,
        LearningIntent.revision,
      );
    },
  );

  testWidgets(
    'welcome can be skipped and a revision preference changes the daily action',
    (tester) async {
      final ctl = await pumpApp(tester, welcomed: false);
      expect(find.text(ar.welcomeStart).hitTestable(), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(ar.learningRevision).hitTestable(),
        300,
      );
      await tester.tap(find.text(ar.learningRevision));
      await tester.pumpAndSettle();
      expect(ctl.read(studyProvider).learningIntent, LearningIntent.revision);
      await tester.tap(find.text(ar.welcomeStart));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ar.dailySession));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsOneWidget);
    },
  );

  testWidgets('exploration opens curriculum from Home', (tester) async {
    await pumpApp(
      tester,
      initial: const StudyState(learningIntent: LearningIntent.explore),
    );
    await tester.tap(find.text(ar.dailySession));
    await tester.pumpAndSettle();
    expect(find.byType(CurriculumScreen).hitTestable(), findsOneWidget);
  });

  testWidgets(
    'comparison selects distinct rules and blocks draft content in release',
    (tester) async {
      await pumpApp(tester);
      var nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      openRuleComparison(nav.context, ruleId: 'r05');
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .toList();
      expect(fields.first.initialValue, 'r05');
      expect(fields.last.initialValue, isNot('r05'));
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      final title = loadContent().rule('r03')!.title.of('ar');
      await tester.scrollUntilVisible(
        find.text(title).last,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text(title).last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .first
            .initialValue,
        'r03',
      );
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, channel: ContentChannel.release);
      nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      openRuleComparison(nav.context);
      await tester.pumpAndSettle();
      expect(find.text(ar.ruleCompareUnavailable), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    },
  );

  for (final language in AppLanguage.values) {
    testWidgets(
      'comparison fits a small phone with large text in ${language.code}',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpApp(
          tester,
          initial: StudyState(language: language),
          size: const Size(320, 640),
        );
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        openRuleComparison(nav.context, ruleId: 'r05');
        await tester.pumpAndSettle();
        expect(find.byType(RuleComparisonScreen), findsOneWidget);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}

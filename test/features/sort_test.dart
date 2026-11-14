import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/content/models.dart';
import 'package:rattil/features/practice/quiz_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

import '../helpers.dart';

/// Every question except sort ones answered correctly, so a session starts
/// with sort questions (not tried yet).
StudyState _onlySortsLeft() {
  final record = QuizRecord(
    attempts: 1,
    correct: 1,
    lastCorrect: true,
    lastAt: DateTime(2026),
    nextReviewAt: DateTime(2100),
  );
  return StudyState(
    welcomed: true,
    quiz: {
      for (final q in loadContent().questions)
        if (q.type != QuestionType.sort) q.id: record,
    },
  );
}

Future<Question> _openSort(WidgetTester tester) async {
  final ar = lookupAppLocalizations(const Locale('ar'));
  await pumpApp(tester, initial: _onlySortsLeft(), random: Random(3));
  await tester.tap(find.text(ar.navPractice).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(ar.practiceQuick));
  await tester.pumpAndSettle();
  final state = tester.state(find.byType(QuizScreen)) as dynamic;
  final q = state.currentQuestion as Question;
  expect(q.type, QuestionType.sort);
  return q;
}

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  testWidgets('sorting every letter into its group is correct', (tester) async {
    final semantics = tester.ensureSemantics();
    final q = await _openSort(tester);
    expect(find.text(ar.quizSortHint), findsOneWidget);
    await answerCurrentCorrectly(tester, AppLanguage.ar);
    expect(find.text(ar.quizFeedbackCorrect), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsNothing);
    final letter = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == q.items.first.arabic,
    );
    final data = tester.getSemantics(letter).getSemanticsData();
    expect(data.value, contains(ar.quizFeedbackCorrect));
    expect(data.value, contains(q.groups[q.items.first.group].of('ar')));
    semantics.dispose();
  });

  testWidgets('a wrong placement is marked; a placed letter can be taken '
      'back; Check waits for every letter', (tester) async {
    final q = await _openSort(tester);
    final first = q.groups.first.of('ar');
    final check = find.widgetWithText(FilledButton, ar.quizCheck);
    // Place everything in the first group.
    for (final item in q.items) {
      await tester.tap(find.text(item.arabic));
      await tester.pumpAndSettle();
      await tester.tap(find.text(first));
      await tester.pumpAndSettle();
    }
    // Take one back: Check is disabled until it is placed again.
    await tester.tap(find.text(q.items.first.arabic));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(check).onPressed, isNull);
    await tester.tap(find.text(first));
    await tester.pumpAndSettle();
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(find.text(ar.quizFeedbackIncorrect), findsOneWidget);
    final wrong = q.items.where((i) => i.group != 0).length;
    expect(find.byIcon(Icons.cancel), findsNWidgets(wrong));
    final item = q.items.firstWhere((item) => item.group != 0);
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == item.arabic,
      ),
    );
    expect(semantics.properties.value, contains(ar.quizFeedbackIncorrect));
    expect(semantics.properties.value, contains(q.groups[item.group].of('ar')));
  });
}

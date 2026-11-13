import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/models.dart';
import 'package:rattil/features/practice/quiz_screen.dart';
import 'package:rattil/features/practice/session.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

import '../helpers.dart';

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  // Every bundled identify/choice question lists its answer first, so the
  // quiz must shuffle: otherwise "always tap the top option" scores 100%.
  testWidgets('quiz options are shown in a random order', (tester) async {
    final content = loadContent();
    final positions = <int>{};
    for (var seed = 0; seed < 12; seed++) {
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, random: Random(seed));
      await tester.tap(find.text(ar.navPractice).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(ar.practiceQuick));
      await tester.pumpAndSettle();
      final state = tester.state(find.byType(QuizScreen)) as dynamic;
      final q = state.currentQuestion as Question;
      final answer = answerLabel(q, content, AppLanguage.ar, ar);
      if (q.type == QuestionType.identify) {
        final titles = [
          for (final id in q.ruleOptions) content.rule(id)!.title.of('ar'),
        ];
        final ys = [for (final t in titles) tester.getCenter(find.text(t)).dy]
          ..sort();
        positions.add(ys.indexOf(tester.getCenter(find.text(answer)).dy));
      }
      // Answering still works whatever the order.
      await tester.tap(find.text(answer).first);
      await tester.pumpAndSettle();
      expect(find.text(ar.quizFeedbackCorrect), findsOneWidget);
    }
    expect(positions.length, greaterThan(1));
  });

  testWidgets('a lesson ends with a 3-question check that can mark the '
      'lesson completed', (tester) async {
    final container = await pumpApp(tester, random: Random(5));
    final content = loadContent();
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    openLesson(nav.context, 't11');
    await tester.pumpAndSettle();
    final check = find.text(ar.lessonCheckStart);
    await tester.scrollUntilVisible(
      check,
      600,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(check);
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      final state = tester.state(find.byType(QuizScreen)) as dynamic;
      final q = state.currentQuestion as Question;
      expect(q.topicId, 't11');
      await tester.tap(
        find.text(answerLabel(q, content, AppLanguage.ar, ar)).first,
      );
      await tester.pumpAndSettle();
      final next = find.text(i < 2 ? ar.quizNext : ar.quizSeeResult);
      await tester.scrollUntilVisible(
        next,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text(ar.quizPerfect), findsOneWidget);
    final mark = find.text(ar.topicMarkCompleted);
    await tester.scrollUntilVisible(
      mark,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(mark);
    await tester.pumpAndSettle();
    expect(
      container.read(studyProvider).progressOf('t11'),
      TopicProgress.completed,
    );
    expect(find.text(ar.quizLessonCompleted), findsOneWidget);
  });

  group('sessions', () {
    final content = loadContent();
    final pool = content.questions;

    test('are short and mix lessons instead of filling up with one', () {
      final s = buildSession(pool, const {}, Random(1));
      expect(s.length, quizSessionSize);
      expect({for (final q in s) q.id}.length, s.length);
      // Topic 10 holds over a third of the bank but not of a session.
      expect(s.where((q) => q.topicId == 't10').length, lessThan(5));
    });

    test('put earlier mistakes first; mistakes mode has only those', () {
      final missed = pool.skip(40).take(3).toList();
      final results = {
        for (final q in pool.take(30))
          q.id: QuizRecord(
            attempts: 1,
            correct: 1,
            lastCorrect: true,
            lastAt: DateTime(2026),
          ),
        for (final q in missed)
          q.id: QuizRecord(
            attempts: 1,
            correct: 0,
            lastCorrect: false,
            lastAt: DateTime(2026),
          ),
      };
      final s = buildSession(pool, results, Random(2));
      expect(s.take(3).map((q) => q.id).toSet(), {
        for (final q in missed) q.id,
      });
      expect(s.skip(3).every((q) => results[q.id] == null), isTrue);
      final m = buildSession(pool, results, Random(3), mistakesOnly: true);
      expect(m.map((q) => q.id).toSet(), {for (final q in missed) q.id});
      expect(mistakeCount(pool, results), 3);
    });
  });
}

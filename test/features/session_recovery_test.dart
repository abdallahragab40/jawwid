import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/features/practice/quiz_screen.dart';
import 'package:rattil/features/practice/saved_session.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import '../helpers.dart';

void main() {
  testWidgets(
    'restart restores the next question and never records an answer twice',
    (tester) async {
      var container = await pumpApp(tester, random: Random(4));
      var nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      openQuiz(nav.context, limit: 3, topicId: 't11');
      await tester.pumpAndSettle();
      final first = await answerCurrentCorrectly(tester, AppLanguage.ar);
      final state = StudyState.fromJson(
        jsonDecode(jsonEncode(container.read(studyProvider).toJson())),
      );
      final saved = state.savedSession!;
      expect(saved.index, 1);
      expect(saved.correct, 1);
      expect(saved.topicId, 't11');
      expect(state.quiz[first.id]!.attempts, 1);
      expect(saved.canResume(loadContent()), isTrue);
      expect(
        SavedSession.fromJson({
          ...saved.toJson(),
          'topicId': 'missing',
        })!.canResume(loadContent()),
        isFalse,
      );
      expect(
        SavedSession.fromJson({
          ...saved.toJson(),
          'topicId': 't01',
        })!.canResume(loadContent()),
        isFalse,
      );
      final stale = SavedSession.fromJson({
        ...saved.toJson(),
        'fingerprint': 'old-content',
      })!;
      expect(stale.canResume(loadContent()), isFalse);
      final duplicateOrder = saved.toJson();
      duplicateOrder['order'] = [
        for (final row in saved.order) List.filled(row.length, 0),
      ];
      expect(SavedSession.fromJson(duplicateOrder), isNull);
      expect(
        saved.canResume(loadContent(channel: ContentChannel.release)),
        isFalse,
      );
      await tester.pumpWidget(const SizedBox());
      container = await pumpApp(tester, initial: state, random: Random(99));
      nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      openQuiz(nav.context, resume: true);
      await tester.pumpAndSettle();
      final quiz = tester.state(find.byType(QuizScreen)) as dynamic;
      expect(quiz.currentQuestion.id, saved.questionIds[1]);
      expect(container.read(studyProvider).quiz[first.id]!.attempts, 1);
      final ar = lookupAppLocalizations(const Locale('ar'));
      for (var i = 1; i < saved.questionIds.length; i++) {
        await answerCurrentCorrectly(tester, AppLanguage.ar);
        final next = find.text(
          i == saved.questionIds.length - 1 ? ar.quizSeeResult : ar.quizNext,
        );
        await tester.scrollUntilVisible(
          next,
          300,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(container.read(studyProvider).savedSession, isNull);
      expect(find.text(ar.quizPerfect), findsOneWidget);
    },
  );

  test(
    'malformed checkpoints are discarded without affecting other study data',
    () {
      expect(
        SavedSession.fromJson({
          'questionIds': [1],
        }),
        isNull,
      );
      final state = StudyState.fromJson({
        'savedSession': {'index': -1},
        'weeklyGoal': 5,
      });
      expect(state.savedSession, isNull);
      expect(state.weeklyGoal, 5);
    },
  );
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

import '../helpers.dart';

void main() {
  // Every bundled identify/choice question lists its answer first, so the
  // quiz must shuffle: otherwise "always tap the top option" scores 100%.
  testWidgets('quiz options are shown in a random order', (tester) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    final content = loadContent();
    final first = content.questions.reduce(
      (a, b) => a.id.compareTo(b.id) <= 0 ? a : b,
    );
    final titles = [
      for (final id in first.ruleOptions) content.rule(id)!.title.of('ar'),
    ];
    final answer = content.rule(first.answerRuleId!)!.title.of('ar');

    final positions = <int>{};
    for (var seed = 0; seed < 8; seed++) {
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, random: Random(seed));
      await tester.tap(find.text(ar.navPractice).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(ar.practiceStart));
      await tester.pumpAndSettle();
      final ys = [for (final t in titles) tester.getCenter(find.text(t)).dy]
        ..sort();
      positions.add(ys.indexOf(tester.getCenter(find.text(answer)).dy));
      // Answering still works whatever the order.
      await tester.tap(find.text(answer));
      await tester.pumpAndSettle();
      expect(find.text(ar.quizFeedbackCorrect), findsOneWidget);
    }
    expect(positions.length, greaterThan(1));
  });
}

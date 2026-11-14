import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/core/reminder.dart';
import 'package:rattil/features/rules/rule_comparison_screen.dart';
import 'package:rattil/features/study/study_state.dart';
import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);
  for (final lang in [AppLanguage.ar, AppLanguage.en]) {
    testWidgets('rule comparison renders in ${lang.code}', (tester) async {
      tester.view.physicalSize = const Size(1800, 2600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final container = ProviderContainer(
        overrides: [
          contentProvider.overrideWithValue(loadContent()),
          initialStudyStateProvider.overrideWithValue(
            StudyState(language: lang),
          ),
          reminderServiceProvider.overrideWithValue(FakeReminders()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RattilApp(
            home: RuleComparisonScreen(initialRuleId: 'r05'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/rule_comparison_${lang.code}.png'),
      );
    });
  }
}

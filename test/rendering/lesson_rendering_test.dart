// Renders the native lesson of topic 10 in all four languages with the real
// fonts, for visual review (docs/evidence/rendering/lesson_t10_<lang>.png).
//   flutter test test/rendering/lesson_rendering_test.dart --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/core/reminder.dart';
import 'package:rattil/features/lessons/lesson_screen.dart';
import 'package:rattil/features/study/study_state.dart';

import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('lesson t10 renders in ${lang.code}', (tester) async {
      tester.view.physicalSize = const Size(1290, 8600);
      tester.view.devicePixelRatio = 3;
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
          child: const RattilApp(home: LessonScreen(topicId: 't10')),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(LessonTable), findsWidgets);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/lesson_t10_${lang.code}.png'),
      );
    });
  }
}

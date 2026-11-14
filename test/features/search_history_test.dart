import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/features/study/study_state.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import '../helpers.dart';

void main() {
  test(
    'search history is bounded, deduplicated, persisted and language-specific',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final ctl = container.read(studyProvider.notifier);
      for (var i = 0; i < 12; i++) {
        ctl.rememberSearch('query $i');
      }
      ctl.rememberSearch('query 7');
      expect(container.read(studyProvider).recentSearches['ar']!.length, 8);
      expect(
        container.read(studyProvider).recentSearches['ar']!.first,
        'query 7',
      );
      ctl.setLanguage(AppLanguage.en);
      ctl.rememberSearch('ikhfaa');
      final restored = StudyState.fromJson(
        container.read(studyProvider).toJson(),
      );
      expect(restored.recentSearches['en'], ['ikhfaa']);
      expect(restored.recentSearches['ar']!.length, 8);
      ctl.clearRecentSearches();
      expect(container.read(studyProvider).recentSearches['en'], isEmpty);
      expect(container.read(studyProvider).recentSearches['ar']!.length, 8);
    },
  );

  testWidgets('submitted query appears on empty search and can be cleared', (
    tester,
  ) async {
    await pumpApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    openSearch(nav.context);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'الإخفاء');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ActionChip, 'الإخفاء'), findsOneWidget);
    final ar = lookupAppLocalizations(const Locale('ar'));
    await tester.tap(find.text(ar.searchClearHistory));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ActionChip, 'الإخفاء'), findsNothing);
  });
}

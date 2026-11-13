import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';

import '../helpers.dart';

void main() {
  testWidgets('the section bar moves to the next section and back', (
    tester,
  ) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    await pumpApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    openLesson(nav.context, 't10');
    await tester.pumpAndSettle();
    final scroll = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last;
    double offset() => tester.state<ScrollableState>(scroll).position.pixels;

    expect(offset(), 0);
    await tester.tap(find.byTooltip(ar.lessonNextSection));
    await tester.pumpAndSettle();
    final first = offset();
    expect(first, greaterThan(0));
    await tester.tap(find.byTooltip(ar.lessonNextSection));
    await tester.pumpAndSettle();
    expect(offset(), greaterThan(first));
    await tester.tap(find.byTooltip(ar.lessonPrevSection));
    await tester.pumpAndSettle();
    expect(offset(), lessThan(first + 1));
  });
}

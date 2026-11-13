import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/features/more/contact_screen.dart';
import 'package:rattil/l10n/generated/app_localizations.dart';
import 'package:rattil/l10n/ckb_localizations.dart';

Widget app(Widget screen) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: [
    ...ckbFrameworkDelegates,
    ...AppLocalizations.localizationsDelegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: screen,
);

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      '${locale.languageCode}: contact pages fit a small phone with large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        for (final screen in [const FeedbackScreen(), const SupportScreen()]) {
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: [
                ...ckbFrameworkDelegates,
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: screen,
            ),
          );
          await tester.pumpAndSettle();
          await tester.drag(find.byType(ListView), const Offset(0, -1500));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  test(
    'feedback email preserves Arabic, newlines, and reserved characters',
    () {
      const subject = 'اقتراح & question?';
      const message = 'السّلام عليكم\nA + B & C #1';
      final uri = feedbackUri(subject, message);
      expect(uri.scheme, 'mailto');
      expect(uri.path, feedbackEmail);
      expect(uri.queryParameters['subject'], 'Jawwid: $subject');
      expect(uri.queryParameters['body'], message);
      expect(uri.query, isNot(contains('+')));
    },
  );

  testWidgets('feedback requires subject and message before opening email', (
    tester,
  ) async {
    await tester.pumpWidget(app(const FeedbackScreen()));
    await tester.ensureVisible(find.text('Open email app'));
    await tester.tap(find.text('Open email app'));
    await tester.pumpAndSettle();
    expect(find.text('Please fill in this field.'), findsNWidgets(2));
    expect(find.text(feedbackEmail), findsOneWidget);
  });

  testWidgets(
    'support shows InstaPay and both wallets with optional gift terms',
    (tester) async {
      await tester.pumpWidget(app(const SupportScreen()));
      expect(find.text(supportNumber), findsOneWidget);
      expect(
        find.textContaining('All learning features remain free'),
        findsOneWidget,
      );
      expect(find.text(instapayAddress), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(vodafoneNumber),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text(vodafoneNumber), findsOneWidget);
      expect(find.text('Vodafone Cash'), findsOneWidget);
    },
  );
}

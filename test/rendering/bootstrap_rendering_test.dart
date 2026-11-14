import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/bootstrap.dart';
import 'package:rattil/core/json_store.dart';
import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);
  for (final english in [false, true]) {
    testWidgets(
      'startup recovery renders in ${english ? 'en dark' : 'ar light'}',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.platformBrightnessTestValue = english
            ? Brightness.dark
            : Brightness.light;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final dir = tempDir();
        addTearDown(() => dir.deleteSync(recursive: true));
        await tester.pumpWidget(
          AppBootstrap(
            load: () async => throw StudyDataUnavailable(
              content: loadContent(),
              store: JsonStore(dir),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (english) {
          await tester.tap(find.text('English'));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/startup_recovery_${english ? 'en' : 'ar'}.png',
          ),
        );
      },
    );
  }
}

// On-device check with the real PDFium renderer: every topic link, in every
// edition, opens the mapped physical page (118 links: 30 topics × 4 editions,
// minus the 2 documented absences).
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/topic_links_test.dart -d <device-id>
// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/features/reader/reader_screen.dart';
import 'package:rattil/features/study/study_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'topic links open the mapped page in every edition (real PDF viewer)',
    (tester) async {
      final content = await ContentRepository.load(
        channel: ContentChannel.preview,
      );
      final container = ProviderContainer(
        overrides: [
          contentProvider.overrideWithValue(content),
          storeProvider.overrideWithValue(
            JsonStore(Directory.systemTemp.createTempSync('rattil_it_')),
          ),
          initialStudyStateProvider.overrideWithValue(
            const StudyState(welcomed: true),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RattilApp(),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      final failures = <String>[];
      var checked = 0;
      for (final ed in const ['ar', 'ckb', 'en', 'id']) {
        for (final t in content.topics) {
          final range = t.pagesIn(ed);
          if (range == null) continue;
          // Reset the remembered position so the check cannot pass by accident.
          container
              .read(studyProvider.notifier)
              .recordPosition(ed, range.start == 1 ? 2 : 1);
          debugActiveViewerController = null;
          openReader(nav.context, edition: ed, page: range.start);
          // Wait for the real viewer to load and settle on its initial page.
          for (var i = 0; i < 25; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          // The page the real viewer shows, not the page that was requested.
          final controller = debugActiveViewerController;
          final reported = controller != null && controller.isReady
              ? controller.pageNumber
              : null;
          if (reported != range.start) {
            failures.add('${t.id}/$ed expected ${range.start} got $reported');
          }
          checked++;
          nav.pop();
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
      }
      // ignore: avoid_print
      print(
        'TOPIC-LINKS checked=$checked failures=${failures.length} $failures',
      );
      expect(checked, 118);
      expect(failures, isEmpty);
    },
  );
}

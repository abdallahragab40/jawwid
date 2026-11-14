// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/app/routes.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/language.dart';
import 'package:rattil/features/reader/reader_document.dart';
import 'package:rattil/features/reader/reader_screen.dart';
import 'package:rattil/features/study/study_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prepared books resume and reopen without reloading the PDF', (
    tester,
  ) async {
    final content = await ContentRepository.load();
    final container = ProviderContainer(
      overrides: [
        contentProvider.overrideWithValue(content),
        initialStudyStateProvider.overrideWithValue(
          const StudyState(welcomed: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const RattilApp()),
    );
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    for (final language in AppLanguage.values) {
      container.read(studyProvider.notifier).setLanguage(language);
      await tester.pump();
      final edition = content.editions[language.editionId]!;
      final reference = container.read(readerDocumentProvider(edition.asset));
      final listenable = reference.resolveListenable();
      await tester.runAsync(() async => await listenable.load());
      expect(listenable.error, isNull);
      final prepared = listenable.document;
      expect(prepared, isNotNull);
      final page = edition.nearestContentPage(edition.pageCount ~/ 2);
      for (var attempt = 0; attempt < 2; attempt++) {
        debugActiveViewerController = null;
        final timer = Stopwatch()..start();
        openReader(navigator.context, edition: edition.id, page: page);
        for (var frame = 0; frame < 100; frame++) {
          await tester.pump(const Duration(milliseconds: 50));
          if (debugActiveViewerController?.isReady == true &&
              debugActiveViewerController?.pageNumber == page) {
            break;
          }
        }
        expect(debugActiveViewerController?.pageNumber, page);
        expect(identical(listenable.document, prepared), isTrue);
        debugPrint(
          'READER ${edition.id} attempt=$attempt '
          'ready=${timer.elapsedMilliseconds}ms page=$page',
        );
        navigator.pop();
        await tester.pumpAndSettle();
        expect(identical(listenable.document, prepared), isTrue);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

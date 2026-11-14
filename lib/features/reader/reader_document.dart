import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

/// Shares the prepared book between the home screen and reader. Only watched
/// editions stay open; page images remain owned by the viewer's bounded cache.
final readerDocumentProvider = Provider.autoDispose
    .family<PdfDocumentRef, String>((ref, asset) {
      final document = PdfDocumentRefAsset(
        asset,
        // These short, local books can prepare their page metadata together.
        // Progressive loading otherwise starts with page 1 even when resuming
        // much later in the book, then waits before loading the remaining pages.
        useProgressiveLoading: false,
      );
      final listenable = document.resolveListenable();
      final removeListener = listenable.addListener(() {});
      var released = false;
      void release() {
        if (released) return;
        released = true;
        removeListener();
      }

      ref.onDispose(release);
      // useDocument holds a reference until loading finishes, including when the
      // language changes or the owning widget disappears during preparation.
      unawaited(
        Future<void>.sync(() async {
          await listenable.useDocument((_) {});
        }).then((_) {
          // A failed speculative load must not poison a later reader attempt.
          if (listenable.error != null) release();
        }),
      );
      return document;
    });

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/study/study_state.dart';

/// Mobile apps may be suspended without disposing their widgets/providers.
final studyPersistenceProvider = Provider<void>((ref) {
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      if (state != AppLifecycleState.resumed) {
        ref.read(studyProvider.notifier).flushPending();
      }
    },
  );
  ref.onDispose(listener.dispose);
});

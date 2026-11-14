import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/study/study_state.dart';
import '../l10n/generated/app_localizations.dart';

/// Lives above the app navigator so a failed save remains visible when moving
/// between screens. Dirty data is retained until Retry or a later write succeeds.
class StudySaveBanner extends ConsumerWidget {
  const StudySaveBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(studySaveStatusProvider);
    if (status != StudySaveStatus.failed) return child;
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.errorContainer,
          child: SafeArea(
            bottom: false,
            child: MaterialBanner(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              leading: const Icon(Icons.cloud_off_outlined),
              content: Semantics(
                liveRegion: true,
                child: Text(l10n.saveFailed),
              ),
              actions: [
                TextButton(
                  onPressed: () => ref.read(studyProvider.notifier).flush(),
                  child: Text(l10n.startupRetry),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

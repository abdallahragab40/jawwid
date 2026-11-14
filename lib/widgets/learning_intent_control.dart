import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/study/study_state.dart';
import '../app/theme.dart';
import '../l10n/generated/app_localizations.dart';

class LearningIntentControl extends ConsumerWidget {
  const LearningIntentControl({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(studyProvider.select((s) => s.learningIntent));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.learningIntent,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final intent in LearningIntent.values)
              ChoiceChip(
                label: Text(switch (intent) {
                  LearningIntent.guided => l10n.learningGuided,
                  LearningIntent.revision => l10n.learningRevision,
                  LearningIntent.explore => l10n.learningExplore,
                }),
                selected: selected == intent,
                selectedColor: scheme.primary,
                backgroundColor: scheme.surface,
                checkmarkColor: scheme.onPrimary,
                labelStyle: context.type.ui(
                  size: 13,
                  color: selected == intent
                      ? scheme.onPrimary
                      : scheme.onSurface,
                ),
                onSelected: (_) =>
                    ref.read(studyProvider.notifier).setLearningIntent(intent),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(l10n.learningIntentHint),
      ],
    );
  }
}

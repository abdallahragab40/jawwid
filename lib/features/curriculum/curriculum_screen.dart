import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';

/// The 30 Level-2 topics in the order of the books' topic list. Nothing is
/// locked: every topic opens the original pages directly.
class CurriculumScreen extends ConsumerWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final lang = ref.watch(languageProvider);
    final progress = ref.watch(studyProvider.select((s) => s.topicProgress));
    final read = progress.values.where((p) => p != TopicProgress.none).length;
    final completed = progress.values
        .where((p) => p == TopicProgress.completed)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.curriculumTitle),
        actions: [
          IconButton(
            tooltip: l10n.searchTitle,
            icon: const Icon(Icons.search),
            onPressed: () => openSearch(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            l10n.curriculumIntro(n(content.topics.length, lang)),
            style: context.type.muted(size: 14),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.curriculumProgress(
              n(read, lang),
              n(completed, lang),
              n(content.topics.length, lang),
            ),
            style: context.type.ui(size: 13.5, weight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(l10n.curriculumGroupsNote, style: context.type.muted(size: 12)),
          for (final g in content.groups) ...[
            const SizedBox(height: 14),
            SectionHeading(g.title.of(lang.code)),
            Card(
              child: Column(
                children: [
                  for (final (i, id) in g.topicIds.indexed) ...[
                    if (i > 0) const Divider(indent: 64),
                    _TopicTile(
                      topic: content.topic(id),
                      progress: progress[id] ?? TopicProgress.none,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicTile extends ConsumerWidget {
  const _TopicTile({required this.topic, required this.progress});
  final Topic topic;
  final TopicProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final ed = lang.editionId;
    final range = topic.pagesIn(ed);
    final dark = context.isDark;
    final (icon, color, label) = switch (progress) {
      TopicProgress.completed => (
        Icons.check_circle,
        dark ? RattilColors.emeraldLight : RattilColors.emerald700,
        l10n.statusCompleted,
      ),
      TopicProgress.read => (
        Icons.radio_button_checked,
        dark ? RattilColors.goldLight : RattilColors.goldText,
        l10n.statusRead,
      ),
      TopicProgress.none => (
        Icons.radio_button_unchecked,
        dark ? RattilColors.nightMuted : RattilColors.lineStrong,
        l10n.statusNotStarted,
      ),
    };
    final String subtitle;
    if (range == null) {
      subtitle = l10n.topicNotInEditionShort(editionName(l10n, ed));
    } else if (topic.isPartialIn(ed)) {
      subtitle =
          '${pageRangeLabel(l10n, range, lang)} · ${l10n.topicPartialShort}';
    } else {
      subtitle = pageRangeLabel(l10n, range, lang);
    }
    return ListTile(
      leading: Semantics(
        label: label,
        child: SizedBox(
          width: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              if (progress == TopicProgress.none)
                Text(
                  n(topic.order, lang),
                  style: context.type.ui(size: 12, weight: FontWeight.w600),
                ),
            ],
          ),
        ),
      ),
      title: Text(topicTitle(topic, lang)),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        textDirection: Directionality.of(context),
      ),
      onTap: () => openTopic(context, topic.id),
    );
  }
}

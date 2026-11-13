import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';
import '../../core/haptics.dart';

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final lang = ref.watch(languageProvider);
    final topic = content.topic(topicId);
    final ed = lang.editionId;
    final range = topic.pagesIn(ed);
    final progress = ref.watch(
      studyProvider.select((s) => s.progressOf(topicId)),
    );
    final perf = ref.watch(topicPerformanceProvider(topicId));
    final rules = content.rulesForTopic(topicId);
    final group = content.groupOf(topic);
    final partial = topic.partialNotes[ed];
    final others = [
      for (final e in const ['ar', 'ckb', 'en', 'id'])
        if (e != ed && topic.isAvailableIn(e)) e,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.topicNumber(n(topic.order, lang)))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(group.title.of(lang.code), style: context.type.muted(size: 13)),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(
              topicTitle(topic, lang),
              style: context.type.heading(size: 26),
            ),
          ),
          if (lang != AppLanguage.ar) ...[
            const SizedBox(height: 2),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                topic.title.of('ar').text,
                style: context.type.arabicTerm(
                  size: 18,
                  color: context.isDark
                      ? RattilColors.nightMuted
                      : RattilColors.inkMuted,
                ),
              ),
            ),
          ],
          const OrnamentDivider(),

          // Reading.
          if (range != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        LabelTag(l10n.topicInTheBook),
                        Text(
                          pageRangeLabel(l10n, range, lang),
                          style: context.type.ui(
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.topicReadHint(editionName(l10n, ed)),
                      style: context.type.muted(size: 13.5),
                    ),
                    if (partial != null) ...[
                      const SizedBox(height: 10),
                      _Notice(
                        icon: Icons.info_outline,
                        text: partial.of(lang.code),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      icon: const Icon(Icons.auto_stories),
                      label: Text(l10n.topicOpenPages),
                      onPressed: () =>
                          openReader(context, edition: ed, page: range.start),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _Notice(
              icon: Icons.info_outline,
              text: l10n.topicUnavailableInEdition(
                topicTitle(topic, lang),
                editionName(l10n, ed),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.topicAvailableIn,
              style: context.type.ui(size: 14, weight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            for (final e in others)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(editionName(l10n, e)),
                  subtitle: Text(pageRangeLabel(l10n, topic.pagesIn(e)!, lang)),
                  trailing: Icon(
                    Icons.chevron_right,
                    textDirection: Directionality.of(context),
                  ),
                  onTap: () => openReader(
                    context,
                    edition: e,
                    page: topic.pagesIn(e)!.start,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 12),

          // Progress (reading) — separate from practice performance below.
          Card(
            child: SwitchListTile(
              value: progress == TopicProgress.completed,
              onChanged: (v) {
                ref.read(hapticsProvider).toggle();
                ref.read(studyProvider.notifier).setTopicCompleted(topicId, v);
              },
              title: Text(l10n.topicMarkCompleted),
              subtitle: Text(switch (progress) {
                TopicProgress.completed => l10n.statusCompleted,
                TopicProgress.read => l10n.statusRead,
                TopicProgress.none => l10n.statusNotStarted,
              }),
            ),
          ),

          if (range != null && others.isNotEmpty) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(
                l10n.topicOtherEditions,
                style: context.type.ui(size: 15, weight: FontWeight.w600),
              ),
              children: [
                for (final e in others)
                  ListTile(
                    title: Text(editionName(l10n, e)),
                    subtitle: Text(
                      pageRangeLabel(l10n, topic.pagesIn(e)!, lang) +
                          (topic.isPartialIn(e)
                              ? ' · ${l10n.topicPartialShort}'
                              : ''),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      textDirection: Directionality.of(context),
                    ),
                    onTap: () => openReader(
                      context,
                      edition: e,
                      page: topic.pagesIn(e)!.start,
                    ),
                  ),
              ],
            ),
          ],

          if (rules.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionHeading(l10n.topicRelatedRules),
            Card(
              child: Column(
                children: [
                  for (final (i, r) in rules.indexed) ...[
                    if (i > 0) const Divider(indent: 16),
                    ListTile(
                      title: Text(r.title.of(lang.code)),
                      subtitle: lang == AppLanguage.ar
                          ? null
                          : Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                r.title.of('ar'),
                                style: context.type.arabicTerm(size: 15),
                              ),
                            ),
                      trailing: Icon(
                        Icons.chevron_right,
                        textDirection: Directionality.of(context),
                      ),
                      onTap: () => openRule(context, r.id),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (perf.total > 0) ...[
            const SizedBox(height: 8),
            SectionHeading(l10n.topicPractice),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      perf.answered == 0
                          ? l10n.practiceNotTried(n(perf.total, lang))
                          : l10n.practicePerformance(
                              n(perf.correctLatest, lang),
                              n(perf.answered, lang),
                              n(perf.total, lang),
                            ),
                      style: context.type.ui(size: 14),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.task_alt),
                      label: Text(l10n.practiceThisLesson),
                      onPressed: () => openQuiz(context, topicId: topicId),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1D2A26) : RattilColors.emerald50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark ? RattilColors.nightLine : RattilColors.emerald100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: dark ? RattilColors.emeraldLight : RattilColors.emerald700,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.type.ui(size: 14))),
        ],
      ),
    );
  }
}

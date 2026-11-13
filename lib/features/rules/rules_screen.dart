import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';

class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final lang = ref.watch(languageProvider);
    final rules = content.rules;
    final byTopic = <String, List<String>>{};
    for (final r in rules) {
      (byTopic[r.topicId] ??= []).add(r.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rulesTitle),
        actions: [
          IconButton(
            tooltip: l10n.searchTitle,
            icon: const Icon(Icons.search),
            onPressed: () => openSearch(context),
          ),
        ],
      ),
      body: rules.isEmpty
          ? _EmptyReview(text: l10n.rulesAwaitingReview)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Text(l10n.rulesIntro, style: context.type.muted(size: 14)),
                if (content.isPreview) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PreviewBadge(l10n.previewBadge),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.previewExplanation,
                    style: context.type.muted(size: 12),
                  ),
                ],
                for (final t in content.topics)
                  if (byTopic.containsKey(t.id)) ...[
                    const SizedBox(height: 12),
                    SectionHeading(topicTitle(t, lang)),
                    Card(
                      child: Column(
                        children: [
                          for (final (i, id) in byTopic[t.id]!.indexed) ...[
                            if (i > 0) const Divider(indent: 16),
                            Builder(
                              builder: (context) {
                                final r = content.rule(id)!;
                                return ListTile(
                                  title: Text(r.title.of(lang.code)),
                                  subtitle: Row(
                                    children: [
                                      if (lang != AppLanguage.ar)
                                        Flexible(
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Text(
                                              r.title.of('ar'),
                                              style: context.type.arabicTerm(
                                                size: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    textDirection: Directionality.of(context),
                                  ),
                                  onTap: () => openRule(context, r.id),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: Text(l10n.makharijTitle),
                    subtitle: Text(l10n.makharijSubtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      textDirection: Directionality.of(context),
                    ),
                    onTap: () => openMakharij(context),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Rosette(size: 40),
          const SizedBox(height: 16),
          Text(
            text,
            style: context.type.ui(size: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

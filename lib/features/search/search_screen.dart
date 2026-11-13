import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';
import 'search_engine.dart';

final searchEngineProvider = Provider<SearchEngine>(
  (ref) => SearchEngine(ref.watch(contentProvider)),
);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);
    final engine = ref.watch(searchEngineProvider);
    final terms = engine.searchTerms(_q);
    final topicHits = [
      for (final h in terms)
        if (h.kind == SearchHitKind.topic) h,
    ];
    final ruleHits = [
      for (final h in terms)
        if (h.kind == SearchHitKind.rule) h,
    ];
    // Page text exists only for the English and Indonesian editions.
    final pageEditions = lang == AppLanguage.en || lang == AppLanguage.id
        ? [lang.editionId]
        : const ['en', 'id'];
    final pageHits = {
      for (final e in pageEditions)
        e: engine.searchPages(_q, edition: e, limit: 12),
    };
    final anyPage = pageHits.values.any((l) => l.isNotEmpty);
    final lessonHits = engine.searchLessons(_q, lang.code);
    final hasQuery = _q.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _q.isEmpty
                ? null
                : IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).clearButtonTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _query.clear();
                      _q = '';
                    }),
                  ),
          ),
          onChanged: (v) => setState(() => _q = v),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            content.hasLessons(lang.code)
                ? l10n.searchCoverageWithLessons
                : l10n.searchCoverage,
            style: context.type.muted(size: 12.5),
          ),
          const SizedBox(height: 12),
          if (hasQuery &&
              topicHits.isEmpty &&
              ruleHits.isEmpty &&
              lessonHits.isEmpty &&
              !anyPage)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Rosette(size: 32),
                  const SizedBox(height: 10),
                  Text(
                    l10n.searchNoResults(_q.trim()),
                    style: context.type.ui(size: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.searchNoResultsHint,
                    style: context.type.muted(size: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (topicHits.isNotEmpty) ...[
            SectionHeading(l10n.searchLessons),
            Card(
              child: Column(
                children: [
                  for (final (i, h) in topicHits.take(10).indexed) ...[
                    if (i > 0) const Divider(indent: 16),
                    Builder(
                      builder: (context) {
                        final t = content.topic(h.topicId!);
                        final range = t.pagesIn(lang.editionId);
                        return ListTile(
                          title: Text(topicTitle(t, lang)),
                          subtitle: Text(
                            [
                              if (h.matchedText != topicTitle(t, lang))
                                l10n.searchMatched(h.matchedText),
                              range == null
                                  ? l10n.topicNotInEditionShort(
                                      editionName(l10n, lang.editionId),
                                    )
                                  : pageRangeLabel(l10n, range, lang),
                            ].join(' · '),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            textDirection: Directionality.of(context),
                          ),
                          onTap: () => openTopic(context, t.id),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (ruleHits.isNotEmpty) ...[
            SectionHeading(l10n.searchRules),
            Card(
              child: Column(
                children: [
                  for (final (i, h) in ruleHits.take(10).indexed) ...[
                    if (i > 0) const Divider(indent: 16),
                    ListTile(
                      title: Text(content.rule(h.ruleId!)!.title.of(lang.code)),
                      subtitle: Text(
                        topicTitle(content.topic(h.topicId!), lang),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        textDirection: Directionality.of(context),
                      ),
                      onTap: () => openRule(context, h.ruleId!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (lessonHits.isNotEmpty) ...[
            SectionHeading(l10n.searchInLessons),
            Card(
              child: Column(
                children: [
                  for (final (i, h) in lessonHits.take(15).indexed) ...[
                    if (i > 0) const Divider(indent: 16),
                    ListTile(
                      title: Text(
                        '${topicTitle(content.topic(h.topicId!), lang)} · ${l10n.pageLabel(n(h.page!, lang))}',
                      ),
                      subtitle: Text(
                        h.matchedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        textDirection: Directionality.of(context),
                      ),
                      onTap: () =>
                          openLesson(context, h.topicId!, block: h.block),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          for (final e in pageEditions)
            if (pageHits[e]!.isNotEmpty) ...[
              SectionHeading(l10n.searchPagesIn(editionName(l10n, e))),
              Text(l10n.searchPagesNote, style: context.type.muted(size: 12)),
              const SizedBox(height: 6),
              Card(
                child: Column(
                  children: [
                    for (final (i, h) in pageHits[e]!.indexed) ...[
                      if (i > 0) const Divider(indent: 16),
                      ListTile(
                        title: Text(
                          [
                            l10n.pageLabel(n(h.page!, lang)),
                            if (h.topicId != null)
                              topicTitle(content.topic(h.topicId!), lang),
                          ].join(' · '),
                        ),
                        subtitle: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            h.matchedText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          textDirection: Directionality.of(context),
                        ),
                        onTap: () =>
                            openReader(context, edition: e, page: h.page!),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

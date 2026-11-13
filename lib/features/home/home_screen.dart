import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/branding.dart';
import '../../app/routes.dart';
import '../../app/shell.dart';
import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/language.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../reader/reader_screen.dart';
import '../study/study_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);
    final study = ref.watch(studyProvider);
    final now = ref.watch(clockProvider)();
    final target = resolveContinue(study, content, lang);
    final completed = study.topicProgress.values
        .where((p) => p == TopicProgress.completed)
        .length;
    final started = study.topicProgress.values
        .where((p) => p != TopicProgress.none)
        .length;
    final dark = context.isDark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            // Masthead.
            Row(
              children: [
                const Rosette(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Branding.name(lang),
                        style: context.type
                            .heading(size: 30)
                            .copyWith(
                              fontFamily: Branding.nameFontFamily(lang),
                              color: dark
                                  ? RattilColors.emeraldLight
                                  : RattilColors.emerald700,
                              height: 1.15,
                            ),
                      ),
                      Text(
                        Branding.subtitleFor(lang),
                        style: context.type.ui(
                          size: 14,
                          color: dark
                              ? RattilColors.goldLight
                              : RattilColors.gold,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.searchTitle,
                  icon: const Icon(Icons.search),
                  onPressed: () => openSearch(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Continue / start.
            _ContinueCard(target: target, content: content, language: lang),
            const SizedBox(height: 14),

            // Curriculum.
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => RootShell.of(context)?.selectTab(Tabs.lessons),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.homeCurriculum,
                              style: context.type.heading(size: 19),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            textDirection: Directionality.of(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeCurriculumSummary(
                          n(content.topics.length, lang),
                          n(content.groups.length, lang),
                        ),
                        style: context.type.muted(size: 13.5),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: content.topics.isEmpty
                              ? 0
                              : completed / content.topics.length,
                          minHeight: 6,
                          backgroundColor: dark
                              ? RattilColors.nightLine
                              : RattilColors.emerald50,
                          semanticsLabel: l10n.curriculumProgress(
                            n(started, lang),
                            n(completed, lang),
                            n(content.topics.length, lang),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.curriculumProgress(
                          n(started, lang),
                          n(completed, lang),
                          n(content.topics.length, lang),
                        ),
                        style: context.type.ui(size: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // The whole book, kept as the reference behind every lesson.
            Card(
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  16,
                  6,
                  12,
                  6,
                ),
                leading: Icon(
                  Icons.auto_stories_outlined,
                  color: dark ? RattilColors.goldLight : RattilColors.gold,
                ),
                title: Text(
                  l10n.bookTitle,
                  style: context.type.ui(size: 16, weight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.bookSubtitle(editionName(l10n, lang.editionId)),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  textDirection: Directionality.of(context),
                ),
                onTap: () => openBook(context),
              ),
            ),
            const SizedBox(height: 14),

            _ReviewSuggestion(content: content, study: study, language: lang),

            if (study.bookmarks.isNotEmpty) ...[
              const SizedBox(height: 8),
              SectionHeading(l10n.homeRecentBookmarks),
              Card(
                child: Column(
                  children: [
                    for (final (i, b) in study.bookmarks.take(3).indexed) ...[
                      if (i > 0) const Divider(indent: 56),
                      Builder(
                        builder: (context) {
                          final ed = content.editions[b.edition]!;
                          final topics = content.topicsAtPage(
                            b.edition,
                            b.page,
                          );
                          return ListTile(
                            leading: const Icon(Icons.bookmark_outline),
                            title: Text(
                              topics.isEmpty
                                  ? editionName(l10n, b.edition)
                                  : topicTitle(topics.first, lang),
                            ),
                            subtitle: Text(
                              '${editionName(l10n, b.edition)} · ${printedPageLabel(l10n, ed, b.page, lang)}',
                            ),
                            onTap: () => openReader(
                              context,
                              edition: b.edition,
                              page: b.page,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (study.streakEnabled) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 18,
                    color: dark
                        ? RattilColors.emeraldLight
                        : RattilColors.emerald500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      study.currentStreak(now) == 0
                          ? l10n.streakNone
                          : l10n.streakDays(n(study.currentStreak(now), lang)),
                      style: context.type.muted(size: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.target,
    required this.content,
    required this.language,
  });
  final ContinueTarget? target;
  final ContentRepository content;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = context.isDark;
    final t = target;
    final String title;
    final String subtitle;
    final VoidCallback onTap;
    String? notice;
    if (t == null) {
      final first = content.topics.first;
      final range = first.pagesIn(language.editionId)!;
      title = l10n.homeStartTitle;
      subtitle =
          '${topicTitle(first, language)} · ${pageRangeLabel(l10n, range, language)}';
      onTap = () => openTopic(context, first.id);
    } else {
      final ed = content.editions[t.edition]!;
      final topic = content.topicOrNull(t.topicId);
      title = l10n.homeContinueTitle;
      subtitle = [
        if (topic != null) topicTitle(topic, language),
        editionName(l10n, t.edition),
        printedPageLabel(l10n, ed, t.page, language),
      ].join(' · ');
      if (t.unavailableTopicId != null) {
        notice = l10n.homeContinueOtherEdition(
          editionName(l10n, language.editionId),
          editionName(l10n, t.edition),
        );
      }
      final id = t.topicId;
      onTap = id != null && content.lesson(id, language.code) != null
          ? () => openLesson(context, id)
          : () => openReader(context, edition: t.edition, page: t.page);
    }
    return Material(
      color: dark ? const Color(0xFF143A30) : RattilColors.emerald700,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.type.heading(
                        size: 21,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: context.type.ui(
                        size: 14,
                        color: const Color(0xFFE3EFE9),
                      ),
                    ),
                    if (notice != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        notice,
                        style: context.type.ui(
                          size: 12.5,
                          color: RattilColors.goldSoft,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: RattilColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSuggestion extends ConsumerWidget {
  const _ReviewSuggestion({
    required this.content,
    required this.study,
    required this.language,
  });
  final ContentRepository content;
  final StudyState study;
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    String? topicId;
    String? body;
    VoidCallback? action;
    String? actionLabel;

    // 1. A lesson with recently missed practice questions.
    for (final t in content.topics) {
      final qs = content.questionsForTopic(t.id);
      final missed = qs
          .where(
            (q) => study.quiz[q.id] != null && !study.quiz[q.id]!.lastCorrect,
          )
          .length;
      if (missed > 0) {
        final answered = qs.where((q) => study.quiz[q.id] != null).length;
        final correct = answered - missed;
        topicId = t.id;
        body = l10n.reviewMissed(
          n(correct, language),
          n(answered, language),
          topicTitle(t, language),
        );
        actionLabel = l10n.reviewOpenLesson;
        action = () => openTopic(context, t.id);
        break;
      }
    }
    // 2. A lesson that was opened but not marked completed.
    if (topicId == null) {
      final last = study.lastRead?.topicId;
      final candidate =
          last != null && study.progressOf(last) == TopicProgress.read
          ? content.topic(last)
          : content.topics
                .where((t) => study.progressOf(t.id) == TopicProgress.read)
                .firstOrNull;
      if (candidate != null) {
        topicId = candidate.id;
        final hasPractice = content.questionsForTopic(candidate.id).isNotEmpty;
        body = hasPractice
            ? l10n.reviewTryPractice(topicTitle(candidate, language))
            : l10n.reviewFinishLesson(topicTitle(candidate, language));
        actionLabel = hasPractice
            ? l10n.practiceThisLesson
            : l10n.reviewOpenLesson;
        action = hasPractice
            ? () => openQuiz(context, topicId: candidate.id)
            : () => openTopic(context, candidate.id);
      }
    }
    // 3. The next lesson not yet started.
    if (topicId == null) {
      final next = content.topics
          .where((t) => study.progressOf(t.id) == TopicProgress.none)
          .firstOrNull;
      if (next == null) return const SizedBox.shrink();
      topicId = next.id;
      body = l10n.reviewNextLesson(topicTitle(next, language));
      actionLabel = l10n.reviewOpenLesson;
      action = () => openTopic(context, next.id);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabelTag(l10n.homeReviewSuggestion),
            const SizedBox(height: 10),
            Text(body!, style: context.type.ui(size: 15)),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                onPressed: action,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

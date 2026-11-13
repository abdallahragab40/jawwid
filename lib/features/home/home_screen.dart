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
import '../../widgets/progress_ring.dart';
import '../practice/session.dart';
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
                              : RattilColors.goldText,
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

            // Progress and practice, side by side.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ProgressTile(
                      completed: completed,
                      started: started,
                      total: content.topics.length,
                      language: lang,
                    ),
                  ),
                  // Release builds show practice only once it is reviewed.
                  if (content.questions.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(child: _PracticeTile(language: lang)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // The units of the curriculum.
            SectionHeading(
              l10n.homeCurriculum,
              trailing: TextButton(
                onPressed: () => RootShell.of(context)?.selectTab(Tabs.lessons),
                child: Text(l10n.homeSeeAll),
              ),
            ),
            _UnitStrip(content: content, study: study, language: lang),
            const SizedBox(height: 16),

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
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: dark
                  ? const [Color(0xFF1A4A3D), Color(0xFF0F2C24)]
                  : const [RattilColors.emerald500, RattilColors.emerald900],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Padding(
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
                        child: const Icon(
                          Icons.auto_stories,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.completed,
    required this.started,
    required this.total,
    required this.language,
  });
  final int completed;
  final int started;
  final int total;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = l10n.curriculumProgress(
      n(started, language),
      n(completed, language),
      n(total, language),
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => RootShell.of(context)?.selectTab(Tabs.lessons),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeProgressTitle,
                    style: context.type.muted(size: 13),
                  ),
                  const SizedBox(height: 10),
                  ProgressRing(
                    value: total == 0 ? 0 : completed / total,
                    size: 60,
                    semanticsLabel: label,
                    child: ExcludeSemantics(
                      child: Text(
                        n(completed, language),
                        style: context.type.heading(size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ExcludeSemantics(
                    child: Text(
                      l10n.homeLessonsDone(
                        n(completed, language),
                        n(total, language),
                      ),
                      style: context.type.ui(
                        size: 13.5,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeTile extends ConsumerWidget {
  const _PracticeTile({required this.language});
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final quiz = ref.watch(studyProvider.select((s) => s.quiz));
    final dark = context.isDark;
    final pool = content.questions;
    if (pool.isEmpty) return const SizedBox.shrink();
    final answered = pool.where((q) => quiz.containsKey(q.id)).length;
    final correct = pool.where((q) => quiz[q.id]?.lastCorrect ?? false).length;
    final mistakes = mistakeCount(pool, quiz);
    final gold = dark ? RattilColors.goldLight : RattilColors.goldText;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => openQuiz(context),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.practiceTitle, style: context.type.muted(size: 13)),
                  const SizedBox(height: 10),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (dark ? RattilColors.goldLight : RattilColors.gold)
                          .withValues(alpha: 0.16),
                    ),
                    child: Icon(Icons.bolt, size: 32, color: gold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    answered == 0
                        ? l10n.homePracticeTeaser
                        : l10n.homePracticeAccuracy(
                            n((correct * 100 / answered).round(), language),
                          ),
                    style: context.type.ui(size: 13.5, weight: FontWeight.w600),
                  ),
                  if (mistakes > 0)
                    Text(
                      l10n.practiceMistakes(n(mistakes, language)),
                      style: context.type.ui(size: 12.5, color: gold),
                    ),
                  const Spacer(),
                  const SizedBox(height: 6),
                  Text(
                    l10n.practiceQuick,
                    style: context.type.ui(
                      size: 14,
                      weight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitStrip extends StatelessWidget {
  const _UnitStrip({
    required this.content,
    required this.study,
    required this.language,
  });
  final ContentRepository content;
  final StudyState study;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, g) in content.groups.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Builder(
                builder: (context) {
                  final accent = UnitColors.of(i, brightness);
                  final done = g.topicIds
                      .where(
                        (t) => study.progressOf(t) == TopicProgress.completed,
                      )
                      .length;
                  final next = g.topicIds.firstWhere(
                    (t) => study.progressOf(t) != TopicProgress.completed,
                    orElse: () => g.topicIds.first,
                  );
                  return SizedBox(
                    width: 156,
                    child: Material(
                      color: accent.withValues(alpha: dark ? 0.16 : 0.09),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => openTopic(context, next),
                        child: Semantics(
                          button: true,
                          excludeSemantics: true,
                          label:
                              '${l10n.homeUnitLabel(n(i + 1, language))}, '
                              '${g.title.of(language.code)}, '
                              '${l10n.homeLessonsDone(n(done, language), n(g.topicIds.length, language))}',
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.homeUnitLabel(n(i + 1, language)),
                                  style: context.type.ui(
                                    size: 12.5,
                                    weight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  g.title.of(language.code),
                                  style: context.type.ui(
                                    size: 14.5,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: done / g.topicIds.length,
                                    minHeight: 5,
                                    color: accent,
                                    backgroundColor: accent.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${n(done, language)} / ${n(g.topicIds.length, language)}',
                                  style: context.type.muted(size: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

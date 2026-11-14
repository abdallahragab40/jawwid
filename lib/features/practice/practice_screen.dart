import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';
import 'session.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  int _limit = quizSessionSize;
  bool _allTopics = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final lang = ref.watch(languageProvider);
    final quiz = ref.watch(studyProvider.select((s) => s.quiz));
    final saved = ref.watch(studyProvider.select((s) => s.savedSession));
    final resumable = saved != null && saved.canResume(content);
    final questions = content.questions;
    final answered = questions.where((q) => quiz.containsKey(q.id)).length;
    final correct = questions
        .where((q) => quiz[q.id]?.lastCorrect ?? false)
        .length;
    final mistakes = mistakeCount(questions, quiz);
    final delayed = questions
        .where((q) => (quiz[q.id]?.reviewStage ?? 0) >= 2)
        .length;
    final topicIds = <String>{for (final q in questions) q.topicId}.toList()
      ..sort(
        (a, b) => content.topic(a).order.compareTo(content.topic(b).order),
      );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.practiceTitle)),
      body: questions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.practiceAwaitingReview,
                      style: context.type.ui(size: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => openBook(context),
                      child: Text(l10n.bookTitle),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                if (resumable)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.play_arrow),
                      title: Text(l10n.practiceResume),
                      subtitle: Text(
                        l10n.quizProgress(
                          n(saved.index + 1, lang),
                          n(saved.questionIds.length, lang),
                        ),
                      ),
                      onTap: () => openQuiz(context, resume: true),
                      trailing: IconButton(
                        tooltip: l10n.actionDelete,
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            ref.read(studyProvider.notifier).saveSession(null),
                      ),
                    ),
                  ),
                Text(l10n.practiceIntro, style: context.type.muted(size: 14)),
                if (content.isPreview) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PreviewBadge(l10n.previewBadge),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.practiceOverall,
                          style: context.type.heading(size: 18),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          answered == 0
                              ? l10n.practiceNotTried(n(questions.length, lang))
                              : l10n.practicePerformance(
                                  n(correct, lang),
                                  n(answered, lang),
                                  n(questions.length, lang),
                                ),
                          style: context.type.ui(size: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.practiceSeparateFromReading,
                          style: context.type.muted(size: 12.5),
                        ),
                        if (delayed > 0)
                          Text(
                            l10n.practiceDelayedReview(n(delayed, lang)),
                            style: context.type.muted(size: 13),
                          ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.practiceAllTopics),
                          value: _allTopics,
                          onChanged: (value) =>
                              setState(() => _allTopics = value),
                        ),
                        Text(l10n.practiceLength),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final count in [3, 5, 10])
                              ChoiceChip(
                                label: Text(n(count, lang)),
                                selected: _limit == count,
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                checkmarkColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                labelStyle: context.type.ui(
                                  size: 13,
                                  color: _limit == count
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                onSelected: (_) =>
                                    setState(() => _limit = count),
                              ),
                          ],
                        ),
                        if (questions.any(
                          (q) =>
                              quiz[q.id]?.isDue(ref.read(clockProvider)()) ??
                              false,
                        ))
                          OutlinedButton.icon(
                            icon: const Icon(Icons.schedule),
                            label: Text(l10n.practiceDue),
                            onPressed: () =>
                                openQuiz(context, dueOnly: true, limit: _limit),
                          ),
                        FilledButton.icon(
                          icon: const Icon(Icons.bolt),
                          label: Text(l10n.practiceQuick),
                          onPressed: () => openQuiz(
                            context,
                            limit: _limit,
                            learnedOnly: !_allTopics,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.practiceQuickHint(n(_limit, lang)),
                          style: context.type.muted(size: 12.5),
                          textAlign: TextAlign.center,
                        ),
                        if (mistakes > 0) ...[
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.history),
                            label: Text(
                              l10n.practiceMistakes(n(mistakes, lang)),
                            ),
                            onPressed: () =>
                                openQuiz(context, mistakesOnly: true),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SectionHeading(l10n.practiceByLesson),
                Card(
                  child: Column(
                    children: [
                      for (final (i, id) in topicIds.indexed) ...[
                        if (i > 0) const Divider(indent: 16),
                        Consumer(
                          builder: (context, ref, _) {
                            final perf = ref.watch(
                              topicPerformanceProvider(id),
                            );
                            final value = perf.total == 0
                                ? 0.0
                                : perf.correctLatest / perf.total;
                            return ListTile(
                              title: Text(topicTitle(content.topic(id), lang)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: value,
                                        minHeight: 6,
                                        backgroundColor: context.isDark
                                            ? RattilColors.nightLine
                                            : RattilColors.emerald50,
                                        semanticsLabel: l10n
                                            .practicePerformance(
                                              n(perf.correctLatest, lang),
                                              n(perf.answered, lang),
                                              n(perf.total, lang),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.practicePerformance(
                                        n(perf.correctLatest, lang),
                                        n(perf.answered, lang),
                                        n(perf.total, lang),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                textDirection: Directionality.of(context),
                              ),
                              onTap: () => openQuiz(context, topicId: id),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                if (answered > 0) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.restart_alt),
                      label: Text(l10n.practiceReset),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.practiceReset),
                            content: Text(l10n.practiceResetConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(l10n.actionCancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(l10n.practiceReset),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          ref.read(studyProvider.notifier).resetPractice();
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../content/models.dart';
import '../../core/numerals.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../../widgets/quran_excerpt_view.dart';
import '../study/study_state.dart';
import '../../core/haptics.dart';

/// A practice session over the visible questions (optionally one lesson or
/// one rule). Unanswered and previously missed questions come first.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, this.topicId, this.ruleId});
  final String? topicId;
  final String? ruleId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late final List<Question> _questions;
  int _index = 0;
  int _correct = 0;
  Object? _choice; // String rule id, int index, or bool
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    final content = ref.read(contentProvider);
    final quiz = ref.read(studyProvider).quiz;
    var qs = content.questions;
    if (widget.topicId != null) {
      qs = [
        for (final q in qs)
          if (q.topicId == widget.topicId) q,
      ];
    }
    if (widget.ruleId != null) {
      qs = [
        for (final q in qs)
          if (q.relatedRuleId == widget.ruleId) q,
      ];
    }
    int rank(Question q) {
      final r = quiz[q.id];
      if (r == null) return 0;
      return r.lastCorrect ? 2 : 1;
    }

    _questions = [...qs]
      ..sort((a, b) {
        final c = rank(a).compareTo(rank(b));
        return c != 0 ? c : a.id.compareTo(b.id);
      });
  }

  bool _isCorrect(Question q, Object? choice) => switch (q.type) {
    QuestionType.identify => choice == q.answerRuleId,
    QuestionType.choice => choice == q.answerIndex,
    QuestionType.trueFalse => choice == q.answerBool,
  };

  void _answer(Object choice) {
    if (_answered) return;
    final q = _questions[_index];
    final ok = _isCorrect(q, choice);
    setState(() {
      _choice = choice;
      _answered = true;
      if (ok) _correct++;
    });
    ref.read(studyProvider.notifier).recordAnswer(q.id, ok);
    final h = ref.read(hapticsProvider);
    ok ? h.success() : h.wrong();
  }

  void _next() => setState(() {
    _index++;
    _choice = null;
    _answered = false;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.practiceTitle)),
        body: Center(child: Text(l10n.practiceAwaitingReview)),
      );
    }
    if (_index >= _questions.length) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.practiceTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Rosette(size: 44),
                const SizedBox(height: 16),
                Text(l10n.quizFinished, style: context.type.heading(size: 22)),
                const SizedBox(height: 8),
                Text(
                  l10n.quizScore(n(_correct, lang), n(_questions.length, lang)),
                  style: context.type.ui(size: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.quizFinishedHint,
                  style: context.type.muted(size: 13.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.actionDone),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final dark = context.isDark;
    final ok = _answered && _isCorrect(q, _choice);

    Widget option({
      required Object value,
      required Widget child,
      required String semantics,
    }) {
      final selected = _choice == value;
      final isAnswer = _answered && _isCorrect(q, value);
      final wrongPick = _answered && selected && !isAnswer;
      final border = isAnswer
          ? LessonColors.correct
          : wrongPick
          ? LessonColors.incorrect
          : (dark ? RattilColors.nightLine : RattilColors.line);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Semantics(
          button: true,
          selected: selected,
          label: semantics,
          value: isAnswer
              ? l10n.quizCorrectAnswer
              : (wrongPick ? l10n.quizYourAnswer : null),
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _answered ? null : () => _answer(value),
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: dark ? RattilColors.nightRaised : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: border,
                  width: isAnswer || wrongPick ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: child),
                  if (isAnswer)
                    const Icon(Icons.check_circle, color: LessonColors.correct),
                  if (wrongPick)
                    const Icon(Icons.cancel, color: LessonColors.incorrect),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final options = <Widget>[];
    switch (q.type) {
      case QuestionType.identify:
        for (final id in q.ruleOptions) {
          final r = content.rule(id);
          if (r == null) continue;
          final title = r.title.of(lang.code);
          options.add(
            option(
              value: id,
              semantics: title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.type.ui(size: 15.5, weight: FontWeight.w600),
                  ),
                  if (lang != AppLanguage.ar)
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        r.title.of('ar'),
                        style: context.type.arabicTerm(size: 14),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      case QuestionType.choice:
        for (final (i, c) in q.choices.indexed) {
          final String text;
          final bool arabic;
          if (c.arabic != null) {
            text = c.arabic!;
            arabic = true;
          } else if (c.counts != null) {
            text = l10n.quizCounts(localizeDigits(c.counts!, lang.code));
            arabic = false;
          } else {
            text = localizeDigits(c.number!, lang.code);
            arabic = false;
          }
          options.add(
            option(
              value: i,
              semantics: text,
              child: arabic
                  ? Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        text,
                        style: context.type.arabicTerm(
                          size: 19,
                          weight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: context.type.ui(size: 16, weight: FontWeight.w600),
                    ),
            ),
          );
        }
      case QuestionType.trueFalse:
        options.add(
          option(
            value: true,
            semantics: l10n.quizTrue,
            child: Text(
              l10n.quizTrue,
              style: context.type.ui(size: 16, weight: FontWeight.w600),
            ),
          ),
        );
        options.add(
          option(
            value: false,
            semantics: l10n.quizFalse,
            child: Text(
              l10n.quizFalse,
              style: context.type.ui(size: 16, weight: FontWeight.w600),
            ),
          ),
        );
    }

    final related = q.relatedRuleId == null
        ? null
        : content.rule(q.relatedRuleId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.quizProgress(n(_index + 1, lang), n(_questions.length, lang)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + (_answered ? 1 : 0)) / _questions.length,
            minHeight: 3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          if (content.isPreview && q.review == ReviewStatus.draft) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                PreviewBadge(l10n.previewBadge),
                Text(
                  l10n.quizSupplementary,
                  style: context.type.muted(size: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            Text(l10n.quizSupplementary, style: context.type.muted(size: 12)),
            const SizedBox(height: 12),
          ],
          Text(switch (q.type) {
            QuestionType.identify => l10n.quizIdentifyPrompt,
            QuestionType.trueFalse => l10n.quizTrueFalsePrompt,
            QuestionType.choice => q.prompt!.of(lang.code),
          }, style: context.type.heading(size: 20)),
          if (q.type == QuestionType.trueFalse) ...[
            const SizedBox(height: 8),
            Text(q.prompt!.of(lang.code), style: context.type.prose(size: 17)),
          ],
          if (q.example != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                child: QuranExcerptView(excerpt: q.example!, size: 34),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...options,
          if (_answered) ...[
            const SizedBox(height: 4),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ok
                      ? LessonColors.correct.withValues(alpha: 0.08)
                      : LessonColors.incorrect.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          ok ? Icons.check_circle : Icons.info,
                          color: ok
                              ? LessonColors.correct
                              : LessonColors.incorrect,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ok
                              ? l10n.quizFeedbackCorrect
                              : l10n.quizFeedbackIncorrect,
                          style: context.type.ui(
                            size: 16,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      q.explanation.of(lang.code),
                      style: context.type.prose(size: 15.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (related != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.style_outlined),
                    label: Text(l10n.quizReviewRule),
                    onPressed: () => openRule(context, related.id),
                  ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.school_outlined),
                  label: Text(l10n.quizOpenLesson),
                  onPressed: () => openTopic(context, q.topicId),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _next,
              child: Text(
                _index + 1 < _questions.length
                    ? l10n.quizNext
                    : l10n.quizSeeResult,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

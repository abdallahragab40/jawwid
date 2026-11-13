import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/language.dart';
import '../../content/models.dart';
import '../../core/numerals.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../../widgets/quran_excerpt_view.dart';
import '../study/study_state.dart';
import '../../core/haptics.dart';
import 'session.dart';

/// Source of randomness for option order; overridden in tests.
final quizRandomProvider = Provider<Random>((_) => Random());

/// A short practice session (see [buildSession]) over the visible questions,
/// optionally of one lesson or one rule, or only the questions missed last
/// time. The options of each question are shown in a random order, so the
/// position of the right answer gives nothing away.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    this.topicId,
    this.ruleId,
    this.mistakesOnly = false,
  });
  final String? topicId;
  final String? ruleId;
  final bool mistakesOnly;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late final List<Question> _questions;

  /// Display order of each question's options (indices into its options).
  late final List<List<int>> _order;
  int _index = 0;
  int _correct = 0;
  final _missed = <Question>[];

  /// The question on screen, or null on the result page.
  @visibleForTesting
  Question? get currentQuestion =>
      _index < _questions.length ? _questions[_index] : null;
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
    final random = ref.read(quizRandomProvider);
    _questions = buildSession(
      qs,
      quiz,
      random,
      mistakesOnly: widget.mistakesOnly,
    );
    _order = [
      for (final q in _questions)
        List<int>.generate(switch (q.type) {
          QuestionType.identify => q.ruleOptions.length,
          QuestionType.choice => q.choices.length,
          QuestionType.trueFalse => 0,
        }, (i) => i)..shuffle(random),
    ];
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
      if (ok) {
        _correct++;
      } else {
        _missed.add(q);
      }
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
      return _SessionEnd(
        correct: _correct,
        total: _questions.length,
        missed: _missed,
        onAgain: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'quiz'),
            builder: (_) => QuizScreen(
              topicId: widget.topicId,
              ruleId: widget.ruleId,
              mistakesOnly: widget.mistakesOnly,
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final dark = context.isDark;
    final brightness = Theme.of(context).brightness;
    final correctColor = LessonColors.correctFor(brightness);
    final incorrectColor = LessonColors.incorrectFor(brightness);
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
          ? correctColor
          : wrongPick
          ? incorrectColor
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
                  if (isAnswer) Icon(Icons.check_circle, color: correctColor),
                  if (wrongPick) Icon(Icons.cancel, color: incorrectColor),
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
        for (final i in _order[_index]) {
          final id = q.ruleOptions[i];
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
        for (final i in _order[_index]) {
          final c = q.choices[i];
          final String text;
          final bool arabic;
          if (c.text != null) {
            text = c.text!.of(lang.code);
            arabic = false;
          } else if (c.arabic != null) {
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
                      ? correctColor.withValues(alpha: dark ? 0.14 : 0.08)
                      : incorrectColor.withValues(alpha: dark ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          ok ? Icons.check_circle : Icons.info,
                          color: ok ? correctColor : incorrectColor,
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

/// The correct answer of [q], as shown to the learner.
String answerLabel(
  Question q,
  ContentRepository content,
  AppLanguage lang,
  AppLocalizations l10n,
) {
  switch (q.type) {
    case QuestionType.identify:
      return content.rule(q.answerRuleId!)?.title.of(lang.code) ?? '';
    case QuestionType.trueFalse:
      return q.answerBool! ? l10n.quizTrue : l10n.quizFalse;
    case QuestionType.choice:
      final c = q.choices[q.answerIndex!];
      if (c.text != null) return c.text!.of(lang.code);
      if (c.arabic != null) return c.arabic!;
      if (c.counts != null) {
        return l10n.quizCounts(localizeDigits(c.counts!, lang.code));
      }
      return localizeDigits(c.number!, lang.code);
  }
}

class _SessionEnd extends ConsumerWidget {
  const _SessionEnd({
    required this.correct,
    required this.total,
    required this.missed,
    required this.onAgain,
  });
  final int correct;
  final int total;
  final List<Question> missed;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);
    final dark = context.isDark;
    final scheme = Theme.of(context).colorScheme;
    final ratio = total == 0 ? 0.0 : correct / total;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.practiceTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => SizedBox(
                width: 132,
                height: 132,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: v,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: dark
                            ? RattilColors.nightLine
                            : RattilColors.emerald50,
                        color: dark
                            ? RattilColors.emeraldLight
                            : RattilColors.emerald700,
                      ),
                    ),
                    Text(
                      '${n(correct, lang)}/${n(total, lang)}',
                      style: context.type.heading(size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            missed.isEmpty ? l10n.quizPerfect : l10n.quizFinished,
            style: context.type.heading(size: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.quizScore(n(correct, lang), n(total, lang)),
            style: context.type.ui(size: 16),
            textAlign: TextAlign.center,
          ),
          if (missed.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.quizFinishedHint,
              style: context.type.muted(size: 13.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SectionHeading(l10n.quizMissedHeading),
            for (final q in missed) ...[
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => openTopic(context, q.topicId),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (q.example != null)
                          QuranExcerptView(excerpt: q.example!, size: 24)
                        else if (q.prompt != null)
                          Text(
                            q.prompt!.of(lang.code),
                            style: context.type.ui(size: 14.5),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: LessonColors.correctFor(
                                Theme.of(context).brightness,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                answerLabel(q, content, lang, l10n),
                                style: context.type.ui(
                                  size: 15,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          q.explanation.of(lang.code),
                          style: context.type.muted(size: 13.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            icon: const Icon(Icons.replay),
            label: Text(l10n.quizPracticeAgain),
            onPressed: onAgain,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: scheme.primary),
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionDone),
          ),
        ],
      ),
    );
  }
}

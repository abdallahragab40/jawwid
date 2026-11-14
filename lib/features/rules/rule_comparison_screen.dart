import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../../widgets/quran_excerpt_view.dart';
import '../study/study_state.dart';

/// Compares the existing source-backed cards without authoring new rule claims.
class RuleComparisonScreen extends ConsumerStatefulWidget {
  const RuleComparisonScreen({super.key, this.initialRuleId});
  final String? initialRuleId;
  @override
  ConsumerState<RuleComparisonScreen> createState() =>
      _RuleComparisonScreenState();
}

class _RuleComparisonScreenState extends ConsumerState<RuleComparisonScreen> {
  String? _first;
  String? _second;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final lang = ref.watch(languageProvider);
    final rules = content.rules;
    if (rules.length < 2) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.ruleCompare)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.ruleCompareUnavailable),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => openBook(context),
                  child: Text(l10n.bookTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final first = rules.firstWhere(
      (r) => r.id == (_first ?? widget.initialRuleId),
      orElse: () => rules.first,
    );
    final second = rules.firstWhere(
      (r) => r.id == _second && r.id != first.id,
      orElse: () => rules.firstWhere(
        (r) => r.id != first.id && r.topicId == first.topicId,
        orElse: () => rules.firstWhere((r) => r.id != first.id),
      ),
    );

    Widget panel(RuleCard rule, bool left) {
      final definition = rule.definition[lang.editionId];
      final hasPractice = content.questions.any(
        (q) => q.relatedRuleId == rule.id,
      );
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey('${left ? 'first' : 'second'}:${rule.id}'),
                initialValue: rule.id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: left
                      ? l10n.ruleCompareFirst
                      : l10n.ruleCompareSecond,
                ),
                items: [
                  for (final r in rules.where((r) => left || r.id != first.id))
                    DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        r.title.of(lang.code),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) => setState(() {
                  if (left) {
                    _first = id;
                  } else {
                    _second = id;
                  }
                }),
              ),
              const SizedBox(height: 18),
              Text(
                rule.title.of(lang.code),
                style: context.type.heading(size: 22),
              ),
              const SizedBox(height: 12),
              LabelTag(l10n.ruleDefinition),
              const SizedBox(height: 8),
              Text(
                definition?.text ??
                    l10n.ruleNotInEdition(editionName(l10n, lang.editionId)),
                style: context.type.prose(size: 16),
              ),
              if (definition?.page != null &&
                  definition!.status != TextStatus.authored)
                TextButton(
                  onPressed: () => openReader(
                    context,
                    edition: lang.editionId,
                    page: definition.page!,
                  ),
                  child: Text(
                    l10n.ruleSourceLine(
                      editionName(l10n, lang.editionId),
                      n(definition.page!, lang),
                    ),
                  ),
                ),
              if (rule.letters != null || rule.lettersExcept != null) ...[
                const SizedBox(height: 12),
                LabelTag(l10n.ruleLetters),
                if (rule.lettersExcept != null) Text(l10n.ruleAllLettersExcept),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    rule.letters ?? rule.lettersExcept!,
                    style: context.type.arabicTerm(size: 23),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              LabelTag(l10n.ruleExample),
              const SizedBox(height: 8),
              QuranExcerptView(excerpt: rule.example, size: 28),
              const SizedBox(height: 8),
              Text(
                rule.explanation.of(lang.code),
                style: context.type.prose(size: 15),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => openRule(context, rule.id),
                child: Text(l10n.ruleCardTitle),
              ),
              if (hasPractice)
                FilledButton(
                  onPressed: () => openQuiz(context, ruleId: rule.id, limit: 3),
                  child: Text(l10n.rulePractice),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ruleCompare)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (content.isPreview) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: PreviewBadge(l10n.previewBadge),
            ),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >= 760 &&
                  MediaQuery.textScalerOf(context).scale(16) <= 24;
              if (!wide) {
                return Column(
                  children: [
                    panel(first, true),
                    const SizedBox(height: 12),
                    panel(second, false),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: panel(first, true)),
                  const SizedBox(width: 16),
                  Expanded(child: panel(second, false)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../../widgets/quran_excerpt_view.dart';
import '../study/study_state.dart';

class RuleCardScreen extends ConsumerWidget {
  const RuleCardScreen({super.key, required this.ruleId});
  final String ruleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final lang = ref.watch(languageProvider);
    final rule = content.rule(ruleId);
    if (rule == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.rulesAwaitingReview)),
      );
    }
    final topic = content.topic(rule.topicId);
    final ed = lang.editionId;
    final def = rule.definition[ed];
    final isSourceText =
        def != null && def.status != TextStatus.authored && def.page != null;
    final arDef = rule.definition['ar'];
    final questions = [
      for (final q in content.questions)
        if (q.relatedRuleId == rule.id) q,
    ];
    final dark = context.isDark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ruleCardTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (content.isPreview && rule.review == ReviewStatus.draft) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: PreviewBadge(l10n.previewBadge),
            ),
            const SizedBox(height: 8),
          ],
          Semantics(
            header: true,
            child: Text(
              rule.title.of(lang.code),
              style: context.type.heading(size: 26),
            ),
          ),
          if (lang != AppLanguage.ar)
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                rule.title.of('ar'),
                style: context.type.arabicTerm(
                  size: 19,
                  color: dark ? RattilColors.nightMuted : RattilColors.inkMuted,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Semantics(
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => openTopic(context, topic.id),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: Text(
                    l10n.ruleFromLesson(topicTitle(topic, lang)),
                    style: context.type.ui(
                      size: 13.5,
                      color: dark
                          ? RattilColors.emeraldLight
                          : RattilColors.emerald700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const OrnamentDivider(),

          // Definition.
          LabelTag(l10n.ruleDefinition, emphasis: true),
          const SizedBox(height: 8),
          if (def != null)
            Text(def.text, style: context.type.prose(size: 16.5)),
          if (def != null && isSourceText)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.ruleSourceLine(editionName(l10n, ed), n(def.page!, lang)),
                style: context.type.muted(size: 12.5),
              ),
            ),
          if (def == null || def.status == TextStatus.authored) ...[
            const SizedBox(height: 8),
            _SoftNote(text: l10n.ruleNotInEdition(editionName(l10n, ed))),
            if (arDef != null && lang != AppLanguage.ar) ...[
              const SizedBox(height: 10),
              Text(
                l10n.ruleArabicSource,
                style: context.type.ui(size: 13, weight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  arDef.text,
                  style: context.type.arabicTerm(
                    size: 17,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                l10n.ruleSourceLine(
                  editionName(l10n, 'ar'),
                  n(arDef.page!, lang),
                ),
                style: context.type.muted(size: 12.5),
              ),
            ],
          ],
          const SizedBox(height: 18),

          // Letters.
          if (rule.letters != null || rule.lettersExcept != null) ...[
            LabelTag(l10n.ruleLetters, emphasis: true),
            const SizedBox(height: 8),
            if (rule.lettersExcept != null)
              Text(l10n.ruleAllLettersExcept, style: context.type.ui(size: 14)),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final letter
                      in (rule.letters ?? rule.lettersExcept!).split(' '))
                    Container(
                      // No `alignment`: it would make the chip fill the row.
                      constraints: const BoxConstraints(minWidth: 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: dark ? RattilColors.nightRaised : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dark
                              ? RattilColors.nightLine
                              : RattilColors.goldSoft,
                        ),
                      ),
                      child: Text(
                        letter,
                        textAlign: TextAlign.center,
                        style: context.type.arabicTerm(
                          size: 22,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Example.
          LabelTag(l10n.ruleExample, emphasis: true),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QuranExcerptView(excerpt: rule.example, size: 32),
                  const SizedBox(height: 10),
                  Text(
                    l10n.ruleHighlightedLetters,
                    style: context.type.ui(size: 13, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rule.explanation.of(lang.code),
                    style: context.type.prose(size: 15.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Source pages.
          LabelTag(l10n.ruleInTheBooks),
          const SizedBox(height: 6),
          for (final e in [
            ed,
            ...const ['ar', 'ckb', 'en', 'id'].where((x) => x != ed),
          ])
            if (rule.definition[e] != null && rule.definition[e]!.page != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  e == ed ? Icons.menu_book : Icons.menu_book_outlined,
                ),
                title: Text(editionName(l10n, e)),
                subtitle: Text(
                  l10n.pageLabel(n(rule.definition[e]!.page!, lang)),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  textDirection: Directionality.of(context),
                ),
                onTap: () => openReader(
                  context,
                  edition: e,
                  page: rule.definition[e]!.page!,
                ),
              ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.school_outlined),
                  label: Text(l10n.ruleOpenLesson),
                  onPressed: () => openTopic(context, topic.id),
                ),
              ),
              if (questions.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.task_alt),
                    label: Text(l10n.rulePractice),
                    onPressed: () => openQuiz(context, ruleId: rule.id),
                  ),
                ),
              ],
            ],
          ),
          if (content.isPreview) ...[
            const SizedBox(height: 18),
            Text(l10n.previewExplanation, style: context.type.muted(size: 12)),
          ],
        ],
      ),
    );
  }
}

class _SoftNote extends StatelessWidget {
  const _SoftNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.isDark ? const Color(0xFF1D2A26) : RattilColors.emerald50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 18,
          color: context.isDark
              ? RattilColors.emeraldLight
              : RattilColors.emerald700,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: context.type.ui(size: 13.5))),
      ],
    ),
  );
}

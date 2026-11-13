import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/models.dart';
import '../../core/numerals.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../../widgets/quran_excerpt_view.dart';
import '../study/study_state.dart';
import '../../widgets/text_size_control.dart';
import '../../core/haptics.dart';

/// Unicode isolates keep Arabic runs intact inside left-to-right paragraphs
/// (and LTR runs intact inside RTL ones).
const _rli = '\u2067', _pdi = '\u2069';

const Map<String, String> lessonImages = {
  'makharij': 'assets/images/makharij_sagittal.png',
};

/// The full text of one topic, as native sections. Each section shows the
/// book page it comes from and links back to it; the PDF stays the reference.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.topicId, this.scrollToBlock});
  final String topicId;

  /// Block index to bring into view (from search).
  final int? scrollToBlock;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final _keys = <int, GlobalKey>{};
  final _scroll = ScrollController();
  final _progress = ValueNotifier<double>(0);

  /// Index into [_sections] of the section at the top of the screen.
  final _section = ValueNotifier<int>(0);
  List<(int, LessonBlock)> _sections = const [];

  void _onScroll() {
    final p = _scroll.position;
    _progress.value = p.maxScrollExtent <= 0
        ? 1
        : (p.pixels / p.maxScrollExtent).clamp(0, 1);
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight + 48;
    var current = 0;
    for (final (i, (block, _)) in _sections.indexed) {
      final box = _keys[block]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= top) {
        current = i;
      } else {
        break;
      }
    }
    if (p.pixels >= p.maxScrollExtent - 4 && _sections.isNotEmpty) {
      current = _sections.length - 1;
    }
    _section.value = current;
  }

  void _jumpToBlock(int block) {
    final ctx = _keys[block]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.02,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _progress.dispose();
    _section.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyProvider.notifier).recordLessonOpened(widget.topicId);
      final target = widget.scrollToBlock;
      final ctx = target == null ? null : _keys[target]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.15,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);
    final topic = content.topic(widget.topicId);
    final ed = lang.editionId;
    final lesson = content.lesson(widget.topicId, lang.code);
    final textScale = ref.watch(studyProvider.select((s) => s.lessonTextScale));
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.rulesAwaitingReview)),
      );
    }
    final group = content.groupOf(topic);
    final unitIndex = content.groups.indexOf(group);
    final accent = UnitColors.of(unitIndex, Theme.of(context).brightness);
    final draft = content.isPreview && lesson.review == ReviewStatus.draft;
    final children = <Widget>[
      // One compact line: the unit, plus a tap target for the source notes.
      Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(
                      alpha: context.isDark ? 0.18 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${l10n.homeUnitLabel(n(unitIndex + 1, lang))} · ${group.title.of(lang.code)}',
                    style: context.type.ui(
                      size: 12.5,
                      weight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
                if (draft) PreviewBadge(l10n.previewBadge),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.lessonSourceInfo,
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => _showSourceInfo(
              l10n.lessonSourceNote(editionName(l10n, ed)),
              draft ? l10n.lessonUnderReview : null,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
    ];
    int? lastPage;
    for (final (i, b) in lesson.blocks.indexed) {
      if (b.page != lastPage) {
        children.add(_PageMarker(edition: ed, page: b.page));
        lastPage = b.page;
      }
      children.add(
        KeyedSubtree(
          key: _keys.putIfAbsent(i, GlobalKey.new),
          child: LessonBlockView(block: b),
        ),
      );
    }
    children.add(_LessonEnd(topicId: widget.topicId));
    final range = topic.pagesIn(ed);
    final sections = [
      for (final (i, b) in lesson.blocks.indexed)
        if (b.type == LessonBlockType.h1 || b.type == LessonBlockType.h2)
          (i, b),
    ];
    _sections = sections;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          topicTitle(topic, lang),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 3,
              color: accent,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.settingsTextSize,
            icon: const Icon(Icons.text_fields),
            onPressed: _showTextSize,
          ),
          if (sections.length > 1)
            IconButton(
              tooltip: l10n.lessonContents,
              icon: const Icon(Icons.toc),
              onPressed: () => _showContents(sections),
            ),
          if (range != null)
            IconButton(
              tooltip: l10n.lessonOriginalPages,
              icon: const Icon(Icons.auto_stories_outlined),
              onPressed: () =>
                  openReader(context, edition: ed, page: range.start),
            ),
        ],
      ),
      bottomNavigationBar: sections.length < 3
          ? null
          : _SectionBar(
              sections: sections,
              current: _section,
              onJump: _jumpToBlock,
              onContents: () => _showContents(sections),
            ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: _scaled(MediaQuery.textScalerOf(context), textScale),
        ),
        child: Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

TextScaler _scaled(TextScaler base, double factor) =>
    factor == 1 ? base : TextScaler.linear(base.scale(1) * factor);

extension on _LessonScreenState {
  void _showSourceInfo(String note, String? review) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(note, style: context.type.ui(size: 15)),
              if (review != null) ...[
                const SizedBox(height: 10),
                Text(review, style: context.type.muted(size: 13.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTextSize() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Consumer(
            builder: (context, ref, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settingsTextSize,
                  style: context.type.heading(size: 18),
                ),
                LessonTextSizeControl(
                  value: ref.watch(
                    studyProvider.select((s) => s.lessonTextScale),
                  ),
                  onChanged: ref
                      .read(studyProvider.notifier)
                      .setLessonTextScale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContents(List<(int, LessonBlock)> sections) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.lessonContents,
                style: context.type.heading(size: 19),
              ),
            ),
            for (final (i, b) in sections)
              ListTile(
                contentPadding: EdgeInsetsDirectional.only(
                  start: b.type == LessonBlockType.h1 ? 20 : 36,
                  end: 20,
                ),
                title: Text(
                  _isolated(b.plain),
                  style: b.type == LessonBlockType.h1
                      ? context.type.ui(size: 15, weight: FontWeight.w600)
                      : context.type.ui(size: 14),
                ),
                onTap: () {
                  Navigator.of(sheet).pop();
                  final ctx = _keys[i]?.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      alignment: 0.05,
                      duration: const Duration(milliseconds: 300),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Wraps Arabic-script runs so headings that mix scripts keep their order.
String _isolated(String text) => text.replaceAllMapped(
  RegExp(
    // An enclosing "( … )" goes inside the isolate with the Arabic run.
    r'\(?[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s،–-]*'
    r'\)?',
  ),
  (m) => '$_rli${m[0]}$_pdi',
);

/// End of a lesson: completion, practice, and moving to the neighbouring
/// lessons of the same edition.
class _LessonEnd extends ConsumerWidget {
  const _LessonEnd({required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);
    final progress = ref.watch(
      studyProvider.select((s) => s.progressOf(topicId)),
    );
    final withLesson = [
      for (final t in content.topics)
        if (content.lesson(t.id, lang.code) != null) t,
    ];
    final at = withLesson.indexWhere((t) => t.id == topicId);
    final prev = at > 0 ? withLesson[at - 1] : null;
    final next = at >= 0 && at < withLesson.length - 1
        ? withLesson[at + 1]
        : null;
    final hasPractice = content.questionsForTopic(topicId).isNotEmpty;
    final rules = content.rulesForTopic(topicId);
    final topic = content.topic(topicId);
    final ed = lang.editionId;
    final others = [
      for (final e in const ['ar', 'ckb', 'en', 'id'])
        if (e != ed && topic.isAvailableIn(e)) e,
    ];
    Widget chevron() =>
        Icon(Icons.chevron_right, textDirection: Directionality.of(context));
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OrnamentDivider(),
          const SizedBox(height: 8),
          Text(
            l10n.lessonEnd,
            textAlign: TextAlign.center,
            style: context.type.heading(size: 19),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: progress == TopicProgress.completed,
              onChanged: (v) {
                ref.read(hapticsProvider).toggle();
                ref.read(studyProvider.notifier).setTopicCompleted(topicId, v);
              },
              title: Text(l10n.topicMarkCompleted),
            ),
          ),
          if (hasPractice) ...[
            const SizedBox(height: 10),
            _LessonCheckCard(
              count: content
                  .questionsForTopic(topicId)
                  .length
                  .clamp(1, lessonCheckSize),
              onStart: () =>
                  openQuiz(context, topicId: topicId, limit: lessonCheckSize),
            ),
          ],
          if (rules.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionHeading(l10n.topicRelatedRules),
            Card(
              child: Column(
                children: [
                  for (final (i, r) in rules.indexed) ...[
                    if (i > 0) const Divider(indent: 16),
                    ListTile(
                      title: Text(r.title.of(lang.code)),
                      trailing: chevron(),
                      onTap: () => openRule(context, r.id),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (others.isNotEmpty) ...[
            const SizedBox(height: 8),
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
                    trailing: chevron(),
                    onTap: () => openReader(
                      context,
                      edition: e,
                      page: topic.pagesIn(e)!.start,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (next != null)
            FilledButton(
              onPressed: () => replaceLesson(context, next.id),
              child: _NavLabel(l10n.lessonNext, topicTitle(next, lang)),
            ),
          if (prev != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => replaceLesson(context, prev.id),
              child: _NavLabel(l10n.lessonPrevious, topicTitle(prev, lang)),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel(this.label, this.title);
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5)),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _PageMarker extends ConsumerWidget {
  const _PageMarker({required this.edition, required this.page});
  final String edition;
  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final dark = context.isDark;
    final line = dark ? RattilColors.nightLine : RattilColors.goldSoft;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Row(
        children: [
          Expanded(child: Divider(color: line)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.lessonFromPage(n(page, lang)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.muted(size: 12),
            ),
          ),
          Flexible(
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: () =>
                  openReader(context, edition: edition, page: page),
              child: Text(
                l10n.lessonViewInBook,
                textAlign: TextAlign.end,
                style: context.type.ui(
                  size: 12.5,
                  weight: FontWeight.w600,
                  color: dark
                      ? RattilColors.emeraldLight
                      : RattilColors.emerald700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonBlockView extends StatelessWidget {
  const LessonBlockView({super.key, required this.block});
  final LessonBlock block;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final emphasis = dark ? const Color(0xFFF2A39C) : RattilColors.emphasis;
    switch (block.type) {
      case LessonBlockType.h1:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1C2A25) : RattilColors.emerald50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark ? RattilColors.nightLine : RattilColors.goldSoft,
              ),
            ),
            child: Row(
              children: [
                const Rosette(size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: LessonText(
                      block.spans,
                      style: context.type.heading(size: 21),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Rosette(size: 22),
              ],
            ),
          ),
        );
      case LessonBlockType.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Rosette(size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: LessonText(
                    block.spans,
                    style: context.type.heading(size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      case LessonBlockType.h3:
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: LabelTag(block.spans.map((s) => s.plain).join()),
        );
      case LessonBlockType.p:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: LessonText(block.spans),
        );
      case LessonBlockType.li:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: emphasis,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: LessonText(block.spans)),
            ],
          ),
        );
      case LessonBlockType.ol:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(minWidth: 26),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: dark
                        ? RattilColors.nightLine
                        : RattilColors.goldSoft,
                  ),
                ),
                child: Text(
                  localizeDigits(
                    block.number ?? '',
                    Localizations.localeOf(context).languageCode,
                  ),
                  textAlign: TextAlign.center,
                  style: context.type.ui(size: 13, weight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: LessonText(block.spans)),
            ],
          ),
        );
      case LessonBlockType.note:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1D2A26) : RattilColors.goldFaint,
            borderRadius: BorderRadius.circular(12),
            border: BorderDirectional(
              start: BorderSide(
                color: dark ? RattilColors.goldLight : RattilColors.gold,
                width: 3,
              ),
            ),
          ),
          child: LessonText(block.spans),
        );
      case LessonBlockType.def:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: LessonText([
            for (final s in block.term) LessonSpan(emphasis: s.plain),
            const LessonSpan(emphasis: ': '),
            ...block.spans,
          ]),
        );
      case LessonBlockType.table:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LessonTable(rows: block.rows),
        );
      case LessonBlockType.crop:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _BookFigure(
            asset: block.asset!,
            aspectRatio: block.aspectRatio ?? 1,
          ),
        );
      case LessonBlockType.img:
        final asset = lessonImages[block.imageKey];
        if (asset == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ColoredBox(
              color: Colors.white,
              // Anatomical illustrations are never mirrored.
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Image.asset(asset),
              ),
            ),
          ),
        );
    }
  }
}

/// An illustration cropped unchanged from the book page. Tap to zoom.
/// Never mirrored, whatever the interface direction.
class _BookFigure extends StatelessWidget {
  const _BookFigure({required this.asset, required this.aspectRatio});
  final String asset;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final image = Directionality(
      textDirection: TextDirection.ltr,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420 * aspectRatio.clamp(0.6, 3.0),
        ),
        child: Semantics(
          button: true,
          label: l10n.lessonFigure,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (ctx) => Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  body: InteractiveViewer(
                    maxScale: 5,
                    child: Center(child: image),
                  ),
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: Colors.white,
                child: AspectRatio(aspectRatio: aspectRatio, child: image),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A native table rebuilt from the book. Scrolls sideways when wider than the
/// screen; follows the reading direction of the interface language.
class LessonTable extends StatelessWidget {
  const LessonTable({super.key, required this.rows});
  final List<List<List<LessonSpan>>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final dark = context.isDark;
    final border = dark ? RattilColors.nightLine : const Color(0xFFCFC6B2);
    final headerBg = dark ? const Color(0xFF22302B) : const Color(0xFFE9E4D4);
    final cols = rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    final headerEmpty = rows.first.every(
      (c) => c.every((s) => s.plain.trim().isEmpty),
    );
    final body = headerEmpty ? rows.skip(1).toList() : rows;
    // A column is "narrow" when every cell is at most a few characters
    // (row numbers, single letters); it is sized to its content.
    bool narrow(int k) => body.every(
      (r) =>
          k >= r.length ||
          r[k].map((s) => s.plain).join().trim().runes.length <= 3,
    );
    Widget cell(List<List<LessonSpan>> r, int k, bool header) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: LessonText(
        k < r.length ? r[k] : const [],
        textAlign: TextAlign.center,
        style: header
            ? context.type.ui(size: 14, weight: FontWeight.w600)
            : context.type.prose(size: 15),
      ),
    );
    List<TableRow> tableRows({required bool fixed}) => [
      for (final (i, r) in body.indexed)
        TableRow(
          decoration: BoxDecoration(
            color: (i == 0 && !headerEmpty)
                ? headerBg
                : (dark ? RattilColors.nightRaised : Colors.white),
          ),
          children: [
            for (var k = 0; k < cols; k++)
              fixed
                  ? cell(r, k, i == 0 && !headerEmpty)
                  : ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 72,
                        maxWidth: 220,
                      ),
                      child: cell(r, k, i == 0 && !headerEmpty),
                    ),
          ],
        ),
    ];
    final tableBorder = TableBorder.all(
      color: border,
      borderRadius: BorderRadius.circular(10),
    );
    Widget table() => _tableOf(context, cols, narrow, tableRows, tableBorder);
    // A table with a header row turns into one card per row when its text
    // columns would be too narrow to read (most tables on a phone).
    final wideCols = [
      for (var k = 0; k < cols; k++)
        if (!narrow(k)) k,
    ].length;
    if (headerEmpty || cols < 3 || body.length < 2) return table();
    return LayoutBuilder(
      builder: (context, c) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final perCol = c.maxWidth / (wideCols == 0 ? 1 : wideCols);
        if (perCol >= 150 * scale) return table();
        return _StackedTable(
          header: body.first,
          rows: body.skip(1).toList(),
          cols: cols,
        );
      },
    );
  }

  Widget _tableOf(
    BuildContext context,
    int cols,
    bool Function(int) narrow,
    List<TableRow> Function({required bool fixed}) tableRows,
    TableBorder tableBorder,
  ) {
    if (cols <= 3) {
      // Fits the screen: text wraps inside the cells.
      return Table(
        columnWidths: {
          for (var k = 0; k < cols; k++)
            k: narrow(k)
                ? const IntrinsicColumnWidth()
                : const FlexColumnWidth(),
        },
        border: tableBorder,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows(fixed: true),
      );
    }
    // Wide example tables scroll sideways in the reading direction.
    return LayoutBuilder(
      builder: (context, c) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: c.maxWidth),
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
              border: tableBorder,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: tableRows(fixed: false),
            ),
          ),
        );
      },
    );
  }
}

/// Rich lesson text. Qur'anic excerpts use Amiri Quran with the lesson's
/// highlight colour and open the full verse when tapped.
class LessonText extends ConsumerStatefulWidget {
  const LessonText(this.spans, {super.key, this.style, this.textAlign});
  final List<LessonSpan> spans;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  ConsumerState<LessonText> createState() => _LessonTextState();
}

class _LessonTextState extends ConsumerState<LessonText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _showVerse(QuranExcerpt e) {
    final l10n = AppLocalizations.of(context);
    final content = ref.read(contentProvider);
    final lang = ref.read(languageProvider);
    final full = content.quranVerses['${e.surah}:${e.ayah}'];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QuranExcerptView(excerpt: e, size: 32),
                if (full != null && !e.isWholeAyah) ...[
                  const SizedBox(height: 14),
                  Text(
                    l10n.lessonFullVerse,
                    style: ctx.type.ui(size: 13, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      full,
                      style: RattilType.quran(
                        size: 24,
                        color: ctx.isDark
                            ? RattilColors.nightInk
                            : RattilColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    quranReference(e, lang, content.surahNames),
                    style: ctx.type.muted(size: 12.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    final l10n = AppLocalizations.of(context);
    final dark = context.isDark;
    final base = widget.style ?? context.type.prose(size: 16.5);
    final emph = base.copyWith(
      color: dark ? const Color(0xFFF2A39C) : RattilColors.emphasis,
      fontWeight: FontWeight.w600,
    );
    final arabic = context.type.arabicTerm(
      size: (base.fontSize ?? 17) * 1.05,
      weight: FontWeight.w500,
      color: base.color,
    );
    final quran = RattilType.quran(
      size: (base.fontSize ?? 17) * 1.2,
      color: base.color ?? (dark ? RattilColors.nightInk : RattilColors.ink),
    ).copyWith(height: base.height);
    final semantics = <String>[];
    final children = <InlineSpan>[];
    // "(Arabic)" inside left-to-right text: move the brackets into the
    // right-to-left isolate, so they stay with the Arabic when it wraps.
    final spans = widget.spans;
    final bracketed = <int>{
      for (var i = 1; i < spans.length - 1; i++)
        if (spans[i].arabic != null &&
            (spans[i - 1].text ?? '').endsWith('(') &&
            (spans[i + 1].text ?? '').startsWith(')'))
          i,
    };
    String plainText(int i) {
      var t = spans[i].text ?? '';
      if (bracketed.contains(i + 1)) t = t.substring(0, t.length - 1);
      if (bracketed.contains(i - 1)) t = t.substring(1);
      return t;
    }

    for (final (i, s) in spans.indexed) {
      if (s.quran != null) {
        final e = s.quran!;
        final rec = TapGestureRecognizer()..onTap = () => _showVerse(e);
        _recognizers.add(rec);
        children.add(
          TextSpan(
            style: quran,
            recognizer: rec,
            children: [
              const TextSpan(text: '$_rli﴿'),
              ...quranSpans(
                e,
                quran,
                highlight: dark
                    ? LessonColors.highlightDark
                    : LessonColors.highlight,
                highlightBg: dark
                    ? LessonColors.highlightBgDark
                    : LessonColors.highlightBg,
              ),
              const TextSpan(text: '﴾$_pdi'),
            ],
          ),
        );
        semantics.add(e.text);
      } else if (s.arabic != null) {
        final text = bracketed.contains(i) ? '(${s.arabic})' : s.arabic!;
        children.add(TextSpan(text: '$_rli$text$_pdi', style: arabic));
        semantics.add(text);
      } else if (s.emphasis != null) {
        children.add(TextSpan(text: s.emphasis, style: emph));
        semantics.add(s.emphasis!);
      } else {
        final text = plainText(i);
        children.add(TextSpan(text: text));
        semantics.add(text);
      }
    }
    final hasQuran = widget.spans.any((s) => s.quran != null);
    return Semantics(
      hint: hasQuran ? l10n.lessonQuranTapHint : null,
      child: Text.rich(
        TextSpan(style: base, children: children),
        textAlign: widget.textAlign,
      ),
    );
  }
}

/// Questions in the check at the end of a lesson.
const lessonCheckSize = 3;

class _LessonCheckCard extends ConsumerWidget {
  const _LessonCheckCard({required this.count, required this.onStart});
  final int count;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final dark = context.isDark;
    final gold = dark ? RattilColors.goldLight : RattilColors.goldText;
    return Material(
      color: (dark ? RattilColors.goldLight : RattilColors.gold).withValues(
        alpha: dark ? 0.14 : 0.12,
      ),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_alt_outlined, size: 30, color: gold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.lessonCheckTitle,
                      style: context.type.heading(size: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.lessonCheckBody(n(count, lang)),
                style: context.type.muted(size: 13),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                onPressed: onStart,
                label: Text(l10n.lessonCheckStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom bar of a lesson: the section being read, with buttons to move to
/// the previous or next section; the title opens the contents.
class _SectionBar extends StatelessWidget {
  const _SectionBar({
    required this.sections,
    required this.current,
    required this.onJump,
    required this.onContents,
  });
  final List<(int, LessonBlock)> sections;
  final ValueListenable<int> current;
  final ValueChanged<int> onJump;
  final VoidCallback onContents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
          child: ValueListenableBuilder<int>(
            valueListenable: current,
            builder: (context, i, _) => Row(
              children: [
                IconButton(
                  tooltip: l10n.lessonPrevSection,
                  icon: Icon(
                    Icons.chevron_left,
                    textDirection: Directionality.of(context),
                  ),
                  onPressed: i > 0 ? () => onJump(sections[i - 1].$1) : null,
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onContents,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isolated(sections[i].$2.plain),
                            key: ValueKey(i),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: context.type.ui(
                              size: 14,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.lessonNextSection,
                  icon: Icon(
                    Icons.chevron_right,
                    textDirection: Directionality.of(context),
                  ),
                  onPressed: i < sections.length - 1
                      ? () => onJump(sections[i + 1].$1)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A table shown as one card per row: the first cell is the card's title and
/// every other cell sits under its column heading.
class _StackedTable extends StatelessWidget {
  const _StackedTable({
    required this.header,
    required this.rows,
    required this.cols,
  });
  final List<List<LessonSpan>> header;
  final List<List<List<LessonSpan>>> rows;
  final int cols;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = dark ? RattilColors.nightLine : const Color(0xFFCFC6B2);
    final titleBg = dark ? const Color(0xFF22302B) : const Color(0xFFE9E4D4);
    List<LessonSpan> at(List<List<LessonSpan>> r, int k) =>
        k < r.length ? r[k] : const [];
    bool empty(List<LessonSpan> c) => c.every((s) => s.plain.trim().isEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in rows)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: dark ? RattilColors.nightRaised : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!empty(at(r, 0)))
                  Container(
                    color: titleBg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!empty(header[0]))
                          LessonText(
                            header[0],
                            style: context.type.muted(size: 12.5),
                          ),
                        LessonText(
                          at(r, 0),
                          style: context.type.ui(
                            size: 15,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                for (var k = 1; k < cols; k++)
                  if (!empty(at(r, k)))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (k < header.length && !empty(header[k]))
                            LessonText(
                              header[k],
                              style: context.type.ui(
                                size: 12.5,
                                weight: FontWeight.w600,
                                color: dark
                                    ? RattilColors.goldLight
                                    : RattilColors.goldText,
                              ),
                            ),
                          LessonText(
                            at(r, k),
                            style: context.type.prose(size: 15.5),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }
}

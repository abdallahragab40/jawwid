import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/content_repository.dart';
import '../../content/language.dart';
import '../../content/models.dart';
import '../../core/numerals.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../study/study_state.dart';
import '../../core/haptics.dart';
import 'reader_appearance.dart';
import 'reader_document.dart';

/// Signature of a stand-in for the PDF page view (used by widget tests, where
/// the native PDFium library is not available).
typedef PageViewSubstitute =
    Widget Function(
      Edition edition,
      int page,
      ValueChanged<int> onPageChanged,
      VoidCallback onTap,
    );

/// Null in the app: the real PDFium-backed viewer is used.
final pageViewSubstituteProvider = Provider<PageViewSubstitute?>((_) => null);

/// The last page number reported by the real PDFium viewer. Used only by the
/// on-device integration test to confirm what the viewer actually displays.
@visibleForTesting
final ValueNotifier<int?> debugViewerReportedPage = ValueNotifier<int?>(null);

/// The active viewer controller, exposed only for the on-device integration
/// test, which reads [PdfViewerController.pageNumber] (the page actually
/// visible) instead of the page that was requested.
@visibleForTesting
PdfViewerController? debugActiveViewerController;

/// Reads an original edition PDF.
///
/// Page numbers in this screen are physical PDF page indices (1-based). The
/// label shown to the learner is the printed page number when the page has
/// one (see [Edition.printedNumberOf]).
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.edition,
    required this.initialPage,
  });
  final String edition;
  final int initialPage;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _controller = PdfViewerController();
  late String _edition = widget.edition;
  late int _page = widget.initialPage;
  late int _initialPage = widget.initialPage;
  bool _controls = true;
  bool _thumbs = false;
  double? _dragPage;
  int? _pendingPage;
  bool _retrying = false;

  ContentRepository get _content => ref.read(contentProvider);
  Edition get _ed => _content.editions[_edition]!;

  late final StudyController _study = ref.read(studyProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _study.recordPosition(_edition, _page);
    });
  }

  @override
  void dispose() {
    // Persist the last position immediately (it is normally debounced).
    _study.flush(deferStatus: true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPage(int page) {
    if (page == _page) return;
    setState(() => _page = page);
    ref.read(studyProvider.notifier).recordPosition(_edition, page);
  }

  void _toggleControls() {
    setState(() {
      _controls = !_controls;
      if (!_controls) _thumbs = false;
    });
    SystemChrome.setEnabledSystemUIMode(
      _controls ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );
  }

  Future<void> _goTo(int page) async {
    final p = _ed.nearestContentPage(page.clamp(1, _ed.pageCount));
    if (!_controller.isReady) {
      _pendingPage = p;
    } else {
      await _controller.goToPage(
        pageNumber: p,
        anchor: PdfPageAnchor.top,
        duration: const Duration(milliseconds: 250),
      );
    }
    _onPage(p);
  }

  Future<void> _retryDocument() async {
    if (_retrying) return;
    final edition = _edition;
    final document = ref.read(readerDocumentProvider(_ed.asset));
    setState(() {
      _retrying = true;
      _initialPage = _page;
      _pendingPage = _page;
    });
    await document.resolveListenable().load(forceReload: true);
    if (mounted && _edition == edition) setState(() => _retrying = false);
  }

  Future<void> _viewerReady(PdfViewerController controller) async {
    debugActiveViewerController = controller;
    final pending = _pendingPage;
    if (pending != null) {
      await controller.goToPage(
        pageNumber: pending,
        anchor: PdfPageAnchor.top,
        duration: Duration.zero,
      );
      if (!mounted || controller != debugActiveViewerController) return;
      _pendingPage = null;
      _onPage(pending);
    }
    if (mounted) setState(() {}); // Thumbnails requested during loading.
  }

  void _switchEdition(String target) {
    if (target == _edition) return;
    final l10n = AppLocalizations.of(context);
    final topics = _content.topicsAtPage(_edition, _page);
    int? page;
    if (topics.isNotEmpty) {
      page = _content.equivalentPage(
        topicId: topics.first.id,
        fromEdition: _edition,
        fromPage: _page,
        toEdition: target,
      );
      if (page == null) {
        _showUnavailable(topics.first, target, l10n);
        return;
      }
    } else {
      // Front matter, references or covers: map by role, else the saved position.
      final from = _ed, to = _content.editions[target]!;
      if (_page == from.referencesPage) {
        page = to.referencesPage;
      } else if (_page == from.introPage) {
        page = to.introPage;
      } else if (_page == 1) {
        page = 1;
      } else {
        page = ref.read(studyProvider).positions[target] ?? to.introPage;
      }
    }
    setState(() {
      _pendingPage = null;
      _retrying = false;
      _edition = target;
      _page = page!;
      _initialPage = page;
      _thumbs = false;
    });
    ref.read(studyProvider.notifier).recordPosition(_edition, _page);
  }

  void _showUnavailable(Topic topic, String target, AppLocalizations l10n) {
    final lang = ref.read(languageProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.topicUnavailableTitle),
        content: Text(
          l10n.topicUnavailableInEdition(
            topicTitle(topic, lang),
            editionName(l10n, target),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionOk),
          ),
        ],
      ),
    );
  }

  Future<void> _askGoToPage() async {
    final l10n = AppLocalizations.of(context);
    final lang = ref.read(languageProvider);
    final ed = _ed;
    final min = ed.numbering.firstNumbered, max = ed.numbering.lastNumbered;
    final text = TextEditingController();
    String? error;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          void submit() {
            final v = int.tryParse(asciiDigits(text.text.trim()));
            final physical = v == null ? null : ed.physicalForPrinted(v);
            if (physical == null) {
              setLocal(
                () => error = l10n.goToPageInvalid(
                  formatInt(min, lang.code),
                  formatInt(max, lang.code),
                ),
              );
            } else {
              Navigator.pop(ctx, physical);
            }
          }

          return AlertDialog(
            title: Text(l10n.readerGoToPage),
            content: TextField(
              controller: text,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.goToPageFieldLabel,
                hintText:
                    '${formatInt(min, lang.code)}–${formatInt(max, lang.code)}',
                errorText: error,
              ),
              onSubmitted: (_) => submit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(onPressed: submit, child: Text(l10n.actionGo)),
            ],
          );
        },
      ),
    );
    if (result != null) await _goTo(result);
  }

  Future<void> _chooseEdition() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                l10n.readerChooseEdition,
                style: ctx.type.heading(size: 18),
              ),
            ),
            for (final id in const ['ar', 'ckb', 'en', 'id'])
              ListTile(
                selected: id == _edition,
                leading: Icon(
                  id == _edition
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(editionName(l10n, id)),
                subtitle: Text(
                  _content.editions[id]!.title,
                  textDirection: _content.editions[id]!.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
                onTap: () => Navigator.pop(ctx, id),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) _switchEdition(picked);
  }

  Future<void> _chooseAppearance() async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final s = ref.watch(studyProvider);
          final ctl = ref.read(studyProvider.notifier);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.readerAppearance,
                    style: ctx.type.heading(size: 18),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ReaderTheme>(
                    segments: [
                      ButtonSegment(
                        value: ReaderTheme.light,
                        label: Text(l10n.readerThemeLight),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ReaderTheme.sepia,
                        label: Text(l10n.readerThemeSepia),
                        icon: const Icon(Icons.auto_stories_outlined),
                      ),
                      ButtonSegment(
                        value: ReaderTheme.night,
                        label: Text(l10n.readerThemeNight),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {s.readerTheme},
                    onSelectionChanged: (v) => ctl.setReaderTheme(v.first),
                  ),
                  const SizedBox(height: 8),
                  if (s.readerTheme == ReaderTheme.night)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: s.dimNightPages,
                      onChanged: ctl.setDimNightPages,
                      title: Text(l10n.readerDimPages),
                      subtitle: Text(l10n.readerDimPagesHint),
                    ),
                  Text(
                    l10n.readerColorsNote,
                    style: ctx.type.muted(size: 12.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openNotes() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _NotesSheet(edition: _edition, page: _page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final study = ref.watch(studyProvider);
    final look = ReaderAppearance.of(
      study.readerTheme,
      dim: study.dimNightPages,
    );
    final ed = _ed;
    final topics = _content.topicsAtPage(_edition, _page);
    final bookmarked = study.isBookmarked(_edition, _page);
    final noteCount = study.notesAt(_edition, _page).length;
    final pageLabel = printedPageLabel(l10n, ed, _page, lang);

    final substitute = ref.watch(pageViewSubstituteProvider);
    Widget viewer = substitute != null
        ? substitute(ed, _page, _onPage, _toggleControls)
        : PdfViewer(
            ref.watch(readerDocumentProvider(ed.asset)),
            key: ValueKey('viewer-$_edition-$_initialPage'),
            controller: _controller,
            initialPageNumber: ed.nearestContentPage(_initialPage),
            params: PdfViewerParams(
              // Blank pages (after the cover, before the back cover) take no
              // space, so the book never shows an empty white sheet.
              layoutPages: (pages, params) =>
                  layoutWithoutBlankPages(pages, params, ed.blankPages),
              backgroundColor: look.backdrop,
              margin: 6,
              pageDropShadow: look.pageShadow,
              // Memory budget suited to ordinary phones; pages outside the cache
              // extent are re-rendered on demand from the bundled file.
              maxImageBytesCachedOnMemory: 48 * 1024 * 1024,
              horizontalCacheExtent: 0.5,
              verticalCacheExtent: 1.0,
              onViewerReady: (document, controller) {
                _viewerReady(controller);
              },
              onPageChanged: (p) {
                if (p == null || _pendingPage != null) return;
                debugViewerReportedPage.value = p;
                _onPage(p);
              },
              onGeneralTap: (ctx, controller, details) {
                if (details.type == PdfViewerGeneralTapType.tap) {
                  _toggleControls();
                  return true;
                }
                return false;
              },
              loadingBannerBuilder: (ctx, _, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: look.onChrome),
                    const SizedBox(height: 12),
                    Text(
                      l10n.readerLoading,
                      style: ctx.type.ui(color: look.onChrome),
                    ),
                  ],
                ),
              ),
              errorBannerBuilder: (ctx, error, _, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.readerError,
                        style: ctx.type.ui(color: look.onChrome),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (_retrying)
                        CircularProgressIndicator(color: look.onChrome)
                      else
                        FilledButton.icon(
                          onPressed: _retryDocument,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.startupRetry),
                        ),
                      TextButton(
                        onPressed: () => Navigator.maybePop(context),
                        child: Text(
                          MaterialLocalizations.of(ctx).backButtonTooltip,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
    if (look.filter != null) {
      viewer = ColorFiltered(colorFilter: look.filter!, child: viewer);
    }

    final chromeText = context.type.ui(
      size: 15,
      weight: FontWeight.w600,
      color: look.onChrome,
    );
    final chromeMuted = context.type.ui(size: 12.5, color: look.onChromeMuted);

    return Scaffold(
      backgroundColor: look.backdrop,
      body: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              label: l10n.readerPageSemantics(
                editionName(l10n, _edition),
                pageLabel,
              ),
              child: RepaintBoundary(
                key: const ValueKey('reader-page-surface'),
                child: viewer,
              ),
            ),
          ),
          // Top controls.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _controls ? 0 : -140,
            left: 0,
            right: 0,
            child: Material(
              color: look.chrome,
              elevation: 1,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      BackButton(color: look.onChrome),
                      Expanded(
                        child: InkWell(
                          onTap: topics.isEmpty
                              ? null
                              : () => openTopic(context, topics.first.id),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                topics.isEmpty
                                    ? editionName(l10n, _edition)
                                    : topicTitle(topics.first, lang),
                                style: chromeText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${editionName(l10n, _edition)} · $pageLabel',
                                style: chromeMuted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: bookmarked
                            ? l10n.readerRemoveBookmark
                            : l10n.readerAddBookmark,
                        color: look.onChrome,
                        icon: Icon(
                          bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        onPressed: () {
                          ref.read(hapticsProvider).toggle();
                          final controller = ref.read(studyProvider.notifier);
                          final removed = bookmarked
                              ? study.bookmarks.firstWhere(
                                  (b) =>
                                      b.edition == _edition && b.page == _page,
                                )
                              : null;
                          final removedIndex = removed == null
                              ? null
                              : study.bookmarks.indexOf(removed);
                          controller.toggleBookmark(_edition, _page);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  bookmarked
                                      ? l10n.bookmarkRemoved
                                      : l10n.bookmarkAdded,
                                ),
                                action: removed == null
                                    ? null
                                    : SnackBarAction(
                                        label: l10n.actionUndo,
                                        onPressed: () =>
                                            controller.restoreBookmark(
                                              removed,
                                              index: removedIndex,
                                            ),
                                      ),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                        },
                      ),
                      IconButton(
                        tooltip: l10n.readerNotes,
                        color: look.onChrome,
                        icon: Badge(
                          isLabelVisible: noteCount > 0,
                          label: Text(n(noteCount, lang)),
                          child: Icon(
                            noteCount > 0
                                ? Icons.sticky_note_2
                                : Icons.sticky_note_2_outlined,
                          ),
                        ),
                        onPressed: _openNotes,
                      ),
                      PopupMenuButton<String>(
                        tooltip: l10n.readerMore,
                        iconColor: look.onChrome,
                        onSelected: (v) => switch (v) {
                          'goto' => _askGoToPage(),
                          'edition' => _chooseEdition(),
                          'look' => _chooseAppearance(),
                          'lesson' =>
                            topics.isEmpty
                                ? null
                                : openTopic(context, topics.first.id),
                          _ => null,
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'goto',
                            child: ListTile(
                              leading: const Icon(Icons.pin_outlined),
                              title: Text(l10n.readerGoToPage),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edition',
                            child: ListTile(
                              leading: const Icon(Icons.translate),
                              title: Text(l10n.readerChooseEdition),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'look',
                            child: ListTile(
                              leading: const Icon(Icons.contrast),
                              title: Text(l10n.readerAppearance),
                            ),
                          ),
                          if (topics.isNotEmpty)
                            PopupMenuItem(
                              value: 'lesson',
                              child: ListTile(
                                leading: const Icon(Icons.school_outlined),
                                title: Text(l10n.readerLessonDetails),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _controls ? 0.0 : (_thumbs ? -260.0 : -160.0),
            left: 0,
            right: 0,
            child: Material(
              color: look.chrome,
              elevation: 1,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_thumbs)
                        _Thumbnails(
                          controller: _controller,
                          edition: ed,
                          current: _page,
                          onTap: _goTo,
                          look: look,
                        ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: _thumbs
                                ? l10n.readerHideThumbnails
                                : l10n.readerShowThumbnails,
                            color: look.onChrome,
                            icon: Icon(
                              _thumbs
                                  ? Icons.view_carousel
                                  : Icons.view_carousel_outlined,
                            ),
                            onPressed: () => setState(() => _thumbs = !_thumbs),
                          ),
                          Expanded(
                            // The slider runs in the book's own direction: page 1 is
                            // on the right for the Arabic and Kurdish editions.
                            child: Directionality(
                              textDirection: ed.isRtl
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Slider(
                                min: 1,
                                max: ed.pageCount.toDouble(),
                                divisions: ed.pageCount - 1,
                                value: (_dragPage ?? _page.toDouble()).clamp(
                                  1,
                                  ed.pageCount.toDouble(),
                                ),
                                label: printedPageLabel(
                                  l10n,
                                  ed,
                                  (_dragPage ?? _page.toDouble()).round(),
                                  lang,
                                ),
                                semanticFormatterCallback: (v) =>
                                    printedPageLabel(l10n, ed, v.round(), lang),
                                onChanged: (v) => setState(() => _dragPage = v),
                                onChangeEnd: (v) {
                                  setState(() => _dragPage = null);
                                  _goTo(v.round());
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _askGoToPage,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    pageLabel,
                                    style: chromeText.copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    l10n.readerPositionOf(
                                      n(_page, lang),
                                      n(ed.pageCount, lang),
                                    ),
                                    style: chromeMuted.copyWith(fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnails extends StatefulWidget {
  const _Thumbnails({
    required this.controller,
    required this.edition,
    required this.current,
    required this.onTap,
    required this.look,
  });
  final PdfViewerController controller;
  final Edition edition;
  final int current;
  final ValueChanged<int> onTap;
  final ReaderAppearance look;

  @override
  State<_Thumbnails> createState() => _ThumbnailsState();
}

class _ThumbnailsState extends State<_Thumbnails> {
  static const _w = 62.0, _h = 88.0, _gap = 8.0;

  /// Pages shown as thumbnails: blank pages are left out.
  late final List<int> _pages = [
    for (var p = 1; p <= widget.edition.pageCount; p++)
      if (!widget.edition.blankPages.contains(p)) p,
  ];
  late final _scroll = ScrollController(
    initialScrollOffset:
        ((_pages.indexWhere((p) => p >= widget.current) - 3).clamp(
          0,
          1 << 20,
        )) *
        (_w + _gap),
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!widget.controller.isReady) return const SizedBox(height: _h + 28);
    final doc = widget.controller.document;
    return SizedBox(
      height: _h + 28,
      child: Directionality(
        textDirection: widget.edition.isRtl
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: ListView.separated(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          itemCount: _pages.length,
          separatorBuilder: (_, _) => const SizedBox(width: _gap),
          itemBuilder: (ctx, i) {
            final page = _pages[i];
            final selected = page == widget.current;
            final printed = widget.edition.printedNumberOf(page);
            return Semantics(
              button: true,
              selected: selected,
              label: printed == null
                  ? l10n.pageUnnumbered
                  : l10n.pageLabel('$printed'),
              child: GestureDetector(
                onTap: () => widget.onTap(page),
                child: Column(
                  children: [
                    Container(
                      width: _w,
                      height: _h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected
                              ? RattilColors.gold
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: PdfPageView(
                        document: doc,
                        pageNumber: page,
                        // Low resolution keeps thumbnail memory small.
                        maximumDpi: 40,
                        decoration: const BoxDecoration(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      printed == null
                          ? '·'
                          : localizeDigits(
                              '$printed',
                              Localizations.localeOf(context).languageCode,
                            ),
                      style: context.type.ui(
                        size: 11,
                        color: widget.look.onChromeMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotesSheet extends ConsumerStatefulWidget {
  const _NotesSheet({required this.edition, required this.page});
  final String edition;
  final int page;

  @override
  ConsumerState<_NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends ConsumerState<_NotesSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final notes = ref.watch(studyProvider).notesAt(widget.edition, widget.page);
    final ed = ref.read(contentProvider).editions[widget.edition]!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.notesForPage(
                  printedPageLabel(l10n, ed, widget.page, lang),
                ),
                style: context.type.heading(size: 18),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.notesPrivateHint,
                style: context.type.muted(size: 12.5),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final note in notes)
                      Card(
                        child: ListTile(
                          title: Text(
                            note.text,
                            style: context.type.prose(size: 15),
                          ),
                          trailing: IconButton(
                            tooltip: l10n.actionDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              final controller = ref.read(
                                studyProvider.notifier,
                              );
                              final index = ref
                                  .read(studyProvider)
                                  .notes
                                  .indexOf(note);
                              controller.deleteNote(note.id);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.noteDeleted),
                                    action: SnackBarAction(
                                      label: l10n.actionUndo,
                                      onPressed: () => controller.restoreNote(
                                        note,
                                        index: index,
                                      ),
                                    ),
                                  ),
                                );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _text,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(hintText: l10n.notesHint),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.notesAdd),
                onPressed: () {
                  final t = _text.text.trim();
                  if (t.isEmpty) return;
                  ref
                      .read(studyProvider.notifier)
                      .addNote(widget.edition, widget.page, t);
                  _text.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Where "continue reading" should open, in the learner's current language.
class ContinueTarget {
  const ContinueTarget({
    required this.edition,
    required this.page,
    required this.topicId,
    this.unavailableTopicId,
  });
  final String edition;
  final int page;
  final String? topicId;

  /// Set when the last-read topic has no equivalent in [edition].
  final String? unavailableTopicId;
}

ContinueTarget? resolveContinue(
  StudyState s,
  ContentRepository content,
  AppLanguage lang,
) {
  final last = s.lastRead;
  if (last == null) return null;
  final ed = lang.editionId;
  if (last.edition == ed) {
    return ContinueTarget(edition: ed, page: last.page, topicId: last.topicId);
  }
  final topicId = last.topicId;
  if (topicId == null) {
    final saved = s.positions[ed];
    return ContinueTarget(
      edition: ed,
      page: saved ?? content.editions[ed]!.introPage,
      topicId: null,
    );
  }
  final range = content.topic(topicId).pagesIn(ed);
  if (range == null) {
    return ContinueTarget(
      edition: last.edition,
      page: last.page,
      topicId: topicId,
      unavailableTopicId: topicId,
    );
  }
  // Prefer the learner's own saved position in this edition if it is inside
  // the same topic; otherwise map by topic.
  final saved = s.positions[ed];
  if (saved != null && range.contains(saved)) {
    return ContinueTarget(edition: ed, page: saved, topicId: topicId);
  }
  final mapped = content.equivalentPage(
    topicId: topicId,
    fromEdition: last.edition,
    fromPage: last.page,
    toEdition: ed,
  );
  return ContinueTarget(
    edition: ed,
    page: mapped ?? range.start,
    topicId: topicId,
  );
}

/// The viewer's usual vertical layout, except that [blank] pages get zero
/// height (and no margin): they are never rendered or reported as visible.
PdfPageLayout layoutWithoutBlankPages(
  List<PdfPage> pages,
  PdfViewerParams params,
  Set<int> blank,
) {
  final width =
      pages.fold(0.0, (w, p) => w > p.width ? w : p.width) + params.margin * 2;
  final layouts = <Rect>[];
  var y = params.margin;
  for (final page in pages) {
    final x = (width - page.width) / 2;
    if (blank.contains(page.pageNumber)) {
      layouts.add(Rect.fromLTWH(x, y, page.width, 0));
      continue;
    }
    layouts.add(Rect.fromLTWH(x, y, page.width, page.height));
    y += page.height + params.margin;
  }
  return PdfPageLayout(pageLayouts: layouts, documentSize: Size(width, y));
}

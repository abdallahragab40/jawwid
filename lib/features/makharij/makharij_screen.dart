import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';

/// Five general areas and seventeen articulation points over the books' own
/// sagittal illustration. The illustration is never mirrored: its geometry is
/// laid out left-to-right in every interface language.
class MakharijScreen extends ConsumerStatefulWidget {
  const MakharijScreen({super.key});

  @override
  ConsumerState<MakharijScreen> createState() => _MakharijScreenState();
}

class _MakharijScreenState extends ConsumerState<MakharijScreen> {
  String? _area;
  String _point = 'p02';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final data = ref.watch(contentProvider).makharij;
    final point = data.point(_point);
    final visiblePoints = [
      for (final p in data.points)
        if (_area == null || p.areaId == _area) p,
    ];
    final ed = lang.editionId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.makharijTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Text(
            l10n.makharijIntro(
              n(data.areas.length, lang),
              n(data.points.length, lang),
            ),
            style: context.type.muted(size: 14),
          ),
          const SizedBox(height: 12),
          _Diagram(
            data: data,
            active: point.landmarkIds.toSet(),
            language: lang,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.makharijDiagramSource,
                  style: context.type.muted(size: 12),
                ),
              ),
              TextButton(
                onPressed: () => openReader(
                  context,
                  edition: ed,
                  page: data.imageSourcePages[ed]!,
                ),
                child: Text(l10n.makharijOpenDiagramPage),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _PointDetail(point: point, data: data),
          const SizedBox(height: 16),
          SectionHeading(l10n.makharijAllPoints),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(l10n.makharijAllAreas),
                    selected: _area == null,
                    onSelected: (_) => setState(() => _area = null),
                  ),
                ),
                for (final a in data.areas)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(a.name.of(lang.code)),
                      selected: _area == a.id,
                      onSelected: (_) => setState(() => _area = a.id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                for (final (i, p) in visiblePoints.indexed) ...[
                  if (i > 0) const Divider(indent: 72),
                  ListTile(
                    selected: p.id == _point,
                    leading: SizedBox(
                      width: 48,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          p.letters,
                          style: context.type.arabicTerm(
                            size: 18,
                            weight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    title: Text(p.name.of(lang.code)),
                    subtitle: Text(
                      data.areas
                          .firstWhere((a) => a.id == p.areaId)
                          .name
                          .of(lang.code),
                    ),
                    onTap: () => setState(() => _point = p.id),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Diagram extends StatelessWidget {
  const _Diagram({
    required this.data,
    required this.active,
    required this.language,
  });
  final MakharijData data;
  final Set<String> active;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: dark ? RattilColors.nightRaised : Colors.white,
        child: InteractiveViewer(
          maxScale: 4,
          child: AspectRatio(
            aspectRatio: data.imageWidth / data.imageHeight,
            // Fixed LTR geometry: anatomical drawings must not be mirrored.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth, h = c.maxHeight;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          data.imageAsset,
                          fit: BoxFit.fill,
                          semanticLabel: null,
                          excludeFromSemantics: true,
                        ),
                      ),
                      for (final l in data.landmarks)
                        Positioned(
                          left: l.x * w - (active.contains(l.id) ? 9 : 5),
                          top: l.y * h - (active.contains(l.id) ? 9 : 5),
                          child: ExcludeSemantics(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: active.contains(l.id) ? 18 : 10,
                              height: active.contains(l.id) ? 18 : 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: active.contains(l.id)
                                    ? RattilColors.gold
                                    : Colors.white,
                                border: Border.all(
                                  color: RattilColors.emerald900,
                                  width: active.contains(l.id) ? 2.5 : 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      for (final l in data.landmarks.where(
                        (l) => active.contains(l.id),
                      ))
                        Positioned(
                          left: (l.x * w + 12).clamp(0, w - 150),
                          top: (l.y * h - 30).clamp(0, h - 26),
                          child: ExcludeSemantics(
                            child: Directionality(
                              textDirection: language.direction,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 150,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: RattilColors.emerald900.withValues(
                                    alpha: 0.88,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l.label.of(language.code),
                                  style: context.type.diagramLabel(
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PointDetail extends ConsumerWidget {
  const _PointDetail({required this.point, required this.data});
  final MakhrajPoint point;
  final MakharijData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final ed = lang.editionId;
    final text = point.text.of(lang.code);
    final area = data.areas.firstWhere((a) => a.id == point.areaId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.name.of(lang.code),
                          style: context.type.muted(size: 12.5),
                        ),
                        Text(
                          point.name.of(lang.code),
                          style: context.type.heading(size: 19),
                        ),
                      ],
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      point.letters,
                      style: context.type.arabicTerm(
                        size: 26,
                        weight: FontWeight.w700,
                        color: context.isDark
                            ? RattilColors.goldLight
                            : RattilColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(text.text, style: context.type.prose(size: 15.5)),
              if (point.unmarked) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.makharijNotMarked,
                  style: context.type.muted(size: 12.5),
                ),
              ],
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(
                    l10n.makharijReadInBook(
                      editionName(l10n, ed),
                      n(point.pages[ed]!, lang),
                    ),
                  ),
                  onPressed: () =>
                      openReader(context, edition: ed, page: point.pages[ed]!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

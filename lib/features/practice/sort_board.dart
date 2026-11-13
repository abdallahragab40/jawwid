import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/models.dart';
import '../../l10n/generated/app_localizations.dart';
import '../study/study_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A sort question: tap a letter, then the group it belongs to. Tapping a
/// placed letter takes it back. "Check" reports the placement through
/// [onCheck]; once [result] is set, each letter shows whether it is right.
class SortBoard extends ConsumerStatefulWidget {
  const SortBoard({
    super.key,
    required this.question,
    required this.order,
    required this.result,
    required this.onCheck,
  });
  final Question question;

  /// Display order of the items (indices into [Question.items]).
  final List<int> order;

  /// The checked placement (item index → group index), or null.
  final Map<int, int>? result;
  final ValueChanged<Map<int, int>> onCheck;

  @override
  ConsumerState<SortBoard> createState() => _SortBoardState();
}

class _SortBoardState extends ConsumerState<SortBoard> {
  final _placed = <int, int>{};
  int? _selected;

  bool get _checked => widget.result != null;

  @override
  void initState() {
    super.initState();
    _selected = widget.order.firstOrNull;
  }

  void _tapItem(int i) {
    if (_checked) return;
    setState(() {
      if (_placed.containsKey(i)) {
        _placed.remove(i);
        _selected = i;
      } else {
        _selected = i;
      }
    });
  }

  void _tapGroup(int g) {
    final i = _selected;
    if (_checked || i == null) return;
    setState(() {
      _placed[i] = g;
      // Move on to the next letter still waiting.
      _selected = widget.order
          .where((k) => !_placed.containsKey(k))
          .firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final q = widget.question;
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final placement = widget.result ?? _placed;
    final waiting = [
      for (final i in widget.order)
        if (!placement.containsKey(i)) i,
    ];

    Widget tile(int i) {
      final item = q.items[i];
      final selected = _selected == i && !_checked;
      Color border = dark ? RattilColors.nightLine : RattilColors.lineStrong;
      Widget? badge;
      if (_checked) {
        final ok = widget.result![i] == item.group;
        border = ok
            ? LessonColors.correctFor(brightness)
            : LessonColors.incorrectFor(brightness);
        badge = Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: border,
        );
      } else if (selected) {
        border = scheme.primary;
      }
      return Semantics(
        button: !_checked,
        selected: selected,
        label: item.arabic,
        hint: placement.containsKey(i) && !_checked
            ? l10n.quizSortReturn
            : null,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _checked ? null : () => _tapItem(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.12)
                  : (dark ? RattilColors.nightRaised : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: border,
                width: selected || _checked ? 2 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  item.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: context.type
                      .arabicTerm(size: 24, weight: FontWeight.w700)
                      .copyWith(height: 1.3),
                ),
                if (badge != null)
                  PositionedDirectional(top: 2, end: 2, child: badge),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_checked) ...[
          Text(l10n.quizSortHint, style: context.type.muted(size: 13.5)),
          const SizedBox(height: 10),
        ],
        if (waiting.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [for (final i in waiting) tile(i)],
          ),
          const SizedBox(height: 14),
        ],
        for (final (g, label) in q.groups.indexed) ...[
          Semantics(
            button: !_checked && _selected != null,
            label: label.of(lang.code),
            child: Material(
              color: UnitColors.of(
                g + 1,
                brightness,
              ).withValues(alpha: dark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _checked || _selected == null
                    ? null
                    : () => _tapGroup(g),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 84),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          label.of(lang.code),
                          style: context.type.ui(
                            size: 15,
                            weight: FontWeight.w700,
                            color: UnitColors.of(g + 1, brightness),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final i in widget.order)
                            if (placement[i] == g) tile(i),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (!_checked)
          FilledButton(
            onPressed: waiting.isEmpty
                ? () => widget.onCheck(Map.of(_placed))
                : null,
            child: Text(l10n.quizCheck),
          ),
      ],
    );
  }
}

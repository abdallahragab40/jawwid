import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/study/study_state.dart';

/// Short, quiet touch feedback, used only where something changes (a tab,
/// a switch, an answer, a bookmark). Respects the learner's setting.
class Haptics {
  const Haptics(this._enabled);
  final bool _enabled;

  /// Tab change, list choice, opening a section.
  void selection() {
    if (_enabled) HapticFeedback.selectionClick();
  }

  /// A switch or a saved item (bookmark, completion).
  void toggle() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  /// A correct answer.
  void success() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  /// A wrong answer: two short taps, firm but not alarming.
  Future<void> wrong() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }
}

final hapticsProvider = Provider<Haptics>(
  (ref) => Haptics(ref.watch(studyProvider.select((s) => s.hapticsEnabled))),
);

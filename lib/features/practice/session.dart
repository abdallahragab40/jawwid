import 'dart:math';

import '../../content/models.dart';
import '../study/study_state.dart';

/// Questions in one practice session.
const quizSessionSize = 10;

/// Picks the questions of one practice session from [pool].
///
/// Questions missed last time come first, then questions not tried yet, then
/// the ones already answered correctly. Inside each group the rules and
/// lessons take turns, so a large lesson (topic 10 has most questions) does
/// not fill a whole session.
List<Question> buildSession(
  List<Question> pool,
  Map<String, QuizRecord> results,
  Random random, {
  int limit = quizSessionSize,
  bool mistakesOnly = false,
}) {
  List<Question> tier(bool Function(QuizRecord?) test) {
    final groups = <String, List<Question>>{};
    for (final q in pool) {
      if (test(results[q.id])) {
        (groups[q.relatedRuleId ?? q.topicId] ??= []).add(q);
      }
    }
    final lists = [
      for (final g in groups.values) [...g]..shuffle(random),
    ]..shuffle(random);
    return [
      for (var i = 0; lists.any((g) => i < g.length); i++)
        for (final g in lists)
          if (i < g.length) g[i],
    ];
  }

  return [
    ...tier((r) => r != null && !r.lastCorrect),
    if (!mistakesOnly) ...tier((r) => r == null),
    if (!mistakesOnly) ...tier((r) => r != null && r.lastCorrect),
  ].take(limit).toList();
}

/// Number of questions in [pool] whose last answer was wrong.
int mistakeCount(List<Question> pool, Map<String, QuizRecord> results) =>
    pool.where((q) => results[q.id]?.lastCorrect == false).length;

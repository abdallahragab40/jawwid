import 'dart:convert';

import '../../content/content_repository.dart';
import '../../content/models.dart';

/// A checkpoint at the next unanswered question. Answers are recorded once,
/// before the checkpoint advances, so restoring never submits them again.
class SavedSession {
  const SavedSession({
    required this.contentVersion,
    required this.fingerprint,
    required this.questionIds,
    required this.order,
    required this.index,
    required this.correct,
    required this.missedIds,
    this.topicId,
    this.ruleId,
  });

  final String contentVersion;
  final String fingerprint;
  final List<String> questionIds;
  final List<List<int>> order;
  final int index;
  final int correct;
  final List<String> missedIds;
  final String? topicId;
  final String? ruleId;

  static String fingerprintFor(ContentRepository content, List<String> ids) {
    final byId = {for (final q in content.questions) q.id: q};
    final payload = jsonEncode([
      for (final id in ids)
        if (byId[id] case final q?)
          [
            q.id,
            q.type.name,
            q.topicId,
            q.ruleId,
            q.prompt?.values,
            q.ruleOptions,
            q.answerRuleId,
            q.answerIndex,
            q.answerBool,
            q.explanation.values,
            q.example?.text,
            q.example?.highlights.toString(),
            [
              for (final c in q.choices)
                [c.number, c.arabic, c.counts, c.text?.values],
            ],
            [for (final g in q.groups) g.values],
            [
              for (final it in q.items) [it.arabic, it.group],
            ],
          ]
        else
          null,
    ]);
    var hash = 2166136261;
    for (final unit in payload.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }

  bool canResume(ContentRepository content) {
    if (content.contentVersion != contentVersion ||
        fingerprint != fingerprintFor(content, questionIds)) {
      return false;
    }
    if (topicId != null && content.topicOrNull(topicId) == null) return false;
    if (ruleId != null && content.rule(ruleId!) == null) return false;
    final questions = {for (final q in content.questions) q.id: q};
    for (final (i, id) in questionIds.indexed) {
      final q = questions[id];
      if (q == null ||
          (topicId != null && q.topicId != topicId) ||
          (ruleId != null && q.relatedRuleId != ruleId)) {
        return false;
      }
      final count = switch (q.type) {
        QuestionType.identify => q.ruleOptions.length,
        QuestionType.choice => q.choices.length,
        QuestionType.trueFalse => 0,
        QuestionType.sort => q.items.length,
      };
      if (order[i].length != count) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
    'contentVersion': contentVersion,
    'fingerprint': fingerprint,
    'questionIds': questionIds,
    'order': order,
    'index': index,
    'correct': correct,
    'missedIds': missedIds,
    'topicId': topicId,
    'ruleId': ruleId,
  };

  static SavedSession? fromJson(dynamic value) {
    try {
      if (value is! Map) return null;
      final ids = (value['questionIds'] as List).cast<String>();
      final order = [
        for (final row in value['order'] as List) (row as List).cast<int>(),
      ];
      final index = value['index'] as int;
      final correct = value['correct'] as int;
      final missed = (value['missedIds'] as List).cast<String>();
      if (ids.isEmpty ||
          ids.length > 100 ||
          ids.toSet().length != ids.length ||
          order.length != ids.length ||
          index < 0 ||
          index >= ids.length ||
          correct < 0 ||
          correct > index ||
          missed.length != index - correct ||
          missed.toSet().length != missed.length ||
          !missed.every(ids.take(index).contains)) {
        return null;
      }
      for (final row in order) {
        if (row.toSet().length != row.length ||
            row.any((i) => i < 0 || i >= row.length)) {
          return null;
        }
      }
      return SavedSession(
        contentVersion: value['contentVersion'] as String,
        fingerprint: value['fingerprint'] as String,
        questionIds: ids.toList(),
        order: order,
        index: index,
        correct: correct,
        missedIds: missed.toList(),
        topicId: value['topicId'] as String?,
        ruleId: value['ruleId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/study_backup.dart';
import 'package:rattil/features/study/study_state.dart';

void main() {
  test(
    'backup export date round trips while older date-free backups restore',
    () {
      const state = StudyState(topicProgress: {'t01': TopicProgress.completed});
      final date = DateTime.utc(2026, 11, 14, 10, 30);
      final text = encodeStudyBackup(state, exportedAt: date);
      expect(decodeStudyBackupEnvelope(text).exportedAt, date);
      final envelope = jsonDecode(text) as Map<String, dynamic>;
      envelope.remove('exportedAt');
      final legacy = decodeStudyBackupEnvelope(jsonEncode(envelope));
      expect(legacy.exportedAt, isNull);
      expect(legacy.state.progressOf('t01'), TopicProgress.completed);
    },
  );
}

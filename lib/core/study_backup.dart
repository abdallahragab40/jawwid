import 'dart:convert';

import '../features/study/study_state.dart';
import '../content/content_repository.dart';
import 'study_validation.dart';

/// Portable, explicitly exported learner data. No automatic network transfer.
const maxStudyBackupBytes = 5 * 1024 * 1024;

class StudyBackup {
  const StudyBackup({required this.state, this.exportedAt});
  final StudyState state;
  final DateTime? exportedAt;
}

String encodeStudyBackup(StudyState state, {DateTime? exportedAt}) =>
    const JsonEncoder.withIndent('  ').convert({
      'format': 'jawwid-backup',
      'version': 1,
      'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'data': state.toJson(),
    });

StudyState decodeStudyBackup(String text, {ContentRepository? content}) =>
    decodeStudyBackupEnvelope(text, content: content).state;

StudyBackup decodeStudyBackupEnvelope(
  String text, {
  ContentRepository? content,
}) {
  if (text.length > maxStudyBackupBytes) {
    throw const FormatException('Too large');
  }
  final decoded = jsonDecode(text);
  if (decoded is! Map<String, dynamic> ||
      decoded['format'] != 'jawwid-backup' ||
      decoded['version'] != 1 ||
      decoded['data'] is! Map<String, dynamic>) {
    throw const FormatException('Unsupported backup');
  }
  final data = decoded['data'] as Map<String, dynamic>;
  // A backup must contain a full state, rather than silently wiping data when
  // given an arbitrary JSON object. StudyState validates individual values.
  for (final key in ['positions', 'topicStatus', 'quiz']) {
    if (data[key] is! Map) throw const FormatException('Missing state');
  }
  for (final key in ['bookmarks', 'notes']) {
    if (data[key] is! List) throw const FormatException('Missing state');
  }
  final state = StudyState.fromJson(data).copyWith(welcomed: true);
  if (content != null) validateStudyReferences(state, content);
  return StudyBackup(
    state: state,
    exportedAt: DateTime.tryParse(decoded['exportedAt'] as String? ?? ''),
  );
}

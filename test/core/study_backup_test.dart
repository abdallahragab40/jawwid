import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rattil/core/study_backup.dart';
import 'package:rattil/features/study/study_state.dart';

void main() {
  test(
    'review stages advance on delayed recall, not repeated same-day answers',
    () {
      var now = DateTime.utc(2026, 11, 13);
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);
      final controller = container.read(studyProvider.notifier);
      controller.recordAnswer('q1', true);
      expect(container.read(studyProvider).learningDays, {'2026-11-13'});
      expect(container.read(studyProvider).quiz['q1']!.reviewStage, 1);
      final due = container.read(studyProvider).quiz['q1']!.nextReviewAt;
      controller.recordAnswer('q1', true);
      expect(container.read(studyProvider).quiz['q1']!.reviewStage, 1);
      expect(container.read(studyProvider).quiz['q1']!.nextReviewAt, due);
      now = now.add(const Duration(days: 1));
      controller.recordAnswer('q1', true);
      expect(container.read(studyProvider).quiz['q1']!.reviewStage, 2);
      expect(
        container.read(studyProvider).quiz['q1']!.nextReviewAt,
        now.add(const Duration(days: 3)),
      );
      controller.recordAnswer('q1', false);
      expect(container.read(studyProvider).quiz['q1']!.reviewStage, 0);
      expect(
        container.read(studyProvider).quiz['q1']!.nextReviewAt,
        now.add(const Duration(days: 1)),
      );
    },
  );
  test(
    'weekly goal and learning days survive storage; legacy reading days stay separate',
    () {
      final state = StudyState.fromJson({
        'streak': {
          'days': ['2026-11-12'],
        },
      });
      expect(state.learningDays, isEmpty);
      final restored = StudyState.fromJson(
        state.copyWith(weeklyGoal: 5, learningDays: {'2026-11-13'}).toJson(),
      );
      expect(restored.weeklyGoal, 5);
      expect(restored.learningDays, {'2026-11-13'});
    },
  );

  test('backup round trip retains notes, progress and review schedule', () {
    final now = DateTime.utc(2026, 11, 13);
    final state = StudyState(
      lessonPositions: const {'en:t10:123': 7},
      topicProgress: const {'t10': TopicProgress.completed},
      notes: [
        Note(
          id: 'n1',
          edition: 'en',
          page: 41,
          topicId: 't10',
          text: 'Private note',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      quiz: {
        'q01': QuizRecord(
          attempts: 2,
          correct: 2,
          lastCorrect: true,
          lastAt: now,
          reviewStage: 2,
          nextReviewAt: now.add(const Duration(days: 3)),
        ),
      },
    );
    final restored = decodeStudyBackup(encodeStudyBackup(state));
    expect(restored.notes.single.text, 'Private note');
    expect(restored.progressOf('t10'), TopicProgress.completed);
    expect(restored.lessonPositions, state.lessonPositions);
    expect(restored.quiz['q01']!.nextReviewAt, state.quiz['q01']!.nextReviewAt);
  });
  test('invalid and future backup versions are rejected', () {
    for (final value in [
      'broken',
      '{}',
      jsonEncode({'format': 'jawwid-backup', 'version': 2, 'data': {}}),
      jsonEncode({'format': 'jawwid-backup', 'version': 1, 'data': {}}),
    ]) {
      expect(() => decodeStudyBackup(value), throwsFormatException);
    }
  });
}

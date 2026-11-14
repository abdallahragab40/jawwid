import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/features/study/study_state.dart';

class RecordingStore extends JsonStore {
  RecordingStore() : super(Directory.systemTemp);
  bool fail = false;
  int writes = 0;
  Map<String, dynamic>? saved;

  @override
  void saveSync(Map<String, dynamic> data) {
    writes++;
    if (fail) throw const FileSystemException('disk full');
    saved = data;
  }
}

void main() {
  test('failed edits stay dirty and retry saves the latest state', () async {
    final store = RecordingStore()..fail = true;
    final container = ProviderContainer(
      overrides: [storeProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    final controller = container.read(studyProvider.notifier);
    controller.setWeeklyGoal(7);
    controller.recordAnswer('q1', true);
    expect(container.read(studySaveStatusProvider), StudySaveStatus.failed);
    expect(container.read(studyProvider).weeklyGoal, 7);
    expect(container.read(studyProvider).quiz['q1']!.attempts, 1);
    expect(store.saved, isNull);

    store.fail = false;
    await controller.flush();
    expect(container.read(studySaveStatusProvider), StudySaveStatus.saved);
    final restored = StudyState.fromJson(store.saved!);
    expect(restored.weeklyGoal, 7);
    expect(restored.quiz['q1']!.attempts, 1);
    final writes = store.writes;
    controller.flushPending();
    expect(store.writes, writes);
  });

  test('disposing with pending sections persists without using a dead Ref', () {
    final store = RecordingStore();
    final container = ProviderContainer(
      overrides: [storeProvider.overrideWithValue(store)],
    );
    final controller = container.read(studyProvider.notifier);
    controller.recordLessonSection('ar:t10:version', 2);
    controller.recordLessonSection('ar:t10:version', 7);
    expect(store.writes, 0);
    container.dispose();
    expect(store.writes, 1);
    expect(store.saved!['lessonPositions'], {'ar:t10:version': 7});
  });

  testWidgets('section writes coalesce and failed delayed writes can retry', (
    tester,
  ) async {
    final store = RecordingStore()..fail = true;
    final container = ProviderContainer(
      overrides: [storeProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    final controller = container.read(studyProvider.notifier);
    controller.recordLessonSection('ar:t10:version', 1);
    await tester.pump(const Duration(milliseconds: 300));
    controller.recordLessonSection('ar:t10:version', 3);
    await tester.pump(const Duration(milliseconds: 599));
    expect(store.writes, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(store.writes, 1);
    expect(container.read(studySaveStatusProvider), StudySaveStatus.failed);
    store.fail = false;
    controller.flushPending();
    expect(store.saved!['lessonPositions'], {'ar:t10:version': 3});
    expect(container.read(studySaveStatusProvider), StudySaveStatus.saved);
  });

  testWidgets('reader exit saves while deferring provider feedback', (
    tester,
  ) async {
    final store = RecordingStore();
    final container = ProviderContainer(
      overrides: [storeProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    final controller = container.read(studyProvider.notifier);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            ref.watch(studySaveStatusProvider);
            return _FlushOnDispose(controller);
          },
        ),
      ),
    );
    controller.recordLessonSection('ar:t10:version', 7);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(store.saved!['lessonPositions'], {'ar:t10:version': 7});
    expect(container.read(studySaveStatusProvider), StudySaveStatus.saved);
  });

  test('Undo restores only the removed record and rejects duplicates', () {
    final now = DateTime(2026, 11, 14);
    Note note(String id) => Note(
      id: id,
      edition: 'ar',
      page: 1,
      topicId: null,
      text: id,
      createdAt: now,
      updatedAt: now,
    );
    final original = note('original');
    final container = ProviderContainer(
      overrides: [
        initialStudyStateProvider.overrideWithValue(
          StudyState(notes: [original]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(studyProvider.notifier);
    controller.deleteNote(original.id);
    controller.restoreNote(note('other'));
    controller.restoreNote(original, index: 1);
    controller.restoreNote(original);
    expect(container.read(studyProvider).notes.map((n) => n.id), [
      'other',
      'original',
    ]);
  });
}

class _FlushOnDispose extends StatefulWidget {
  const _FlushOnDispose(this.controller);
  final StudyController controller;

  @override
  State<_FlushOnDispose> createState() => _FlushOnDisposeState();
}

class _FlushOnDisposeState extends State<_FlushOnDispose> {
  @override
  void dispose() {
    widget.controller.flush(deferStatus: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

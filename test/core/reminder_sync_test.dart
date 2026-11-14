import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/reminder.dart';
import 'package:rattil/features/study/study_state.dart';

class _ControlledReminders implements ReminderService {
  final calls = <String>[];
  Completer<void>? hold;
  bool fail = false;

  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> cancel() async {
    calls.add('cancel');
    if (fail) throw StateError('unavailable');
  }

  @override
  Future<void> scheduleDaily({
    required int minutes,
    required String title,
    required String body,
    required String channelName,
  }) async {
    calls.add('schedule:$minutes');
    await hold?.future;
    if (fail) throw StateError('unavailable');
  }
}

void main() {
  testWidgets(
    'an older pending schedule cannot win after turning reminders off',
    (tester) async {
      final service = _ControlledReminders()..hold = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          reminderServiceProvider.overrideWithValue(service),
          initialStudyStateProvider.overrideWithValue(
            const StudyState(reminderEnabled: true),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(reminderSyncProvider);
      await tester.pump();
      final study = container.read(studyProvider.notifier);
      study.setReminder(minutes: 600);
      study.setReminder(minutes: 700);
      study.setReminder(enabled: false);
      expect(service.calls, ['schedule:1200']);
      service.hold!.complete();
      await tester.pump();
      expect(service.calls, ['schedule:1200', 'cancel']);
      expect(container.read(reminderSyncProvider).hasError, isFalse);
      expect(container.read(reminderSyncProvider).isLoading, isFalse);
    },
  );

  testWidgets(
    'schedule failure is visible and retry reconciles current state',
    (tester) async {
      final service = _ControlledReminders()..fail = true;
      final container = ProviderContainer(
        overrides: [
          reminderServiceProvider.overrideWithValue(service),
          initialStudyStateProvider.overrideWithValue(
            const StudyState(reminderEnabled: true),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(reminderSyncProvider);
      await tester.pump();
      expect(container.read(reminderSyncProvider).hasError, isTrue);
      service.fail = false;
      container.read(reminderSyncProvider.notifier).retry();
      await tester.pump();
      expect(service.calls, ['schedule:1200', 'schedule:1200']);
      expect(container.read(reminderSyncProvider).hasError, isFalse);
    },
  );

  testWidgets('foreground entry refreshes the current reminder configuration', (
    tester,
  ) async {
    final service = _ControlledReminders();
    final container = ProviderContainer(
      overrides: [
        reminderServiceProvider.overrideWithValue(service),
        initialStudyStateProvider.overrideWithValue(
          const StudyState(reminderEnabled: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(reminderSyncProvider);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(service.calls, ['schedule:1200', 'schedule:1200']);
  });
}

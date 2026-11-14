import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:rattil/core/reminder.dart';
import 'package:rattil/features/study/study_state.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);
  test('tomorrow reminder retains wall-clock time across Cairo DST', () {
    final cairo = tz.getLocation('Africa/Cairo');
    final now = tz.TZDateTime(cairo, 2026, 4, 23, 21);
    final next = nextReminderTime(now, 20 * 60);
    expect(next.day, 24);
    expect(next.hour, 20);
    expect(next.minute, 0);
    expect(next.location, cairo);
    expect(next.isAfter(now), isTrue);
    // The timezone database has a spring offset change between these dates.
    expect(next.timeZoneOffset, isNot(now.timeZoneOffset));
  });
  test(
    'same-time request advances to tomorrow and midnight stays on its date',
    () {
      final zone = tz.getLocation('UTC');
      final now = tz.TZDateTime(zone, 2026, 11, 14, 20);
      expect(nextReminderTime(now, 20 * 60).day, 15);
      final midnight = nextReminderTime(now, 0);
      expect(midnight.day, 15);
      expect(midnight.hour, 0);
    },
  );
  test('streak uses calendar dates at month and leap-day boundaries', () {
    const state = StudyState(
      studyDays: {'2024-02-28', '2024-02-29', '2024-03-01'},
    );
    expect(state.currentStreak(DateTime(2024, 3, 1)), 3);
    expect(state.currentStreak(DateTime(2024, 3, 2)), 3);
    expect(state.currentStreak(DateTime(2024, 3, 3)), 0);
  });
}

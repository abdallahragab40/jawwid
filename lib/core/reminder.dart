import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../app/branding.dart';
import '../content/language.dart';
import '../features/study/study_state.dart';
import '../l10n/generated/app_localizations.dart';

/// Schedules the optional daily study reminder. Everything happens on the
/// device: a single repeating local notification, no network.
abstract class ReminderService {
  /// Asks the system for permission to show notifications. Returns false if
  /// the learner declined.
  Future<bool> requestPermission();

  /// Replaces any scheduled reminder with one at [minutes] after midnight,
  /// repeating daily.
  Future<void> scheduleDaily({
    required int minutes,
    required String title,
    required String body,
    required String channelName,
  });

  Future<void> cancel();
}

class LocalReminderService implements ReminderService {
  static const _id = 1;
  static const _channelId = 'daily_reminder';
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Unknown zone name: fall back to UTC; the time may be off by the
      // zone offset, which is better than not scheduling at all.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? true;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? true;
  }

  @override
  Future<void> scheduleDaily({
    required int minutes,
    required String title,
    required String body,
    required String channelName,
  }) async {
    await _init();
    await _plugin.cancel(id: _id);
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _id,
      title: title,
      body: body,
      scheduledDate: at,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Inexact: no special alarm permission; a few minutes' drift is fine.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() async {
    await _init();
    await _plugin.cancel(id: _id);
  }
}

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => LocalReminderService(),
);

/// Keeps the scheduled notification in line with the settings: re-schedules
/// when the time or the language changes, cancels when turned off, and
/// refreshes once at start-up (time zone may have changed).
final reminderSyncProvider = Provider<void>((ref) {
  void sync(({bool on, int minutes, AppLanguage lang}) s) {
    final service = ref.read(reminderServiceProvider);
    void report(Object e, StackTrace st) =>
        debugPrint('Daily reminder could not be updated: $e');
    if (!s.on) {
      service.cancel().catchError(report);
      return;
    }
    final l10n = lookupAppLocalizations(Locale(s.lang.code));
    service
        .scheduleDaily(
          minutes: s.minutes,
          title: Branding.name(s.lang),
          body: l10n.reminderBody,
          channelName: l10n.reminderChannel,
        )
        .catchError(report);
  }

  ref.listen(
    studyProvider.select(
      (s) =>
          (on: s.reminderEnabled, minutes: s.reminderMinutes, lang: s.language),
    ),
    (prev, next) {
      if (prev != next) sync(next);
    },
    fireImmediately: true,
  );
});

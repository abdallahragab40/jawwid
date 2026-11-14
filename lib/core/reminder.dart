import 'dart:async';

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

/// Next local wall-clock occurrence, preserving the clock time across DST.
tz.TZDateTime nextReminderTime(tz.TZDateTime now, int minutes) {
  RangeError.checkValueInInterval(minutes, 0, 24 * 60 - 1, 'minutes');
  tz.TZDateTime onDay(int offset) => tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day + offset,
    minutes ~/ 60,
    minutes % 60,
  );
  final today = onDay(0);
  return today.isAfter(now) ? today : onDay(1);
}

class LocalReminderService implements ReminderService {
  static const _id = 1;
  static const _channelId = 'daily_reminder';
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  Future<void> _init() =>
      _initialization ??= _initialize().catchError((Object error) {
        _initialization = null;
        throw error;
      });

  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
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
    // Refresh for every reconciliation, including foreground entry after travel.
    // Failure is surfaced rather than silently scheduling at the wrong UTC time.
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.cancel(id: _id);
    final now = tz.TZDateTime.now(tz.local);
    final at = nextReminderTime(now, minutes);
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

typedef ReminderConfiguration = ({bool on, int minutes, AppLanguage lang});

/// Reconciles one configuration at a time. Changes during an operation are
/// coalesced and applied afterwards, so an old schedule can never win last.
final reminderSyncProvider =
    NotifierProvider<ReminderSyncController, AsyncValue<void>>(
      ReminderSyncController.new,
    );

class ReminderSyncController extends Notifier<AsyncValue<void>> {
  late ReminderService _service;
  ReminderConfiguration? _pending;
  bool _running = false;
  bool _disposed = false;
  int _revision = 0;

  ReminderConfiguration _configuration() {
    final study = ref.read(studyProvider);
    return (
      on: study.reminderEnabled,
      minutes: study.reminderMinutes,
      lang: study.language,
    );
  }

  @override
  AsyncValue<void> build() {
    _service = ref.read(reminderServiceProvider);
    ref.onDispose(() => _disposed = true);
    final lifecycle = AppLifecycleListener(onResume: retry);
    ref.onDispose(lifecycle.dispose);
    ref.listen(
      studyProvider.select(
        (s) => (
          on: s.reminderEnabled,
          minutes: s.reminderMinutes,
          lang: s.language,
        ),
      ),
      (_, next) => _request(next),
    );
    // Avoid changing provider state while it is being initialized.
    scheduleMicrotask(() {
      if (!_disposed) retry();
    });
    return const AsyncData(null);
  }

  void retry() {
    if (!_disposed) _request(_configuration());
  }

  void _request(ReminderConfiguration configuration) {
    _pending = configuration;
    _revision++;
    state = const AsyncLoading();
    if (!_running) unawaited(_drain());
  }

  Future<void> _drain() async {
    _running = true;
    while (!_disposed && _pending != null) {
      final configuration = _pending!;
      final revision = _revision;
      _pending = null;
      try {
        if (!configuration.on) {
          await _service.cancel();
        } else {
          final l10n = lookupAppLocalizations(configuration.lang.locale);
          await _service.scheduleDaily(
            minutes: configuration.minutes,
            title: Branding.name(configuration.lang),
            body: l10n.reminderBody,
            channelName: l10n.reminderChannel,
          );
        }
        if (!_disposed && revision == _revision) state = const AsyncData(null);
      } catch (error, stack) {
        if (!_disposed && revision == _revision) {
          state = AsyncError(error, stack);
        }
      }
    }
    _running = false;
  }
}

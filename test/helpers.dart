import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app/app.dart';
import 'package:rattil/content/content_repository.dart';
import 'package:rattil/content/models.dart';
import 'package:rattil/core/json_store.dart';
import 'package:rattil/core/reminder.dart';
import 'package:rattil/features/practice/quiz_screen.dart';
import 'package:rattil/features/reader/reader_screen.dart';
import 'package:rattil/features/study/study_state.dart';

Map<String, dynamic> _read(String name) =>
    jsonDecode(File('assets/content/$name').readAsStringSync())
        as Map<String, dynamic>;

ContentRepository? _preview;
ContentRepository? _release;

/// The real bundled content, parsed from the asset files.
ContentRepository loadContent({
  ContentChannel channel = ContentChannel.preview,
}) {
  ContentRepository build() => ContentRepository.fromJson(
    editions: _read('editions.json'),
    curriculum: _read('curriculum.json'),
    rules: _read('rules.json'),
    quiz: _read('quiz.json'),
    makharij: _read('makharij.json'),
    quran: _read('quran.json'),
    searchTerms: _read('search_terms.json'),
    searchPages: _read('search_pages.json'),
    lessons: {
      for (final l in const ['ar', 'ckb', 'en', 'id'])
        l: _read('lessons_$l.json'),
    },
    channel: channel,
  );
  return channel == ContentChannel.preview
      ? (_preview ??= build())
      : (_release ??= build());
}

Directory tempDir() => Directory.systemTemp.createTempSync('rattil_test_');

/// Records what the reader was asked to show, instead of rendering a PDF.
class ReaderProbe {
  String? edition;
  int? page;
  ValueChanged<int>? goTo;

  Widget build(Edition e, int p, ValueChanged<int> onPage, VoidCallback onTap) {
    edition = e.id;
    page = p;
    goTo = onPage;
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: Colors.white,
        child: Center(
          child: Text('PDF ${e.id} #$p', key: const Key('reader-probe')),
        ),
      ),
    );
  }
}

/// Pumps the full app with real content, an optional on-disk store and a
/// reader probe in place of the native PDF view.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  JsonStore? store,
  ReaderProbe? probe,
  ContentChannel channel = ContentChannel.preview,
  StudyState? initial,
  Size size = const Size(400, 860),
  FakeReminders? reminders,
  Random? random,
  bool welcomed = true,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final stored =
      initial ??
      (store == null
          ? const StudyState()
          : StudyState.fromJson(store.loadSync()));
  // Tests start past the first-launch welcome unless they ask for it.
  final loaded = welcomed ? stored.copyWith(welcomed: true) : stored;
  final container = ProviderContainer(
    overrides: [
      contentProvider.overrideWithValue(loadContent(channel: channel)),
      storeProvider.overrideWithValue(store),
      initialStudyStateProvider.overrideWithValue(loaded),
      if (probe != null)
        pageViewSubstituteProvider.overrideWithValue(probe.build),
      reminderServiceProvider.overrideWithValue(reminders ?? FakeReminders()),
      if (random != null) quizRandomProvider.overrideWithValue(random),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const RattilApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Loads the bundled fonts so rendered text uses the real typefaces
/// (by default widget tests use a placeholder font).
Future<void> loadAppFonts() async {
  const families = {
    'NotoNaskhArabic': [
      'NotoNaskhArabic-w400.ttf',
      'NotoNaskhArabic-w500.ttf',
      'NotoNaskhArabic-w700.ttf',
    ],
    'NotoSansArabic': [
      'NotoSansArabic-w400.ttf',
      'NotoSansArabic-w500.ttf',
      'NotoSansArabic-w600.ttf',
      'NotoSansArabic-w700.ttf',
    ],
    'Amiri': ['Amiri-Regular.ttf', 'Amiri-Bold.ttf'],
    'AmiriQuran': ['AmiriQuran-Regular.ttf'],
    'Literata': ['Literata-w400.ttf', 'Literata-w600.ttf', 'Literata-w700.ttf'],
    'Inter': [
      'Inter-w400.ttf',
      'Inter-w500.ttf',
      'Inter-w600.ttf',
      'Inter-w700.ttf',
    ],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final f in e.value) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }
  // Material icons for realistic chrome.
  final iconFont = File(
    '${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (iconFont.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(
          Future.value(ByteData.sublistView(iconFont.readAsBytesSync())),
        ))
        .load();
  }
}

/// Records reminder calls instead of talking to the notifications plugin.
class FakeReminders implements ReminderService {
  FakeReminders({this.granted = true});
  bool granted;
  int? scheduledMinutes;
  String? scheduledBody;
  int cancels = 0;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<void> scheduleDaily({
    required int minutes,
    required String title,
    required String body,
    required String channelName,
  }) async {
    scheduledMinutes = minutes;
    scheduledBody = body;
  }

  @override
  Future<void> cancel() async {
    scheduledMinutes = null;
    cancels++;
  }
}

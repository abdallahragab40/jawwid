import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/branding.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../content/language.dart';
import '../../core/haptics.dart';
import '../../core/reminder.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/ornaments.dart';
import '../study/study_state.dart';
import '../../widgets/text_size_control.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    Widget tile(
      IconData icon,
      String title,
      String? subtitle,
      VoidCallback onTap,
    ) => ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        textDirection: Directionality.of(context),
      ),
      onTap: onTap,
    );
    void push(Widget w, String name) => Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: name),
        builder: (_) => w,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Column(
              children: [
                tile(
                  Icons.auto_stories_outlined,
                  l10n.bookTitle,
                  l10n.bookSubtitle(
                    editionName(l10n, ref.watch(languageProvider).editionId),
                  ),
                  () => openBook(context),
                ),
                const Divider(indent: 56),
                tile(
                  Icons.record_voice_over_outlined,
                  l10n.makharijTitle,
                  l10n.makharijSubtitle,
                  () => openMakharij(context),
                ),
                const Divider(indent: 56),
                tile(
                  Icons.search,
                  l10n.searchTitle,
                  null,
                  () => openSearch(context),
                ),
                const Divider(indent: 56),
                tile(
                  Icons.bookmarks_outlined,
                  l10n.bookmarksAndNotes,
                  null,
                  () => push(const BookmarksNotesScreen(), 'bookmarks'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                tile(
                  Icons.tune,
                  l10n.settingsTitle,
                  null,
                  () => push(const SettingsScreen(), 'settings'),
                ),
                const Divider(indent: 56),
                tile(
                  Icons.info_outline,
                  l10n.aboutTitle,
                  null,
                  () => push(const AboutScreen(), 'about'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookmarksNotesScreen extends ConsumerWidget {
  const BookmarksNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);
    final study = ref.watch(studyProvider);
    final ctl = ref.read(studyProvider.notifier);

    String where(String edition, int page) {
      final topics = content.topicsAtPage(edition, page);
      return [
        editionName(l10n, edition),
        printedPageLabel(l10n, content.editions[edition]!, page, lang),
        if (topics.isNotEmpty) topicTitle(topics.first, lang),
      ].join(' · ');
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookmarksAndNotes),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.bookmarksTab),
              Tab(text: l10n.notesTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            study.bookmarks.isEmpty
                ? _Empty(text: l10n.bookmarksEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: study.bookmarks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final b = study.bookmarks[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: Text(where(b.edition, b.page)),
                          subtitle: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(b.createdAt),
                          ),
                          trailing: IconButton(
                            tooltip: l10n.actionDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ctl.removeBookmark(b.id),
                          ),
                          onTap: () => openReader(
                            context,
                            edition: b.edition,
                            page: b.page,
                          ),
                        ),
                      );
                    },
                  ),
            study.notes.isEmpty
                ? _Empty(text: l10n.notesEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: study.notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final note = study.notes[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                note.text,
                                style: context.type.prose(size: 15.5),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                where(note.edition, note.page),
                                style: context.type.muted(size: 12.5),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => openReader(
                                      context,
                                      edition: note.edition,
                                      page: note.page,
                                    ),
                                    child: Text(l10n.notesOpenPage),
                                  ),
                                  IconButton(
                                    tooltip: l10n.notesEdit,
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () async {
                                      final c = TextEditingController(
                                        text: note.text,
                                      );
                                      final v = await showDialog<String>(
                                        context: context,
                                        builder: (d) => AlertDialog(
                                          title: Text(l10n.notesEdit),
                                          content: TextField(
                                            controller: c,
                                            minLines: 2,
                                            maxLines: 6,
                                            autofocus: true,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(d),
                                              child: Text(l10n.actionCancel),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.pop(
                                                d,
                                                c.text.trim(),
                                              ),
                                              child: Text(l10n.actionSave),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (v != null && v.isNotEmpty) {
                                        ctl.updateNote(note.id, v);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    tooltip: l10n.actionDelete,
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => ctl.deleteNote(note.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Rosette(size: 36),
          const SizedBox(height: 12),
          Text(
            text,
            style: context.type.muted(size: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(studyProvider);
    final ctl = ref.read(studyProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          SectionHeading(l10n.settingsLanguage),
          Text(l10n.settingsLanguageHint, style: context.type.muted(size: 13)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final (i, l) in AppLanguage.values.indexed) ...[
                  if (i > 0) const Divider(indent: 16),
                  ListTile(
                    title: Text(
                      l.nativeName,
                      textDirection: l.direction,
                      style: TextStyle(
                        fontFamily: l.usesArabicScript
                            ? 'NotoSansArabic'
                            : 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: s.language == l
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    selected: s.language == l,
                    onTap: () => ctl.setLanguage(l),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeading(l10n.settingsAppearance),
          SegmentedButton<AppThemeChoice>(
            segments: [
              ButtonSegment(
                value: AppThemeChoice.system,
                icon: const Icon(Icons.brightness_auto_outlined),
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: AppThemeChoice.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: AppThemeChoice.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {s.appTheme},
            onSelectionChanged: (v) => ctl.setAppTheme(v.first),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.settingsTextSize,
            style: context.type.ui(size: 15, weight: FontWeight.w600),
          ),
          LessonTextSizeControl(
            value: s.lessonTextScale,
            onChanged: ctl.setLessonTextScale,
          ),
          const SizedBox(height: 16),
          SectionHeading(l10n.readerAppearance),
          SegmentedButton<ReaderTheme>(
            segments: [
              ButtonSegment(
                value: ReaderTheme.light,
                label: Text(l10n.readerThemeLight),
              ),
              ButtonSegment(
                value: ReaderTheme.sepia,
                label: Text(l10n.readerThemeSepia),
              ),
              ButtonSegment(
                value: ReaderTheme.night,
                label: Text(l10n.readerThemeNight),
              ),
            ],
            selected: {s.readerTheme},
            onSelectionChanged: (v) => ctl.setReaderTheme(v.first),
          ),
          if (s.readerTheme == ReaderTheme.night)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.dimNightPages,
              onChanged: ctl.setDimNightPages,
              title: Text(l10n.readerDimPages),
              subtitle: Text(l10n.readerDimPagesHint),
            ),
          const SizedBox(height: 6),
          Text(l10n.readerColorsNote, style: context.type.muted(size: 12.5)),
          const SizedBox(height: 16),
          SectionHeading(l10n.settingsStudy),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: s.reminderEnabled,
                  onChanged: (on) async {
                    ref.read(hapticsProvider).toggle();
                    if (!on) {
                      ctl.setReminder(enabled: false);
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    final granted = await ref
                        .read(reminderServiceProvider)
                        .requestPermission();
                    if (granted) {
                      ctl.setReminder(enabled: true);
                    } else {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.settingsReminderDenied)),
                      );
                    }
                  },
                  secondary: const Icon(Icons.notifications_outlined),
                  title: Text(l10n.settingsReminder),
                  subtitle: Text(l10n.settingsReminderHint),
                ),
                if (s.reminderEnabled)
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(l10n.settingsReminderTime),
                    trailing: Text(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                        TimeOfDay(
                          hour: s.reminderMinutes ~/ 60,
                          minute: s.reminderMinutes % 60,
                        ),
                      ),
                      style: context.type.ui(size: 15, weight: FontWeight.w600),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: s.reminderMinutes ~/ 60,
                          minute: s.reminderMinutes % 60,
                        ),
                      );
                      if (picked != null) {
                        ctl.setReminder(
                          minutes: picked.hour * 60 + picked.minute,
                        );
                      }
                    },
                  ),
                const Divider(height: 1),
                SwitchListTile(
                  value: s.hapticsEnabled,
                  onChanged: (on) {
                    ctl.setHapticsEnabled(on);
                    if (on) ref.read(hapticsProvider).toggle();
                  },
                  secondary: const Icon(Icons.vibration),
                  title: Text(l10n.settingsHaptics),
                  subtitle: Text(l10n.settingsHapticsHint),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: s.streakEnabled,
                  onChanged: ctl.setStreakEnabled,
                  secondary: const Icon(Icons.eco_outlined),
                  title: Text(l10n.settingsStreak),
                  subtitle: Text(l10n.settingsStreakHint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.settingsOffline, style: context.type.muted(size: 12.5)),
        ],
      ),
    );
  }
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageProvider);
    final content = ref.watch(contentProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Row(
            children: [
              const Rosette(size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Branding.name(lang),
                      style: context.type
                          .heading(size: 26)
                          .copyWith(fontFamily: Branding.nameFontFamily(lang)),
                    ),
                    Text(
                      Branding.subtitleFor(lang),
                      style: context.type.muted(size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.aboutBody, style: context.type.prose(size: 15.5)),
          const OrnamentDivider(),
          SectionHeading(l10n.aboutBooks),
          for (final id in const ['ar', 'ckb', 'en', 'id'])
            Builder(
              builder: (context) {
                final e = content.editions[id]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${editionName(l10n, id)} — ${e.title}'),
                    subtitle: Text(
                      [
                        l10n.aboutAuthor(e.author),
                        if (e.translator != null)
                          l10n.aboutTranslator(e.translator!),
                        e.level,
                      ].join('\n'),
                    ),
                    isThreeLine: e.translator != null,
                  ),
                );
              },
            ),
          const SizedBox(height: 6),
          Text(l10n.aboutDistribution, style: context.type.ui(size: 13.5)),
          const SizedBox(height: 4),
          Text(l10n.aboutUnchanged, style: context.type.muted(size: 12.5)),
          const OrnamentDivider(),
          SectionHeading(l10n.aboutQuranText),
          Text(l10n.aboutTanzil, style: context.type.ui(size: 13.5)),
          const OrnamentDivider(),
          SectionHeading(l10n.aboutPrivacyTitle),
          Text(l10n.aboutPrivacy, style: context.type.ui(size: 13.5)),
          const OrnamentDivider(),
          SectionHeading(l10n.aboutSupplementary),
          Text(l10n.aboutSupplementaryBody, style: context.type.ui(size: 13.5)),
          if (content.isPreview) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: PreviewBadge(l10n.previewBadge),
            ),
            const SizedBox(height: 4),
            Text(l10n.previewExplanation, style: context.type.muted(size: 12)),
          ],
          const OrnamentDivider(),
          SectionHeading(l10n.aboutFonts),
          Text(l10n.aboutFontsBody, style: context.type.ui(size: 13.5)),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: Branding.name(lang),
              applicationVersion: content.contentVersion,
            ),
            child: Text(l10n.aboutLicenses),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.aboutContentVersion(content.contentVersion),
            style: context.type.muted(size: 12),
          ),
        ],
      ),
    );
  }
}

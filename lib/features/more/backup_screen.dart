import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/study_backup.dart';
import '../../core/backup_files.dart';
import '../../core/numerals.dart';
import '../../l10n/generated/app_localizations.dart';
import '../study/study_state.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key, this.recoveryMode = false});
  final bool recoveryMode;

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _input = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _saveFile() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final now = ref.read(clockProvider)();
      final saved = await ref
          .read(backupFilesProvider)
          .save(
            encodeStudyBackup(ref.read(studyProvider), exportedAt: now),
            name: 'jawwid-backup-${StudyState.dayKey(now)}.json',
            title: l10n.backupSaveFile,
          );
      if (saved && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.backupFileSaved)));
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.backupFileError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openFile() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final text = await ref
          .read(backupFilesProvider)
          .open(title: l10n.backupOpenFile);
      if (text == null || !mounted) return;
      _input.text = text;
      await _restore();
    } on FormatException {
      if (mounted) setState(() => _error = l10n.backupInvalid);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.backupFileError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    final StudyBackup backup;
    try {
      backup = decodeStudyBackupEnvelope(
        _input.text,
        content: ref.read(contentProvider),
      );
    } catch (_) {
      setState(() => _error = l10n.backupInvalid);
      return;
    }
    final restored = backup.state;
    setState(() => _error = null);
    final localizations = MaterialLocalizations.of(context);
    final date = backup.exportedAt?.toLocal();
    final dateLabel = date == null
        ? l10n.backupUnknownDate
        : '${localizations.formatFullDate(date)} ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
    final lang = ref.read(languageProvider).code;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupRestore),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.backupSummary(
                localizeDigits(dateLabel, lang),
                localizeDigits('${restored.notes.length}', lang),
                localizeDigits('${restored.bookmarks.length}', lang),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.backupConfirm),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.backupRestore),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // Notification permission belongs to this device, not the exported file.
    try {
      ref.read(studyProvider.notifier).restoreBackup(restored);
    } catch (_) {
      setState(() => _error = l10n.backupWriteFailed);
      return;
    }
    _input.clear();
    if (widget.recoveryMode) {
      Navigator.of(context).pop(true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).backupRestored)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.recoveryMode ? l10n.backupRecoveryIntro : l10n.backupIntro,
          ),
          const SizedBox(height: 16),
          if (!widget.recoveryMode) ...[
            FilledButton.icon(
              icon: const Icon(Icons.save_alt),
              label: Text(l10n.backupSaveFile),
              onPressed: _busy ? null : _saveFile,
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.backupOpenFile),
            onPressed: _busy ? null : _openFile,
          ),
          const SizedBox(height: 16),
          if (!widget.recoveryMode)
            FilledButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(l10n.backupCopy),
              onPressed: _busy
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: encodeStudyBackup(ref.read(studyProvider)),
                        ),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.contactCopied)),
                      );
                    },
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _input,
            minLines: 5,
            maxLines: 10,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.backupRestore,
              alignLabelWithHint: true,
              errorText: _error,
              errorMaxLines: 4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.restore),
            onPressed: _busy ? null : _restore,
            label: Text(l10n.backupRestore),
          ),
        ],
      ),
    );
  }
}

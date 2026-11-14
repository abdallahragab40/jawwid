import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

/// Owns its controller until the dialog route finishes its exit animation.
class NoteEditorDialog extends StatefulWidget {
  const NoteEditorDialog({
    super.key,
    this.initialText = '',
    this.editing = false,
  });
  final String initialText;
  final bool editing;

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  late final _text = TextEditingController(text: widget.initialText);
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.editing ? l10n.notesEdit : l10n.notesAdd),
      content: TextField(
        controller: _text,
        autofocus: true,
        minLines: 2,
        maxLines: 6,
        maxLength: 3000,
        decoration: InputDecoration(hintText: l10n.notesHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _text.text.trim()),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

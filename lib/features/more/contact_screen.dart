import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';

const feedbackEmail = 'abdallahragab40@gmail.com';
const supportNumber = '01159478583';
const vodafoneNumber = '01097562535';
const instapayAddress = 'abdallah-ragab@instapay';
const instapayLink = 'https://ipn.eg/S/abdallah-ragab/instapay/8Mz0rK';

Uri feedbackUri(String subject, String message) => Uri(
  scheme: 'mailto',
  path: feedbackEmail,
  query:
      'subject=${Uri.encodeComponent('Jawwid: $subject')}'
      '&body=${Uri.encodeComponent(message)}',
);

Future<void> _copy(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).contactCopied)),
  );
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _opening = false;
  bool _failed = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _opening = true);
    var opened = false;
    try {
      opened = await launchUrl(
        feedbackUri(_subject.text.trim(), _message.text.trim()),
      );
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    setState(() {
      _opening = false;
      _failed = !opened;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? required(String? value) =>
        value == null || value.trim().isEmpty ? l10n.feedbackRequired : null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      body: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.feedbackIntro),
            const SizedBox(height: 20),
            Text(feedbackEmail, textDirection: TextDirection.ltr),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _copy(context, feedbackEmail),
                icon: const Icon(Icons.copy_outlined),
                label: Text(l10n.contactCopyEmail),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subject,
              decoration: InputDecoration(labelText: l10n.feedbackSubject),
              validator: required,
              maxLength: 120,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _message,
              decoration: InputDecoration(labelText: l10n.feedbackMessage),
              validator: required,
              minLines: 6,
              maxLines: 12,
              maxLength: 3000,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _opening ? null : _send,
              icon: const Icon(Icons.email_outlined),
              label: Text(l10n.feedbackSend),
            ),
            if (_failed) ...[
              const SizedBox(height: 16),
              Text(l10n.feedbackFallback),
            ],
            TextButton.icon(
              onPressed: () => _copy(
                context,
                '${_subject.text.trim()}\n\n${_message.text.trim()}',
              ),
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.feedbackCopy),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _openInstapay(BuildContext context) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(instapayLink),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).supportLinkFailed)),
    );
  }

  Widget _wallet(BuildContext context, String name, String number) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name),
          const SizedBox(height: 12),
          Text(
            number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _copy(context, number),
            icon: const Icon(Icons.copy_outlined),
            label: Text(AppLocalizations.of(context).supportCopyNumber),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            Icons.local_cafe_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(l10n.supportIntro),
          const SizedBox(height: 24),
          Text(l10n.supportTransfer),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('InstaPay', textDirection: TextDirection.ltr),
                  const SizedBox(height: 12),
                  const Text(
                    instapayAddress,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _openInstapay(context),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.supportOpenInstapay),
                  ),
                  TextButton.icon(
                    onPressed: () => _copy(context, instapayAddress),
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(l10n.supportCopyAddress),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _wallet(context, l10n.supportEtisalat, supportNumber),
          const SizedBox(height: 12),
          _wallet(context, l10n.supportVodafone, vodafoneNumber),
          const SizedBox(height: 16),
          Text(l10n.supportVerify),
        ],
      ),
    );
  }
}

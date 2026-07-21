/// Ein Dialog mit einem einzelnen Eingabefeld.
///
/// Als eigenes Widget, damit der [TextEditingController] an dessen Lebensdauer
/// hängt. Wird er stattdessen direkt nach `showDialog` entsorgt, ist das
/// Textfeld beim Schließen noch im Baum und Flutter bricht mit
/// „_dependents.isEmpty is not true“ ab.
library;

import 'package:flutter/material.dart';

class TextPromptDialog extends StatefulWidget {
  const TextPromptDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.label = 'Name',
    this.initial = '',
    this.keyboardType,
    this.confirmLabel = 'Speichern',
  });

  final String title;
  final String? subtitle;
  final String label;
  final String initial;
  final TextInputType? keyboardType;
  final String confirmLabel;

  @override
  State<TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<TextPromptDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.subtitle case final subtitle?) ...[
            Text(subtitle),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// Fragt nach einem Text. Liefert `null` bei Abbruch oder leerer Eingabe.
Future<String?> askForText(
  BuildContext context, {
  required String title,
  String? subtitle,
  String label = 'Name',
  String initial = '',
  String confirmLabel = 'Speichern',
}) async {
  final value = await showDialog<String>(
    context: context,
    builder: (_) => TextPromptDialog(
      title: title,
      subtitle: subtitle,
      label: label,
      initial: initial,
      confirmLabel: confirmLabel,
    ),
  );
  return (value == null || value.isEmpty) ? null : value;
}

/// Fragt nach einer Jahreszahl. Liefert `null` bei Abbruch oder Unsinn.
Future<int?> askForYear(
  BuildContext context, {
  required String title,
  String? subtitle,
  int? initial,
}) async {
  final value = await showDialog<String>(
    context: context,
    builder: (_) => TextPromptDialog(
      title: title,
      subtitle: subtitle,
      label: 'Erscheinungsjahr',
      initial: initial?.toString() ?? '',
      keyboardType: TextInputType.number,
      confirmLabel: 'Übernehmen',
    ),
  );
  return value == null ? null : int.tryParse(value);
}

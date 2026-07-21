/// Ordnet einer gescannten Karte von Hand einen Song zu.
///
/// Für Karten, die in keiner geladenen Ausgabe stehen. Die Angaben stehen auf
/// der Kartenrückseite; nachgeschlagen wird nichts — die App fragt außer
/// YouTube und der Quelle der Kartenlisten keinen Dienst.
library;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/models.dart';
import '../../scan/card_list_import.dart';

class AssignCardDialog extends StatefulWidget {
  const AssignCardDialog({super.key, required this.cardNumber});

  final String cardNumber;

  @override
  State<AssignCardDialog> createState() => _AssignCardDialogState();
}

class _AssignCardDialogState extends State<AssignCardDialog> {
  final _title = TextEditingController();
  final _artist = TextEditingController();
  final _year = TextEditingController();
  final _videoUrl = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _year.dispose();
    _videoUrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _title.text.trim().isNotEmpty &&
      _artist.text.trim().isNotEmpty &&
      int.tryParse(_year.text.trim()) != null;

  void _save() {
    final videoId = youtubeVideoId(_videoUrl.text.trim());

    Navigator.of(context).pop(Song(
      id: const Uuid().v4(),
      title: _title.text.trim(),
      artist: _artist.text.trim(),
      year: int.parse(_year.text.trim()),
      // Vom Menschen von der Karte abgelesen — das wiegt schwerer als jede
      // automatische Auflösung.
      yearSource: YearSource.card,
      providerIds:
          videoId == null ? const {} : {MusicService.youtube: videoId},
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Karte ${widget.cardNumber} zuordnen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Titel, Künstler und Jahr stehen auf der Rückseite der Karte.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            _Field(controller: _title, label: 'Titel', autofocus: true,
                onChanged: () => setState(() {})),
            const SizedBox(height: 8),
            _Field(controller: _artist, label: 'Künstler',
                onChanged: () => setState(() {})),
            const SizedBox(height: 8),
            _Field(controller: _year, label: 'Jahr', numeric: true,
                onChanged: () => setState(() {})),
            const SizedBox(height: 8),
            _Field(
              controller: _videoUrl,
              label: 'YouTube-Adresse (freiwillig)',
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 4),
            Text(
              'Ohne Adresse lässt sich die Karte zuordnen, aber nicht '
              'abspielen.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: const Text('Zuordnen'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.numeric = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;
  final bool numeric;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: numeric ? TextInputType.number : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) => onChanged(),
    );
  }
}

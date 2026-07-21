/// Eine Kartenausgabe hinzufügen.
///
/// Zwei Wege: eine der mitgelieferten Ausgaben auswählen, oder eine eigene
/// Liste einlesen — als Datei, über eine Adresse oder aus der Zwischenablage.
library;

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../app_dependencies.dart';
import '../../scan/card_mapping_store.dart';
import '../../scan/card_set_catalog.dart';

class AddCardSetScreen extends StatefulWidget {
  const AddCardSetScreen({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<AddCardSetScreen> createState() => _AddCardSetScreenState();
}

class _AddCardSetScreenState extends State<AddCardSetScreen> {
  final _name = TextEditingController();
  final _language = TextEditingController(text: 'de');
  final _sku = TextEditingController();
  final _url = TextEditingController();

  bool _busy = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _name.dispose();
    _language.dispose();
    _sku.dispose();
    _url.dispose();
    super.dispose();
  }

  void _report(ImportOutcome outcome) {
    if (!mounted) return;

    setState(() {
      _messageIsError = outcome.isFailure;
      _message = outcome.isFailure
          ? outcome.error
          : '${outcome.imported} Karten übernommen'
              '${outcome.skipped > 0 ? ", ${outcome.skipped} Zeilen übersprungen" : ""}.';
    });

    if (!outcome.isFailure) Navigator.of(context).pop();
  }

  Future<void> _installFromCatalog(CatalogEntry entry) async {
    setState(() {
      _busy = true;
      _message = null;
    });

    final outcome = await widget.deps.cardSets.installFromCatalog(entry);

    if (mounted) setState(() => _busy = false);
    _report(outcome);
  }

  /// Angaben, die für eine eigene Ausgabe nötig sind.
  String? get _ownSetBlocker {
    if (_name.text.trim().isEmpty) return 'Die Ausgabe braucht einen Namen.';
    if (_language.text.trim().isEmpty) {
      return 'Ohne Sprache lassen sich die Karten nicht zuordnen.';
    }
    return null;
  }

  Future<void> _installOwn({String? csv, Uri? url}) async {
    final blocker = _ownSetBlocker;
    if (blocker != null) {
      setState(() {
        _message = blocker;
        _messageIsError = true;
      });
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });

    final sku = _sku.text.trim();
    final outcome = url != null
        ? await widget.deps.cardSets.installFromUrl(
            id: const Uuid().v4(),
            name: _name.text.trim(),
            language: _language.text.trim(),
            sku: sku.isEmpty ? null : sku,
            url: url,
          )
        : await widget.deps.cardSets.installFromCsv(
            id: const Uuid().v4(),
            name: _name.text.trim(),
            language: _language.text.trim(),
            sku: sku.isEmpty ? null : sku,
            csv: csv!,
          );

    if (mounted) setState(() => _busy = false);
    _report(outcome);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
      withData: true,
    );

    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    // Namensvorschlag aus dem Dateinamen, falls noch keiner steht.
    if (_name.text.trim().isEmpty) {
      final fileName = result!.files.single.name;
      _name.text = fileName.replaceAll(RegExp(r'\.(csv|txt)$'), '');
    }

    // utf8.decode statt String.fromCharCodes: Letzteres nimmt jedes Byte für
    // ein Zeichen und zerlegt damit jeden Umlaut in zwei Wirrzeichen —
    // deutsche Titel und Künstlernamen kämen verstümmelt an.
    await _installOwn(csv: utf8.decode(bytes, allowMalformed: true));
  }

  Future<void> _fromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      setState(() {
        _message = 'In der Zwischenablage steht kein Text.';
        _messageIsError = true;
      });
      return;
    }
    await _installOwn(csv: text);
  }

  Future<void> _fromUrl() async {
    final url = Uri.tryParse(_url.text.trim());
    if (url == null || !url.hasScheme) {
      setState(() {
        _message = 'Das ist keine gültige Adresse.';
        _messageIsError = true;
      });
      return;
    }
    await _installOwn(url: url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ausgabe hinzufügen')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_busy) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              if (_message case final message?) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _messageIsError
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(message,
                      style: TextStyle(
                        color: _messageIsError
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onPrimaryContainer,
                      )),
                ),
                const SizedBox(height: 20),
              ],
              Text('Mitgelieferte Ausgaben',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Wird beim Auswählen geladen und dauerhaft gespeichert.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              for (final entry in cardSetCatalog)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_outlined),
                  title: Text(entry.name),
                  subtitle: Text(entry.sku == null
                      ? 'Grundausgabe · ${entry.language}'
                      : '${entry.language} · ${entry.sku}'),
                  onTap: _busy ? null : () => _installFromCatalog(entry),
                ),
              const Divider(height: 40),
              Text('Eigene Liste', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Eine CSV mit Kartennummer, Titel, Künstler und Jahr. Eine '
                'Spalte mit YouTube-Adressen wird mitgenommen, wenn '
                'vorhanden.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name der Ausgabe',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _language,
                      decoration: const InputDecoration(
                        labelText: 'Sprache',
                        helperText: 'wie im QR-Code',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _sku,
                      decoration: const InputDecoration(
                        labelText: 'Ausgabe',
                        helperText: 'leer bei Grundausgabe',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('CSV-Datei auswählen'),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _url,
                decoration: const InputDecoration(
                  labelText: 'oder Adresse einer CSV-Datei',
                  hintText: 'https://…/liste.csv',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _busy || _url.text.trim().isEmpty ? null : _fromUrl,
                      icon: const Icon(Icons.download),
                      label: const Text('Laden'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _fromClipboard,
                      icon: const Icon(Icons.paste),
                      label: const Text('Einfügen'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

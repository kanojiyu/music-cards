/// Einstellungen: wie die Wiedergabe startet und welche Ausgaben geladen sind.
library;

import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../scan/card_set_catalog.dart';
import '../../scan/card_set_store.dart';
import '../../settings/app_settings.dart';
import 'add_card_set_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings _settings = const AppSettings();
  List<CardSet> _sets = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final settings = await widget.deps.settings.read();
    final sets = await widget.deps.cardSets.all();
    if (mounted) {
      setState(() {
        _settings = settings;
        _sets = sets;
        _loading = false;
      });
    }
  }

  Future<void> _save(AppSettings settings) async {
    setState(() => _settings = settings);
    await widget.deps.settings.write(settings);
  }

  Future<void> _addSet() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddCardSetScreen(deps: widget.deps)),
    );
    await _reload();
  }

  Future<void> _removeSet(CardSet set) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('„${set.name}“ entfernen?'),
        content: Text('${set.cardCount} Karten werden gelöscht. Andere '
            'Ausgaben bleiben erhalten.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await widget.deps.cardSets.remove(set.id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Wiedergabe starten', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              // Auswahl und Umschaltung sitzen an der Gruppe, nicht an den
              // einzelnen Feldern — die frühere Form ist abgekündigt.
              RadioGroup<PlaybackTrigger>(
                groupValue: _settings.trigger,
                onChanged: (value) =>
                    _save(_settings.copyWith(trigger: value)),
                child: const Column(
                  children: [
                    RadioListTile<PlaybackTrigger>(
                      value: PlaybackTrigger.flip,
                      title: Text('Wenn das Handy umgedreht wird'),
                      subtitle: Text(
                          'Der Lagesensor erkennt, wann der Bildschirm nach '
                          'unten zeigt.'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<PlaybackTrigger>(
                      value: PlaybackTrigger.delay,
                      title: Text('Nach einer festen Wartezeit'),
                      subtitle: Text(
                          'Für Geräte, bei denen die Lageerkennung nicht '
                          'greift — etwa mit dicker Hülle.'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              if (_settings.trigger == PlaybackTrigger.delay)
                _DelayPicker(
                  seconds: _settings.delay.inSeconds,
                  onChanged: (seconds) =>
                      _save(_settings.copyWith(delay: Duration(seconds: seconds))),
                ),
              const Divider(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Text('Kartenausgaben',
                        style: theme.textTheme.titleMedium),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _addSet,
                    icon: const Icon(Icons.add),
                    label: const Text('Hinzufügen'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_sets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Noch keine Ausgabe geladen. Über „Hinzufügen“ eine '
                    'mitgelieferte Ausgabe wählen oder eine eigene Liste '
                    'einlesen.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              else
                for (final set in _sets)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.style),
                    title: Text(set.name),
                    subtitle: Text('${set.cardCount} Karten · '
                        '${set.language}${set.sku == null ? "" : " · ${set.sku}"}'),
                    trailing: IconButton(
                      tooltip: 'Entfernen',
                      onPressed: () => _removeSet(set),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
              const SizedBox(height: 32),
              Text(
                catalogAttribution,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DelayPicker extends StatelessWidget {
  const _DelayPicker({required this.seconds, required this.onChanged});

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Row(
        children: [
          Expanded(child: Text('Wartezeit: $seconds Sekunden')),
          IconButton(
            onPressed: seconds > 2 ? () => onChanged(seconds - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          IconButton(
            onPressed: seconds < 30 ? () => onChanged(seconds + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

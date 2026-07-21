/// Der Startbildschirm: spielen oder einstellen, sonst nichts.
///
/// Bewusst karg. Beim Spielen liegt das Gerät auf dem Tisch und wird
/// herumgereicht — jede zusätzliche Schaltfläche ist eine, die versehentlich
/// getroffen wird.
library;

import 'package:flutter/material.dart';

import '../app_dependencies.dart';
import 'scan/scan_flow_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cardCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final count = await widget.deps.cardMappings.count();
    if (mounted) setState(() => _cardCount = count);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(deps: widget.deps)),
    );
    await _refresh();
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanFlowScreen(deps: widget.deps)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = _cardCount > 0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  tooltip: 'Einstellungen',
                  iconSize: 28,
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Music Cards',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 48),
                    _PlayButton(onPressed: ready ? _play : null),
                    const SizedBox(height: 32),
                    if (ready)
                      Text('$_cardCount Karten bereit',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ))
                    else
                      _NoCardsHint(onOpenSettings: _openSettings),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Die eine Schaltfläche, um die es geht — großflächig genug, um sie ohne
/// Hinsehen zu treffen.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      label: 'Spielen',
      child: Material(
        color: enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Icon(
              Icons.play_arrow_rounded,
              size: 110,
              color: enabled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoCardsHint extends StatelessWidget {
  const _NoCardsHint({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Noch keine Karten geladen.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: onOpenSettings,
          icon: const Icon(Icons.download),
          label: const Text('Ausgabe wählen'),
        ),
      ],
    );
  }
}

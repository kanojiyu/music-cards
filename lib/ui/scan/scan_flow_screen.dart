/// Der Spielablauf: scannen, umdrehen, hören, auflösen.
///
/// Alles in einem Bildschirm, weil es eine zusammenhängende Handlung am Tisch
/// ist. Zwischenschritte mit Zurück-Knöpfen würden den Fluss zerreißen.
///
/// Der YouTube-Player läuft erst, wenn niemand hinsehen kann, und wird beim
/// Auflösen sichtbar. Verdeckt wird er nie — das untersagen die
/// Nutzungsbedingungen ausdrücklich.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../app_dependencies.dart';
import '../../core/models.dart';
import '../../scan/printed_card.dart';
import '../../scan/tilt_detector.dart';
import '../../settings/app_settings.dart';

/// Die Schritte des Ablaufs.
enum FlowStep {
  /// Kamera sucht einen Code.
  scanning,

  /// Karte erkannt, wartet auf das Umdrehen.
  recognized,

  /// Gerät liegt umgedreht, der Song läuft.
  playing,

  /// Aufgedeckt: Player oben, Angaben darunter.
  revealed,
}

class ScanFlowScreen extends StatefulWidget {
  const ScanFlowScreen({
    super.key,
    required this.deps,
    Stream<double>? tiltValues,
  }) : _tiltValues = tiltValues;

  final AppDependencies deps;

  /// Nur für Tests überschrieben; sonst kommt die Lage vom Sensor.
  final Stream<double>? _tiltValues;

  @override
  State<ScanFlowScreen> createState() => _ScanFlowScreenState();
}

class _ScanFlowScreenState extends State<ScanFlowScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _scanner;
  YoutubePlayerController? _player;
  StreamSubscription<bool>? _tilt;
  Timer? _delayTimer;

  FlowStep _step = FlowStep.scanning;
  Song? _song;
  String? _problem;
  AppSettings _settings = const AppSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startScanner();
    _loadSettings();

    final values = widget._tiltValues ??
        accelerometerEventStream().map((event) => event.z);
    _tilt = faceDownEvents(values).listen(_onFaceDownChanged);
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _tilt?.cancel();
    _scanner?.dispose();
    _player?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Baut die Kamera neu auf, wenn die App aus dem Hintergrund zurückkehrt.
  ///
  /// Android gibt die Kamera beim Wechsel in den Hintergrund frei; ohne
  /// Neuaufbau bliebe der Sucher danach schwarz.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_step != FlowStep.scanning) return;

    if (state == AppLifecycleState.resumed) {
      _disposeScanner().then((_) {
        if (!mounted) return;
        setState(_startScanner);
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _disposeScanner().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _loadSettings() async {
    final settings = await widget.deps.settings.read();
    if (mounted) setState(() => _settings = settings);
  }

  void _startScanner() {
    _scanner = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  /// Baut die Kamerasteuerung vollständig ab.
  ///
  /// Bewusst nicht nur `stop()`: Eine angehaltene und später wieder
  /// gestartete Steuerung liefert gelegentlich kein Bild mehr — der Sucher
  /// bleibt dann schwarz. Eine frische Steuerung je Durchgang vermeidet das.
  Future<void> _disposeScanner() async {
    final scanner = _scanner;
    _scanner = null;
    await scanner?.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_step != FlowStep.scanning) return;

    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((value) => value != null && value.isNotEmpty,
            orElse: () => null);
    if (value == null) return;

    final card = parsePrintedCard(value);
    final key = card.mappingKey;
    if (key == null) {
      setState(() => _problem = 'Diese Karte kennt die App nicht.');
      return;
    }

    final song = await widget.deps.cardMappings.songForCard(key);
    if (!mounted) return;

    if (song == null) {
      setState(() => _problem =
          'Karte ${card.number} ist keiner Ausgabe zugeordnet. Prüfe in den '
          'Einstellungen, ob die richtige Ausgabe geladen ist.');
      return;
    }

    // Kamera abbauen, sobald sie nicht mehr gebraucht wird — sie kostet
    // Strom und zeigt weiter das Bild der Karte.
    await _disposeScanner();

    setState(() {
      _song = song;
      _problem = null;
      _step = FlowStep.recognized;
    });

    _armDelayTrigger();
  }

  /// Startet bei fester Wartezeit den Zeitgeber.
  ///
  /// Der Ausweg für Geräte, bei denen die Lageerkennung nicht greift — etwa
  /// mit dicker Hülle oder auf weicher Unterlage.
  void _armDelayTrigger() {
    _delayTimer?.cancel();
    if (_settings.trigger != PlaybackTrigger.delay) return;

    _delayTimer = Timer(_settings.delay, () {
      if (mounted && _step == FlowStep.recognized) _startPlayback();
    });
  }

  void _onFaceDownChanged(bool faceDown) {
    if (_settings.trigger != PlaybackTrigger.flip) return;

    if (faceDown && _step == FlowStep.recognized) {
      _startPlayback();
    } else if (!faceDown && _step == FlowStep.playing) {
      _reveal();
    }
  }

  void _startPlayback() {
    final videoId = _song?.providerIds[MusicService.youtube];
    setState(() {
      _step = FlowStep.playing;
      _player = videoId == null
          ? null
          : YoutubePlayerController.fromVideoId(
              videoId: videoId,
              autoPlay: true,
              params: const YoutubePlayerParams(
                showControls: false,
                showFullscreenButton: false,
                enableCaption: false,
                // Lädt über youtube-nocookie.com statt youtube.com und
                // setzt damit keine Verfolgungs-Cookies.
                privacyEnhancedMode: true,
                // Vorschläge am Ende bleiben beim selben Kanal, statt sich
                // aus dem Nutzungsverlauf zu speisen.
                strictRelatedVideos: true,
                showVideoAnnotations: false,
              ),
            );
    });
  }

  void _reveal() => setState(() => _step = FlowStep.revealed);

  /// Zurück zum Scanner für die nächste Karte.
  Future<void> _next() async {
    _delayTimer?.cancel();
    final player = _player;

    // Frische Kamerasteuerung statt einer wiederverwendeten — siehe
    // _disposeScanner.
    await _disposeScanner();
    _startScanner();

    setState(() {
      _step = FlowStep.scanning;
      _song = null;
      _problem = null;
      _player = null;
    });

    player?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: switch (_step) {
          FlowStep.scanning => _ScanningView(
              controller: _scanner,
              onDetect: _onDetect,
              problem: _problem,
              onClose: () => Navigator.of(context).pop(),
            ),
          FlowStep.recognized => _RecognizedView(
              trigger: _settings.trigger,
              delay: _settings.delay,
              onStartNow: _startPlayback,
            ),
          // Wiedergabe und Auflösung teilen sich einen Bildschirm, damit der
          // Player an derselben Stelle im Baum bleibt. Würde er zwischen
          // zwei Anordnungen wandern, baute Flutter die WebView neu auf und
          // die Wiedergabe risse ab.
          FlowStep.playing || FlowStep.revealed => _PlayerView(
              player: _player,
              song: _step == FlowStep.revealed ? _song : null,
              onReveal: _reveal,
              onNext: _next,
            ),
        },
      ),
    );
  }
}

class _ScanningView extends StatelessWidget {
  const _ScanningView({
    required this.controller,
    required this.onDetect,
    required this.problem,
    required this.onClose,
  });

  final MobileScannerController? controller;
  final void Function(BarcodeCapture) onDetect;
  final String? problem;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller case final controller?)
          MobileScanner(controller: controller, onDetect: onDetect),
        // Zielrahmen, damit klar ist, wohin die Karte gehört.
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'QR-Code der Karte scannen',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                if (problem case final problem?) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      problem,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Karte erkannt — jetzt umdrehen.
class _RecognizedView extends StatelessWidget {
  const _RecognizedView({
    required this.trigger,
    required this.delay,
    required this.onStartNow,
  });

  final PlaybackTrigger trigger;
  final Duration delay;
  final VoidCallback onStartNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  size: 120, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text('Karte erkannt',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Icon(Icons.flip_to_back,
                  size: 56, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                trigger == PlaybackTrigger.flip
                    ? 'Handy umdrehen'
                    : 'Handy umdrehen — die Musik startet in '
                        '${delay.inSeconds} Sekunden',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Mit dem Bildschirm nach unten auf den Tisch legen, damit '
                'niemand sieht, welcher Song läuft.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (trigger == PlaybackTrigger.flip) ...[
                const SizedBox(height: 40),
                TextButton(
                  onPressed: onStartNow,
                  child: const Text('Jetzt starten'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Wiedergabe und Auflösung in einem Bildschirm.
///
/// Der Player sitzt immer an derselben Stelle im Baum und ändert nur seine
/// Höhe. Beim Auflösen rückt er nach oben, statt neu aufgebaut zu werden —
/// sonst risse die Wiedergabe ab.
///
/// Er wird nie verdeckt oder überlagert; das untersagen die
/// Nutzungsbedingungen von YouTube ausdrücklich.
class _PlayerView extends StatelessWidget {
  const _PlayerView({
    required this.player,
    required this.song,
    required this.onReveal,
    required this.onNext,
  });

  final YoutubePlayerController? player;

  /// Gesetzt, sobald aufgelöst wurde. Vorher bleibt der Song verborgen.
  final Song? song;

  final VoidCallback onReveal;
  final VoidCallback onNext;

  bool get _revealed => song != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Beim Hören nimmt der Player die Fläche ein, beim Auflösen rückt
          // er auf Videoformat zusammen. Gleiche Stelle, andere Höhe.
          final playerHeight = _revealed
              ? constraints.maxWidth * 9 / 16
              : constraints.maxHeight * 0.72;

          return Column(
            children: [
              if (player case final player?)
                SizedBox(
                  height: playerHeight,
                  width: double.infinity,
                  child: YoutubePlayer(controller: player),
                ),
              Expanded(
                child: _revealed
                    ? _RevealedDetails(song: song!, onNext: onNext)
                    : _ListeningHint(
                        hasPlayer: player != null,
                        onReveal: onReveal,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ListeningHint extends StatelessWidget {
  const _ListeningHint({required this.hasPlayer, required this.onReveal});

  final bool hasPlayer;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasPlayer) ...[
              Text('Zu dieser Karte ist kein Video hinterlegt.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
            ],
            Text('Zum Auflösen wieder umdrehen',
                style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(onPressed: onReveal, child: const Text('Auflösen')),
          ],
        ),
      ),
    );
  }
}

/// Die Angaben zum Song, nachdem aufgelöst wurde.
class _RevealedDetails extends StatelessWidget {
  const _RevealedDetails({required this.song, required this.onNext});

  final Song song;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('${song.year}',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              )),
          const SizedBox(height: 8),
          Text(song.title,
              style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(song.artist,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.skip_next),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text('Nächste Karte scannen',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

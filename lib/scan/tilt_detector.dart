/// Erkennt, ob das Gerät mit dem Display nach unten liegt.
///
/// Grundlage des Spielmodus: Erst wenn niemand mehr auf den Bildschirm sehen
/// kann, startet die Wiedergabe. So bleibt der Titel verborgen, obwohl der
/// Player sichtbar läuft — was die Nutzungsbedingungen von YouTube verlangen,
/// die ein Verdecken des Players untersagen.
///
/// Bewusst als Umformung eines Zahlenstroms statt als Sensorzugriff: dadurch
/// lässt sich das Verhalten ohne Gerät prüfen.
library;

import 'dart:async';

/// Ab welchem Wert der Z-Achse das Gerät als umgedreht gilt.
///
/// Bei Ruhe misst die Z-Achse rund -9,8 m/s², wenn das Display nach unten
/// zeigt. Der Schwellwert liegt bewusst darunter, damit ein schräg
/// gehaltenes Gerät nicht schon auslöst.
const faceDownThreshold = -7.5;

/// Wie lange die Lage stabil sein muss.
///
/// Ohne diese Wartezeit löst schon das Umgreifen aus, während die Karte noch
/// gelesen wird.
const faceDownHold = Duration(milliseconds: 700);

/// Meldet `true`, sobald das Gerät stabil umgedreht liegt, und `false`,
/// sobald es wieder angehoben wird.
///
/// Das Anheben wirkt sofort — dort ist Verzögerung schädlich, weil in dem
/// Moment die Wiedergabe enden soll, bevor jemand den Bildschirm sieht.
Stream<bool> faceDownEvents(
  Stream<double> zValues, {
  double threshold = faceDownThreshold,
  Duration hold = faceDownHold,
  Stopwatch? clock,
}) {
  final controller = StreamController<bool>();
  final watch = clock ?? Stopwatch();

  var isFaceDown = false;
  var candidateSince = Duration.zero;
  var hasCandidate = false;

  late final StreamSubscription<double> subscription;
  subscription = zValues.listen(
    (z) {
      final looksFaceDown = z <= threshold;

      if (!looksFaceDown) {
        hasCandidate = false;
        if (isFaceDown) {
          isFaceDown = false;
          controller.add(false);
        }
        return;
      }

      if (isFaceDown) return;

      if (!hasCandidate) {
        hasCandidate = true;
        if (!watch.isRunning) watch.start();
        candidateSince = watch.elapsed;
        return;
      }

      if (watch.elapsed - candidateSince >= hold) {
        isFaceDown = true;
        hasCandidate = false;
        controller.add(true);
      }
    },
    onError: controller.addError,
    onDone: controller.close,
  );

  controller.onCancel = subscription.cancel;
  return controller.stream;
}

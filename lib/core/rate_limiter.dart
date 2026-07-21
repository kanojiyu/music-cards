/// Drosselung ausgehender Anfragen.
///
/// Beide angebundenen Dienste bestehen auf einem Mindestabstand: MusicBrainz
/// erlaubt eine Anfrage pro Sekunde und sperrt bei Verstößen die IP, die
/// iTunes-Suche liegt bei etwa 20 Anfragen pro Minute. Da die Drosselung
/// zweimal gebraucht wird, steht sie hier statt in einem der beiden Dienste.
library;

import 'dart:async';

class RateLimiter {
  RateLimiter({required this.minInterval});

  /// Mindestabstand zwischen dem Start zweier Aufrufe.
  final Duration minInterval;

  /// Serialisiert alle Aufrufe, damit der Abstand auch dann eingehalten wird,
  /// wenn mehrere Anfragen gleichzeitig gestellt werden.
  Future<void> _queue = Future.value();
  DateTime? _lastRun;

  /// Führt [action] aus, sobald der Mindestabstand zum vorigen Aufruf
  /// verstrichen ist.
  ///
  /// Fehler aus [action] werden unverändert weitergereicht und blockieren die
  /// Warteschlange nicht.
  Future<T> run<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      final last = _lastRun;
      if (last != null) {
        final elapsed = DateTime.now().difference(last);
        if (elapsed < minInterval) await Future.delayed(minInterval - elapsed);
      }
      _lastRun = DateTime.now();
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });
    return completer.future;
  }
}

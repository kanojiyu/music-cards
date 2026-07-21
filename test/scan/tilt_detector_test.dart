import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/scan/tilt_detector.dart';

/// Eine Uhr, die im Test von Hand vorgestellt wird.
class ManualClock implements Stopwatch {
  Duration _elapsed = Duration.zero;
  bool _running = false;

  void advance(Duration by) => _elapsed += by;

  @override
  Duration get elapsed => _elapsed;
  @override
  bool get isRunning => _running;
  @override
  void start() => _running = true;
  @override
  void stop() => _running = false;
  @override
  void reset() => _elapsed = Duration.zero;

  @override
  int get elapsedMicroseconds => _elapsed.inMicroseconds;
  @override
  int get elapsedMilliseconds => _elapsed.inMilliseconds;
  @override
  int get elapsedTicks => _elapsed.inMicroseconds;
  @override
  int get frequency => 1000000;
}

void main() {
  late StreamController<double> z;
  late ManualClock clock;
  late List<bool> events;
  late StreamSubscription<bool> subscription;

  setUp(() {
    z = StreamController<double>();
    clock = ManualClock();
    events = [];
    subscription = faceDownEvents(z.stream, clock: clock).listen(events.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await z.close();
  });

  /// Schickt einen Messwert und lässt die Ereignisschleife durchlaufen.
  Future<void> send(double value) async {
    z.add(value);
    await Future<void>.delayed(Duration.zero);
  }

  test('meldet nichts, solange das Gerät oben liegt', () async {
    await send(9.8);
    await send(9.7);

    expect(events, isEmpty);
  });

  // Ohne Wartezeit löst schon das Umgreifen aus, während die Karte noch
  // gelesen wird.
  test('meldet erst, wenn die Lage stabil bleibt', () async {
    await send(-9.8);
    expect(events, isEmpty, reason: 'ein einzelner Messwert reicht nicht');

    clock.advance(const Duration(milliseconds: 300));
    await send(-9.8);
    expect(events, isEmpty, reason: 'noch zu kurz');

    clock.advance(const Duration(milliseconds: 500));
    await send(-9.8);
    expect(events, [true]);
  });

  test('kurzes Kippen löst nicht aus', () async {
    await send(-9.8);
    clock.advance(const Duration(milliseconds: 200));
    await send(-9.8);
    // Wieder aufgerichtet, bevor die Wartezeit um war.
    await send(2.0);
    clock.advance(const Duration(seconds: 2));
    await send(2.0);

    expect(events, isEmpty);
  });

  // Beim Anheben muss die Wiedergabe sofort enden, bevor jemand den
  // Bildschirm sieht — Verzögerung wäre hier schädlich.
  test('das Anheben wirkt ohne Wartezeit', () async {
    await send(-9.8);
    clock.advance(const Duration(seconds: 1));
    await send(-9.8);
    expect(events, [true]);

    await send(0.5);
    expect(events, [true, false]);
  });

  test('meldet dieselbe Lage nicht mehrfach', () async {
    await send(-9.8);
    clock.advance(const Duration(seconds: 1));
    await send(-9.8);
    await send(-9.9);
    await send(-9.7);

    expect(events, [true]);
  });

  test('lässt sich mehrfach hintereinander auslösen', () async {
    Future<void> flipDown() async {
      await send(-9.8);
      clock.advance(const Duration(seconds: 1));
      await send(-9.8);
    }

    await flipDown();
    await send(3.0);
    await flipDown();

    expect(events, [true, false, true]);
  });

  test('ein schräg gehaltenes Gerät gilt nicht als umgedreht', () async {
    // Deutlich geneigt, aber nicht flach auf dem Tisch.
    await send(-5.0);
    clock.advance(const Duration(seconds: 2));
    await send(-5.0);

    expect(events, isEmpty);
  });

  test('der Schwellwert lässt sich anpassen', () async {
    final locker = StreamController<double>();
    addTearDown(locker.close);
    final gemeldet = <bool>[];
    final sub = faceDownEvents(locker.stream, threshold: -4.0, clock: clock)
        .listen(gemeldet.add);
    addTearDown(sub.cancel);

    locker.add(-5.0);
    await Future<void>.delayed(Duration.zero);
    clock.advance(const Duration(seconds: 1));
    locker.add(-5.0);
    await Future<void>.delayed(Duration.zero);

    expect(gemeldet, [true]);
  });
}

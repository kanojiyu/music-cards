import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/core/models.dart';
import 'package:music_cards/game/rules.dart';

Song song(int year, {String? id}) => Song(
      id: id ?? 'song-$year',
      title: 'Titel $year',
      artist: 'Künstler $year',
      year: year,
      yearSource: YearSource.card,
    );

void main() {
  group('gapCount', () {
    test('leere Timeline hat genau eine Lücke', () {
      expect(gapCount([]), 1);
    });

    test('N Karten haben N+1 Lücken', () {
      expect(gapCount([song(1970), song(1980), song(1990)]), 4);
    });
  });

  group('isCorrectPlacement', () {
    final timeline = [song(1970), song(1985), song(2000)];

    test('ganz links vor der ersten Karte', () {
      expect(isCorrectPlacement(timeline, song(1960), 0), isTrue);
      expect(isCorrectPlacement(timeline, song(1990), 0), isFalse);
    });

    test('ganz rechts nach der letzten Karte', () {
      expect(isCorrectPlacement(timeline, song(2010), 3), isTrue);
      expect(isCorrectPlacement(timeline, song(1990), 3), isFalse);
    });

    test('in der Mitte', () {
      expect(isCorrectPlacement(timeline, song(1978), 1), isTrue);
      expect(isCorrectPlacement(timeline, song(1978), 2), isFalse);
      expect(isCorrectPlacement(timeline, song(1990), 2), isTrue);
    });

    test('erste Karte überhaupt passt in die einzige Lücke', () {
      expect(isCorrectPlacement([], song(1999), 0), isTrue);
    });

    test('Lücken außerhalb des Bereichs sind nie korrekt', () {
      expect(isCorrectPlacement(timeline, song(1980), -1), isFalse);
      expect(isCorrectPlacement(timeline, song(1980), 4), isFalse);
    });

    // Zwei Songs aus demselben Jahr sind für Spielende nicht unterscheidbar,
    // deshalb dürfen beide angrenzenden Lücken zählen.
    group('Gleichstand bei Jahreszahlen', () {
      test('beide Seiten einer gleichjährigen Karte gelten', () {
        final t = [song(1970), song(1985, id: 'a'), song(2000)];
        expect(isCorrectPlacement(t, song(1985, id: 'b'), 1), isTrue);
        expect(isCorrectPlacement(t, song(1985, id: 'b'), 2), isTrue);
      });

      test('gleiches Jahr wie die einzige Karte passt links und rechts', () {
        final t = [song(1985, id: 'a')];
        expect(isCorrectPlacement(t, song(1985, id: 'b'), 0), isTrue);
        expect(isCorrectPlacement(t, song(1985, id: 'b'), 1), isTrue);
      });

      test('bei drei gleichen Jahren gelten alle Lücken dazwischen', () {
        final t = [song(1990, id: 'a'), song(1990, id: 'b')];
        for (var gap = 0; gap <= 2; gap++) {
          expect(isCorrectPlacement(t, song(1990, id: 'c'), gap), isTrue,
              reason: 'Lücke $gap');
        }
      });
    });
  });

  group('insertSorted', () {
    test('sortiert unabhängig von der geratenen Lücke ein', () {
      final result = insertSorted([song(1970), song(2000)], song(1985));
      expect(result.map((s) => s.year), [1970, 1985, 2000]);
    });

    test('hängt an beiden Rändern korrekt an', () {
      expect(insertSorted([song(1980)], song(1960)).map((s) => s.year),
          [1960, 1980]);
      expect(insertSorted([song(1980)], song(1990)).map((s) => s.year),
          [1980, 1990]);
    });

    test('verändert die Ausgangsliste nicht', () {
      final original = [song(1970)];
      insertSorted(original, song(1990));
      expect(original, hasLength(1));
    });

    test('hängt gleiche Jahre hinter bestehende gleiche Karten an', () {
      final result = insertSorted([song(1990, id: 'a')], song(1990, id: 'b'));
      expect(result.map((s) => s.id), ['a', 'b']);
    });

    test('in eine leere Timeline', () {
      expect(insertSorted([], song(1975)).single.year, 1975);
    });
  });

  group('resolveRound', () {
    final timeline = [song(1970), song(2000)];

    RoundOutcome run({
      required int year,
      required int placement,
      List<Challenge> challenges = const [],
    }) {
      return resolveRound(
        activeTimeline: timeline,
        song: song(year, id: 'gezogen'),
        activePlayerId: 'aktiv',
        activePlacement: placement,
        challenges: challenges,
      );
    }

    test('aktiver Spieler richtig: er bekommt die Karte', () {
      final outcome = run(year: 1985, placement: 1);
      expect(outcome.activePlacementCorrect, isTrue);
      expect(outcome.cardGoesTo, 'aktiv');
    });

    test('aktiver Spieler falsch, niemand fordert heraus: Karte verfällt', () {
      final outcome = run(year: 1985, placement: 0);
      expect(outcome.activePlacementCorrect, isFalse);
      expect(outcome.cardGoesTo, isNull);
    });

    test('aktiver Spieler falsch, Herausforderer richtig: der bekommt sie', () {
      final outcome = run(
        year: 1985,
        placement: 0,
        challenges: const [Challenge(playerId: 'bea', gap: 1)],
      );
      expect(outcome.winningChallengerId, 'bea');
      expect(outcome.cardGoesTo, 'bea');
    });

    test('bei mehreren richtigen Tokens gewinnt der erste in Zugreihenfolge',
        () {
      // Gleichstand 1970 macht Lücke 0 und 1 gültig — beide Tokens liegen
      // richtig, entscheiden darf trotzdem nur die Reihenfolge.
      final outcome = resolveRound(
        activeTimeline: timeline,
        song: song(1970, id: 'gezogen'),
        activePlayerId: 'aktiv',
        activePlacement: 2,
        challenges: const [
          Challenge(playerId: 'bea', gap: 1),
          Challenge(playerId: 'cem', gap: 0),
        ],
      );
      expect(outcome.winningChallengerId, 'bea');
    });

    test('alle falsch: Karte verfällt', () {
      final outcome = run(
        year: 1985,
        placement: 0,
        challenges: const [Challenge(playerId: 'bea', gap: 2)],
      );
      expect(outcome.cardGoesTo, isNull);
    });

    // Vorrangregel: liegt der aktive Spieler richtig, zählt kein Token mehr,
    // auch wenn es bei Gleichstand ebenfalls auf einer gültigen Lücke liegt.
    test('aktiver Spieler hat Vorrang vor einem ebenfalls richtigen Token', () {
      final outcome = resolveRound(
        activeTimeline: timeline,
        song: song(1970, id: 'gezogen'),
        activePlayerId: 'aktiv',
        activePlacement: 0,
        challenges: const [Challenge(playerId: 'bea', gap: 1)],
      );
      expect(outcome.activePlacementCorrect, isTrue);
      expect(outcome.cardGoesTo, 'aktiv');
      expect(outcome.winningChallengerId, isNull);
    });
  });
}

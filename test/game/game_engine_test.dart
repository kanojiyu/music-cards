import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/core/models.dart';
import 'package:music_cards/game/game_engine.dart';
import 'package:music_cards/game/game_state.dart';
import 'package:music_cards/game/rules.dart';

Song song(int year, {String? id}) => Song(
      id: id ?? 'song-$year',
      title: 'Titel $year',
      artist: 'Künstler $year',
      year: year,
      yearSource: YearSource.card,
    );

List<Song> catalogue(int count) =>
    [for (var i = 0; i < count; i++) song(1950 + i * 3, id: 'k$i')];

Player player(String id, List<int> years, {int tokens = 2}) => Player(
      id: id,
      name: id,
      tokens: tokens,
      timeline: [for (final y in years) song(y, id: '$id-$y')],
    );

/// Baut einen Zustand direkt, um einzelne Situationen ohne Vorlauf zu prüfen.
GameState stateWith({
  required List<Player> players,
  required Song current,
  GamePhase phase = GamePhase.placing,
  GameConfig config = const GameConfig(winCondition: 3),
  int activeIndex = 0,
  int? placement,
  List<Challenge> challenges = const [],
  List<String> pending = const [],
  Set<String> claims = const {},
  List<Song>? deck,
}) {
  return GameState(
    config: config,
    players: players,
    activePlayerIndex: activeIndex,
    deck: deck ?? [song(1999, id: 'nachschub')],
    currentSong: current,
    phase: phase,
    activePlacement: placement,
    challenges: challenges,
    pendingChallengerIds: pending,
    knowledgeClaimants: claims,
  );
}

void main() {
  group('start', () {
    test('teilt Startkarte und Tokens aus und zieht den ersten Song', () {
      final state = GameEngine.start(
        config: const GameConfig(startingTokens: 2),
        players: const [(id: 'a', name: 'Ada'), (id: 'b', name: 'Bea')],
        songs: catalogue(10),
        random: Random(42),
      );

      expect(state.players, hasLength(2));
      expect(state.players.every((p) => p.timeline.length == 1), isTrue);
      expect(state.players.every((p) => p.tokens == 2), isTrue);
      expect(state.currentSong, isNotNull);
      expect(state.phase, GamePhase.listening);
      // 10 minus 2 Startkarten minus 1 gezogener Song.
      expect(state.deck, hasLength(7));
    });

    test('die Startkarte zählt nicht für den Sieg', () {
      final state = GameEngine.start(
        config: const GameConfig(),
        players: const [(id: 'a', name: 'Ada')],
        songs: catalogue(5),
        random: Random(1),
      );
      expect(state.players.single.scoringCards, 0);
    });

    test('lehnt zu kleine Songauswahl ab', () {
      expect(
        () => GameEngine.start(
          config: const GameConfig(),
          players: const [(id: 'a', name: 'Ada'), (id: 'b', name: 'Bea')],
          songs: catalogue(2),
        ),
        throwsArgumentError,
      );
    });

    test('lehnt eine Partie ohne Spieler ab', () {
      expect(
        () => GameEngine.start(
          config: const GameConfig(),
          players: const [],
          songs: catalogue(5),
        ),
        throwsArgumentError,
      );
    });
  });

  group('Rundenablauf', () {
    test('listening → placing → challenging', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980])],
        current: song(1990, id: 'gezogen'),
        phase: GamePhase.listening,
      );

      state = GameEngine.finishListening(state);
      expect(state.phase, GamePhase.placing);

      state = GameEngine.placeCard(state, 1);
      expect(state.phase, GamePhase.challenging);
      expect(state.activePlacement, 1);
      expect(state.pendingChallengerIds, ['b']);
    });

    test('ohne Mitspieler wird direkt aufgedeckt', () {
      var state = stateWith(
        players: [player('a', [1970])],
        current: song(1990, id: 'gezogen'),
      );

      state = GameEngine.placeCard(state, 1);
      expect(state.phase, GamePhase.revealing);
      expect(state.lastOutcome!.cardGoesTo, 'a');
    });

    test('wenn kein Mitspieler Tokens hat, wird direkt aufgedeckt', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980], tokens: 0)],
        current: song(1990, id: 'gezogen'),
      );

      expect(GameEngine.placeCard(state, 1).phase, GamePhase.revealing);
    });

    test('nextRound gibt den Zug weiter und zieht neu', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980])],
        current: song(1990, id: 'gezogen'),
        deck: [song(1965, id: 'naechster')],
      );
      state = GameEngine.placeCard(state, 1);
      state = GameEngine.pass(state, 'b');
      state = GameEngine.nextRound(state);

      expect(state.activePlayerIndex, 1);
      expect(state.phase, GamePhase.listening);
      expect(state.currentSong!.id, 'naechster');
      expect(state.activePlacement, isNull);
      expect(state.challenges, isEmpty);
    });

    test('eine Lücke außerhalb der Timeline wird abgelehnt', () {
      final state = stateWith(
        players: [player('a', [1970, 1980])],
        current: song(1990, id: 'gezogen'),
      );
      expect(() => GameEngine.placeCard(state, 3),
          throwsA(isA<IllegalMoveException>()));
      expect(() => GameEngine.placeCard(state, -1),
          throwsA(isA<IllegalMoveException>()));
    });

    test('Einordnen in falscher Phase wird abgelehnt', () {
      final state = stateWith(
        players: [player('a', [1970])],
        current: song(1990, id: 'gezogen'),
        phase: GamePhase.listening,
      );
      expect(() => GameEngine.placeCard(state, 0),
          throwsA(isA<IllegalMoveException>()));
    });
  });

  group('Token-Ökonomie', () {
    test('ein gesetztes Token ist ausgegeben, auch wenn es gewinnt', () {
      var state = stateWith(
        players: [player('a', [1970, 2000]), player('b', [1980])],
        current: song(1985, id: 'gezogen'),
      );

      state = GameEngine.placeCard(state, 0); // falsch
      state = GameEngine.challenge(state, 'b', 1); // richtig

      expect(state.phase, GamePhase.revealing);
      expect(state.lastOutcome!.cardGoesTo, 'b');
      expect(state.playerById('b').tokens, 1, reason: 'Token bleibt ausgegeben');
      expect(state.playerById('b').timeline.map((s) => s.year), [1980, 1985]);
    });

    test('Passen kostet kein Token', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980])],
        current: song(1990, id: 'gezogen'),
      );

      state = GameEngine.placeCard(state, 1);
      state = GameEngine.pass(state, 'b');

      expect(state.playerById('b').tokens, 2);
      expect(state.phase, GamePhase.revealing);
    });

    test('ohne Tokens kann nicht gesetzt werden', () {
      final state = stateWith(
        players: [player('a', [1970]), player('b', [1980], tokens: 0)],
        current: song(1990, id: 'gezogen'),
        phase: GamePhase.challenging,
        placement: 1,
        pending: const ['b'],
      );
      expect(() => GameEngine.challenge(state, 'b', 0),
          throwsA(isA<IllegalMoveException>()));
    });

    test('die Lücke des aktiven Spielers ist gesperrt', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980])],
        current: song(1990, id: 'gezogen'),
      );
      state = GameEngine.placeCard(state, 1);

      expect(() => GameEngine.challenge(state, 'b', 1),
          throwsA(isA<IllegalMoveException>()));
    });

    test('eine bereits belegte Lücke ist gesperrt', () {
      var state = stateWith(
        players: [
          player('a', [1970, 1990]),
          player('b', [1980]),
          player('c', [1975]),
        ],
        current: song(1985, id: 'gezogen'),
      );
      state = GameEngine.placeCard(state, 0);
      state = GameEngine.challenge(state, 'b', 1);

      expect(() => GameEngine.challenge(state, 'c', 1),
          throwsA(isA<IllegalMoveException>()));
    });

    test('wer nicht am Zug ist, kann nicht setzen', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980])],
        current: song(1990, id: 'gezogen'),
      );
      state = GameEngine.placeCard(state, 1);

      expect(() => GameEngine.challenge(state, 'a', 0),
          throwsA(isA<IllegalMoveException>()));
    });

    test('Herausforderer kommen reihum links vom aktiven Spieler dran', () {
      var state = stateWith(
        players: [
          player('a', [1970]),
          player('b', [1980]),
          player('c', [1975]),
        ],
        current: song(1990, id: 'gezogen'),
        activeIndex: 1,
      );
      state = GameEngine.placeCard(state, 1);
      expect(state.pendingChallengerIds, ['c', 'a']);
    });
  });

  group('Wissensansage', () {
    test('eine bestätigte Ansage bringt ein Token', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980], tokens: 1)],
        current: song(1990, id: 'gezogen'),
      );

      state = GameEngine.claimKnowledge(state, 'b');
      state = GameEngine.placeCard(state, 1);
      state = GameEngine.pass(state, 'b');
      state = GameEngine.confirmKnowledge(state, 'b', wasCorrect: true);

      expect(state.playerById('b').tokens, 2);
      expect(state.knowledgeClaimants, isEmpty);
    });

    test('eine abgelehnte Ansage bringt nichts', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980], tokens: 1)],
        current: song(1990, id: 'gezogen'),
      );

      state = GameEngine.claimKnowledge(state, 'b');
      state = GameEngine.placeCard(state, 1);
      state = GameEngine.pass(state, 'b');
      state = GameEngine.confirmKnowledge(state, 'b', wasCorrect: false);

      expect(state.playerById('b').tokens, 1);
    });

    // Wer erst nach dem Jahr ansagt, hat nichts gewusst.
    test('nach dem Aufdecken ist keine Ansage mehr möglich', () {
      var state = stateWith(
        players: [player('a', [1970])],
        current: song(1990, id: 'gezogen'),
      );
      state = GameEngine.placeCard(state, 1);

      expect(() => GameEngine.claimKnowledge(state, 'a'),
          throwsA(isA<IllegalMoveException>()));
    });

    test('ohne Ansage gibt es nichts zu bestätigen', () {
      var state = stateWith(
        players: [player('a', [1970])],
        current: song(1990, id: 'gezogen'),
      );
      state = GameEngine.placeCard(state, 1);

      expect(() => GameEngine.confirmKnowledge(state, 'a', wasCorrect: true),
          throwsA(isA<IllegalMoveException>()));
    });

    test('eine abgeschaltete Wissensansage wird abgelehnt', () {
      final state = stateWith(
        players: [player('a', [1970])],
        current: song(1990, id: 'gezogen'),
        config: const GameConfig(tokenForKnowledge: false),
      );
      expect(() => GameEngine.claimKnowledge(state, 'a'),
          throwsA(isA<IllegalMoveException>()));
    });
  });

  group('Siegbedingung', () {
    test('greift ab 2 Karten', () {
      var state = stateWith(
        players: [player('a', [1970, 1990])], // Startkarte + 1
        current: song(1980, id: 'gezogen'),
        config: const GameConfig(winCondition: 2),
      );

      state = GameEngine.placeCard(state, 1);

      expect(state.playerById('a').scoringCards, 2);
      expect(state.phase, GamePhase.gameOver);
      expect(state.winnerId, 'a');
      expect(state.isOver, isTrue);
    });

    test('greift nicht zu früh', () {
      var state = stateWith(
        players: [player('a', [1970])],
        current: song(1980, id: 'gezogen'),
        config: const GameConfig(winCondition: 2),
      );

      state = GameEngine.placeCard(state, 1);
      expect(state.phase, GamePhase.revealing);
      expect(state.winnerId, isNull);
    });

    test('ein gewinnendes Token beendet die Partie ebenfalls', () {
      var state = stateWith(
        players: [
          player('a', [1970, 2000]),
          player('b', [1960, 1980]),
        ],
        current: song(1985, id: 'gezogen'),
        config: const GameConfig(winCondition: 2),
      );

      state = GameEngine.placeCard(state, 0); // falsch
      state = GameEngine.challenge(state, 'b', 1); // richtig

      expect(state.winnerId, 'b');
      expect(state.phase, GamePhase.gameOver);
    });

    test('eine Siegbedingung unter 2 ist nicht konstruierbar', () {
      expect(() => GameConfig(winCondition: 1),
          throwsA(isA<AssertionError>()));
    });
  });

  group('Deck-Erschöpfung', () {
    test('leeres Deck beendet die Partie, längste Timeline gewinnt', () {
      var state = stateWith(
        players: [player('a', [1970, 1990]), player('b', [1980])],
        current: song(2000, id: 'gezogen'),
        deck: const [],
        config: const GameConfig(winCondition: 10),
      );

      state = GameEngine.placeCard(state, 2); // richtig
      state = GameEngine.pass(state, 'b');
      state = GameEngine.nextRound(state);

      expect(state.phase, GamePhase.gameOver);
      expect(state.winnerId, 'a');
    });

    test('Gleichstand endet ohne Sieger', () {
      var state = stateWith(
        players: [player('a', [1970]), player('b', [1980])],
        current: song(2000, id: 'gezogen'),
        deck: const [],
        config: const GameConfig(winCondition: 10),
      );

      state = GameEngine.placeCard(state, 0); // falsch, Karte verfällt
      state = GameEngine.pass(state, 'b');
      state = GameEngine.nextRound(state);

      expect(state.phase, GamePhase.gameOver);
      expect(state.winnerId, isNull);
    });
  });
}

/// Die Zustandsmaschine der Partie.
///
/// Reines Dart, keine IO, keine Zufallsquelle außer der beim Start
/// übergebenen. Nach `GameEngine.start` ist jeder weitere Übergang
/// deterministisch — dadurch sind Partien reproduzierbar und der
/// Multiplayer-Host kann denselben Code unverändert betreiben.
library;

import 'dart:math';

import '../core/models.dart';
import 'game_state.dart';
import 'rules.dart';

/// Wird geworfen, wenn eine Aktion in der aktuellen Phase nicht erlaubt ist.
///
/// Die UI verhindert solche Aktionen bereits; im Multiplayer ist das die
/// Verteidigungslinie gegen manipulierte Clients.
class IllegalMoveException implements Exception {
  IllegalMoveException(this.message);
  final String message;

  @override
  String toString() => 'Unerlaubter Zug: $message';
}

abstract final class GameEngine {
  /// Startet eine Partie: Deck mischen, jedem Spieler eine Startkarte geben,
  /// ersten Song ziehen.
  ///
  /// Braucht mindestens `players.length + 1` Songs — eine Startkarte pro
  /// Spieler und mindestens einen Song zum Raten.
  static GameState start({
    required GameConfig config,
    required List<({String id, String name})> players,
    required List<Song> songs,
    Random? random,
  }) {
    if (players.isEmpty) {
      throw ArgumentError('Mindestens ein Spieler nötig');
    }
    if (songs.length < players.length + 1) {
      throw ArgumentError(
        'Zu wenige Songs: ${songs.length} für ${players.length} Spieler '
        '(mindestens ${players.length + 1} nötig)',
      );
    }

    final deck = [...songs]..shuffle(random ?? Random());

    final seated = <Player>[
      for (final p in players)
        Player(
          id: p.id,
          name: p.name,
          tokens: config.startingTokens,
          // Startkarte: verschenkt, damit jede Timeline einen Ankerpunkt hat.
          timeline: [deck.removeLast()],
        ),
    ];

    return _beginRound(
      GameState(
        config: config,
        players: seated,
        activePlayerIndex: 0,
        deck: deck,
        currentSong: null,
        phase: GamePhase.listening,
      ),
    );
  }

  /// Zieht den Song der neuen Runde und setzt die Rundendaten zurück.
  static GameState _beginRound(GameState state) {
    if (state.deck.isEmpty) return _endGameByDeckExhaustion(state);

    final deck = [...state.deck];
    final song = deck.removeLast();

    return state.copyWith(
      deck: deck,
      currentSong: song,
      phase: GamePhase.listening,
      challenges: const [],
      pendingChallengerIds: const [],
      knowledgeClaimants: const {},
      clearPlacement: true,
    );
  }

  /// Der Song wurde gehört — der aktive Spieler darf einsortieren.
  static GameState finishListening(GameState state) {
    _require(state.phase == GamePhase.listening,
        'Es läuft gerade kein Song (Phase: ${state.phase.name})');
    return state.copyWith(phase: GamePhase.placing);
  }

  /// Der aktive Spieler legt die Karte in Lücke [gap] seiner Timeline.
  ///
  /// Danach dürfen die übrigen Spieler herausfordern. Kann das niemand —
  /// keine Mitspieler oder alle ohne Token — geht es direkt zum Aufdecken.
  static GameState placeCard(GameState state, int gap) {
    _require(state.phase == GamePhase.placing,
        'Jetzt kann nicht eingeordnet werden (Phase: ${state.phase.name})');

    final timeline = state.activePlayer.timeline;
    _require(gap >= 0 && gap < gapCount(timeline),
        'Lücke $gap liegt außerhalb der Timeline (0..${gapCount(timeline) - 1})');

    final pending = [
      for (final p in _turnOrderAfterActive(state))
        if (p.tokens > 0) p.id,
    ];

    final next = state.copyWith(
      activePlacement: gap,
      pendingChallengerIds: pending,
      phase: GamePhase.challenging,
    );

    // Ohne mögliche Herausforderer hat die Phase keinen Inhalt.
    return pending.isEmpty ? reveal(next) : next;
  }

  /// Ein Mitspieler setzt ein Token auf eine abweichende Lücke.
  static GameState challenge(GameState state, String playerId, int gap) {
    _require(state.phase == GamePhase.challenging,
        'Jetzt können keine Tokens gesetzt werden (Phase: ${state.phase.name})');
    _require(state.pendingChallengerIds.contains(playerId),
        '$playerId ist gerade nicht am Zug');

    final player = state.playerById(playerId);
    _require(player.tokens > 0, '${player.name} hat keine Tokens mehr');

    final timeline = state.activePlayer.timeline;
    _require(gap >= 0 && gap < gapCount(timeline),
        'Lücke $gap liegt außerhalb der Timeline');
    _require(gap != state.activePlacement,
        'Diese Lücke hat der aktive Spieler bereits gewählt');
    _require(state.challenges.every((c) => c.gap != gap),
        'Auf Lücke $gap liegt bereits ein Token');

    final players = _replacePlayer(
      state.players,
      player.copyWith(tokens: player.tokens - 1),
    );

    return _advanceChallenger(
      state.copyWith(
        players: players,
        challenges: [...state.challenges, Challenge(playerId: playerId, gap: gap)],
      ),
      playerId,
    );
  }

  /// Ein Mitspieler verzichtet auf ein Token.
  static GameState pass(GameState state, String playerId) {
    _require(state.phase == GamePhase.challenging,
        'Jetzt kann nicht gepasst werden (Phase: ${state.phase.name})');
    _require(state.pendingChallengerIds.contains(playerId),
        '$playerId ist gerade nicht am Zug');

    return _advanceChallenger(state, playerId);
  }

  /// Sagt an, Titel *und* Künstler zu kennen.
  ///
  /// Die Ansage muss vor dem Aufdecken fallen — sonst wäre sie wertlos.
  /// Bestätigt wird sie erst danach durch die Runde, siehe
  /// [confirmKnowledge].
  static GameState claimKnowledge(GameState state, String playerId) {
    _require(state.config.tokenForKnowledge,
        'Wissensansagen sind in dieser Partie abgeschaltet');
    _require(
        state.phase == GamePhase.listening ||
            state.phase == GamePhase.placing ||
            state.phase == GamePhase.challenging,
        'Nach dem Aufdecken ist die Ansage wertlos (Phase: ${state.phase.name})');

    // Sicherstellen, dass der Spieler existiert.
    state.playerById(playerId);

    return state.copyWith(
      knowledgeClaimants: {...state.knowledgeClaimants, playerId},
    );
  }

  /// Löst eine Wissensansage nach dem Aufdecken auf.
  ///
  /// [wasCorrect] entscheidet die Runde gemeinsam — das lässt sich nicht
  /// automatisch prüfen, weil niemand weiß, was jemand laut gesagt hat.
  static GameState confirmKnowledge(
    GameState state,
    String playerId, {
    required bool wasCorrect,
  }) {
    _require(state.phase == GamePhase.revealing,
        'Bestätigung erst nach dem Aufdecken (Phase: ${state.phase.name})');
    _require(state.knowledgeClaimants.contains(playerId),
        '${state.playerById(playerId).name} hat nichts angesagt');

    final remaining = {...state.knowledgeClaimants}..remove(playerId);
    if (!wasCorrect) {
      return state.copyWith(knowledgeClaimants: remaining);
    }

    final player = state.playerById(playerId);
    return state.copyWith(
      players: _replacePlayer(
        state.players,
        player.copyWith(tokens: player.tokens + 1),
      ),
      knowledgeClaimants: remaining,
    );
  }

  /// Deckt das Jahr auf und wertet die Runde aus.
  static GameState reveal(GameState state) {
    _require(
        state.phase == GamePhase.challenging ||
            state.phase == GamePhase.placing,
        'Jetzt gibt es nichts aufzudecken (Phase: ${state.phase.name})');

    final song = state.currentSong;
    final placement = state.activePlacement;
    _require(song != null, 'Kein Song in dieser Runde');
    _require(placement != null, 'Der aktive Spieler hat noch nicht eingeordnet');

    final outcome = resolveRound(
      activeTimeline: state.activePlayer.timeline,
      song: song!,
      activePlayerId: state.activePlayer.id,
      activePlacement: placement!,
      challenges: state.challenges,
    );

    var players = state.players;
    final recipientId = outcome.cardGoesTo;
    if (recipientId != null) {
      final recipient = state.playerById(recipientId);
      players = _replacePlayer(
        players,
        recipient.copyWith(timeline: insertSorted(recipient.timeline, song)),
      );
    }

    final withOutcome = state.copyWith(
      players: players,
      phase: GamePhase.revealing,
      lastOutcome: outcome,
      pendingChallengerIds: const [],
    );

    final winner = _findWinner(withOutcome);
    return winner == null
        ? withOutcome
        : withOutcome.copyWith(phase: GamePhase.gameOver, winnerId: winner);
  }

  /// Gibt den Zug weiter und startet die nächste Runde.
  static GameState nextRound(GameState state) {
    _require(state.phase == GamePhase.revealing,
        'Die laufende Runde ist nicht abgeschlossen (Phase: ${state.phase.name})');

    return _beginRound(
      state.copyWith(
        activePlayerIndex: (state.activePlayerIndex + 1) % state.players.length,
      ),
    );
  }

  // --- intern ---

  /// Nimmt den Spieler aus der Warteschlange und deckt auf, sobald alle
  /// entschieden haben.
  static GameState _advanceChallenger(GameState state, String playerId) {
    final pending = [...state.pendingChallengerIds]..remove(playerId);
    final next = state.copyWith(pendingChallengerIds: pending);
    return pending.isEmpty ? reveal(next) : next;
  }

  /// Mitspieler in Zugreihenfolge, beginnend links vom aktiven Spieler.
  static List<Player> _turnOrderAfterActive(GameState state) {
    final n = state.players.length;
    return [
      for (var offset = 1; offset < n; offset++)
        state.players[(state.activePlayerIndex + offset) % n],
    ];
  }

  static List<Player> _replacePlayer(List<Player> players, Player updated) => [
        for (final p in players) p.id == updated.id ? updated : p,
      ];

  /// Der erste Spieler, der die Siegbedingung erreicht hat.
  static String? _findWinner(GameState state) {
    for (final p in state.players) {
      if (p.scoringCards >= state.config.winCondition) return p.id;
    }
    return null;
  }

  /// Deck leer, niemand hat die Siegbedingung erreicht: die längste Timeline
  /// gewinnt, bei Gleichstand endet die Partie unentschieden.
  static GameState _endGameByDeckExhaustion(GameState state) {
    final best = state.players
        .map((p) => p.scoringCards)
        .reduce((a, b) => a > b ? a : b);
    final leaders = state.players.where((p) => p.scoringCards == best).toList();

    return state.copyWith(
      phase: GamePhase.gameOver,
      winnerId: leaders.length == 1 ? leaders.single.id : null,
      clearSong: true,
      clearPlacement: true,
    );
  }

  static void _require(bool condition, String message) {
    if (!condition) throw IllegalMoveException(message);
  }
}

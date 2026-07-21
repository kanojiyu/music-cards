/// Spielzustand und Konfiguration.
library;

import '../core/models.dart';
import 'rules.dart';

/// Einstellbare Regeln einer Partie.
class GameConfig {
  const GameConfig({
    this.winCondition = 10,
    this.startingTokens = 2,
    this.tokenForKnowledge = true,
  })  : assert(winCondition >= 2, 'Siegbedingung muss mindestens 2 sein'),
        assert(startingTokens >= 0, 'Tokens dürfen nicht negativ sein');

  /// Wie viele Karten in der eigenen Timeline zum Sieg führen. Frei ab 2.
  final int winCondition;

  /// Tokens, mit denen jeder Spieler startet.
  final int startingTokens;

  /// Ob eine bestätigte Wissensansage ein Token einbringt.
  final bool tokenForKnowledge;
}

/// Ein Mitspieler mit seiner Timeline und seinem Tokenvorrat.
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.tokens,
    required this.timeline,
  });

  final String id;
  final String name;
  final int tokens;
  final Timeline timeline;

  /// Die Startkarte zählt nicht zum Sieg — sie wird verschenkt, nicht erraten.
  int get scoringCards => timeline.length - 1;

  Player copyWith({int? tokens, Timeline? timeline}) => Player(
        id: id,
        name: name,
        tokens: tokens ?? this.tokens,
        timeline: timeline ?? this.timeline,
      );

  @override
  String toString() => 'Player($name, $tokens Token, ${timeline.length} Karten)';
}

/// Ablaufphasen einer Runde.
enum GamePhase {
  /// Der Song läuft, noch wurde nichts eingeordnet.
  listening,

  /// Der aktive Spieler wählt eine Lücke.
  placing,

  /// Die übrigen Spieler dürfen reihum Tokens setzen oder passen.
  challenging,

  /// Das Jahr ist aufgedeckt, die Runde ausgewertet.
  revealing,

  /// Die Partie ist beendet.
  gameOver,
}

/// Der vollständige, unveränderliche Zustand einer Partie.
///
/// Alle Übergänge liefern einen neuen Zustand. Das macht Snapshots für den
/// Multiplayer-Host trivial und die Engine ohne Aufbau testbar.
class GameState {
  const GameState({
    required this.config,
    required this.players,
    required this.activePlayerIndex,
    required this.deck,
    required this.currentSong,
    required this.phase,
    this.activePlacement,
    this.challenges = const [],
    this.pendingChallengerIds = const [],
    this.knowledgeClaimants = const {},
    this.lastOutcome,
    this.winnerId,
  });

  final GameConfig config;
  final List<Player> players;
  final int activePlayerIndex;

  /// Noch nicht gespielte Songs. Es wird vom Ende gezogen.
  final List<Song> deck;

  /// Der laufende Song. Darf Mitspielern vor dem Aufdecken nicht gezeigt werden.
  final Song? currentSong;

  final GamePhase phase;

  /// Die vom aktiven Spieler gewählte Lücke.
  final int? activePlacement;

  final List<Challenge> challenges;

  /// Wer in dieser Runde noch setzen oder passen darf, in Zugreihenfolge.
  final List<String> pendingChallengerIds;

  /// Wer angesagt hat, Titel und Künstler zu kennen — noch unbestätigt.
  final Set<String> knowledgeClaimants;

  final RoundOutcome? lastOutcome;

  /// Gesetzt, sobald die Partie entschieden ist. `null` bei Gleichstand.
  final String? winnerId;

  Player get activePlayer => players[activePlayerIndex];

  Player playerById(String id) =>
      players.firstWhere((p) => p.id == id, orElse: () {
        throw ArgumentError('Unbekannter Spieler: $id');
      });

  bool get isOver => phase == GamePhase.gameOver;

  GameState copyWith({
    List<Player>? players,
    int? activePlayerIndex,
    List<Song>? deck,
    Song? currentSong,
    GamePhase? phase,
    int? activePlacement,
    List<Challenge>? challenges,
    List<String>? pendingChallengerIds,
    Set<String>? knowledgeClaimants,
    RoundOutcome? lastOutcome,
    String? winnerId,
    bool clearPlacement = false,
    bool clearSong = false,
  }) {
    return GameState(
      config: config,
      players: players ?? this.players,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      deck: deck ?? this.deck,
      currentSong: clearSong ? null : (currentSong ?? this.currentSong),
      phase: phase ?? this.phase,
      activePlacement:
          clearPlacement ? null : (activePlacement ?? this.activePlacement),
      challenges: challenges ?? this.challenges,
      pendingChallengerIds: pendingChallengerIds ?? this.pendingChallengerIds,
      knowledgeClaimants: knowledgeClaimants ?? this.knowledgeClaimants,
      lastOutcome: lastOutcome ?? this.lastOutcome,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}

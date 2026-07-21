/// Die Spielregeln als reine Funktionen, ohne Zustand und ohne IO.
///
/// Alles hier ist direkt testbar. Die Zustandsmaschine in `game_engine.dart`
/// ruft ausschließlich diese Funktionen auf, statt Regeln selbst zu kennen.
library;

import '../core/models.dart';

/// Eine Timeline ist eine aufsteigend nach Jahr sortierte Kartenreihe.
///
/// Eine Timeline mit N Karten hat N+1 Lücken. Lücke `i` liegt vor Karte `i`;
/// Lücke `0` ist ganz links, Lücke `N` ganz rechts.
typedef Timeline = List<Song>;

/// Anzahl der Lücken, in die eine Karte einsortiert werden kann.
int gapCount(Timeline timeline) => timeline.length + 1;

/// Ob `song` in Lücke `gap` der `timeline` korrekt einsortiert ist.
///
/// Bei gleichen Jahreszahlen gelten beide angrenzenden Lücken als richtig —
/// die Reihenfolge zweier Songs aus demselben Jahr ist für Spielende nicht
/// entscheidbar, deshalb darf sie nicht bestraft werden. Genau dafür stehen
/// hier `<=` statt `<`.
bool isCorrectPlacement(Timeline timeline, Song song, int gap) {
  if (gap < 0 || gap >= gapCount(timeline)) return false;

  final fitsAfterLeft = gap == 0 || timeline[gap - 1].year <= song.year;
  final fitsBeforeRight =
      gap == timeline.length || song.year <= timeline[gap].year;

  return fitsAfterLeft && fitsBeforeRight;
}

/// Fügt `song` sortiert in eine Kopie der Timeline ein.
///
/// Wird erst nach einer korrekten Platzierung aufgerufen, sortiert aber
/// unabhängig von der geratenen Lücke — so bleibt die Timeline auch dann
/// konsistent, wenn bei Gleichstand eine andere Lücke gewählt wurde.
Timeline insertSorted(Timeline timeline, Song song) {
  final result = [...timeline];
  var index = result.indexWhere((s) => s.year > song.year);
  if (index == -1) index = result.length;
  result.insert(index, song);
  return result;
}

/// Der Einsatz eines Mitspielers auf eine abweichende Lücke.
class Challenge {
  const Challenge({required this.playerId, required this.gap});

  final String playerId;

  /// Lücke in der Timeline des *aktiven* Spielers.
  final int gap;

  @override
  String toString() => 'Challenge($playerId → Lücke $gap)';
}

/// Wie eine Runde ausgegangen ist.
class RoundOutcome {
  const RoundOutcome({
    required this.song,
    required this.activePlayerId,
    required this.activePlacementCorrect,
    required this.winningChallengerId,
  });

  final Song song;
  final String activePlayerId;

  /// Ob der aktive Spieler richtig einsortiert hat.
  final bool activePlacementCorrect;

  /// Der Mitspieler, der die Karte per Token gewonnen hat — sonst `null`.
  final String? winningChallengerId;

  /// Wer die Karte bekommt. `null`, wenn sie verfällt.
  String? get cardGoesTo =>
      activePlacementCorrect ? activePlayerId : winningChallengerId;
}

/// Wertet eine Runde aus.
///
/// Reihenfolge, weil hier die meisten Hausregel-Varianten sitzen:
/// 1. Der aktive Spieler hat Vorrang. Liegt er richtig, bekommt er die Karte,
///    und alle Tokens sind verloren — auch solche, die bei Jahres-Gleichstand
///    ebenfalls auf einer gültigen Lücke lagen.
/// 2. Liegt er falsch, gewinnt der *erste* korrekt liegende Herausforderer in
///    Zugreihenfolge die Karte.
/// 3. Liegt niemand richtig, verfällt die Karte.
///
/// Tokens gelten in jedem Fall als ausgegeben — Rückgabe erfolgt
/// ausschließlich über die Wissensansage.
RoundOutcome resolveRound({
  required Timeline activeTimeline,
  required Song song,
  required String activePlayerId,
  required int activePlacement,
  required List<Challenge> challenges,
}) {
  final activeCorrect =
      isCorrectPlacement(activeTimeline, song, activePlacement);

  String? winner;
  if (!activeCorrect) {
    for (final challenge in challenges) {
      if (isCorrectPlacement(activeTimeline, song, challenge.gap)) {
        winner = challenge.playerId;
        break;
      }
    }
  }

  return RoundOutcome(
    song: song,
    activePlayerId: activePlayerId,
    activePlacementCorrect: activeCorrect,
    winningChallengerId: winner,
  );
}

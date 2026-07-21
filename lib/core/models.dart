/// Kern-Datenmodelle. Bewusst ohne Flutter- und Codegen-Abhängigkeiten,
/// damit sie zusammen mit der Spiel-Engine auch im Multiplayer-Host
/// unverändert laufen.
library;

/// Streaming-Anbieter, auf denen ein Song abspielbar sein kann.
enum MusicService { spotify, appleMusic, tidal, youtube }

/// Woher die Jahreszahl eines Songs stammt.
///
/// Das ist spielentscheidend: Streaming-Kataloge liefern bei Remastern das
/// Remaster-Jahr statt des Originals. Ein Song, dessen Jahr nur vom Anbieter
/// kommt, ist deshalb nicht vertrauenswürdig.
enum YearSource {
  /// Über MusicBrainz aufgelöstes Erstveröffentlichungsjahr. Bevorzugt.
  musicbrainz,

  /// Direkt vom Streaming-Anbieter. Bei Remastern häufig falsch.
  provider,

  /// Vom Nutzer von Hand gesetzt oder korrigiert.
  manual,

  /// Von einer gedruckten Karte übernommen.
  card,
}

/// Wie sehr der Jahreszahl zu trauen ist.
extension YearSourceTrust on YearSource {
  /// Ob die Quelle ohne Rückfrage für ein Spiel taugt.
  bool get isReliable => this != YearSource.provider;
}

/// Ein spielbarer Song mit genau einem maßgeblichen Erscheinungsjahr.
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.yearSource,
    this.providerIds = const {},
  });

  final String id;
  final String title;
  final String artist;

  /// Das Jahr, gegen das im Spiel geraten wird.
  final int year;
  final YearSource yearSource;

  /// Anbieterspezifische Track-IDs. Ein Song kann auf mehreren Diensten
  /// vorliegen; fehlt ein Eintrag, ist er dort nicht abspielbar.
  final Map<MusicService, String> providerIds;

  bool isPlayableOn(MusicService service) => providerIds.containsKey(service);

  /// Derselbe Song unter einer anderen Kennung.
  ///
  /// Beim Import bekommt jede Karte eine aus Ausgabe und Nummer abgeleitete
  /// Kennung, damit ein erneuter Import dieselben Einträge trifft statt
  /// Doppel anzulegen.
  Song withId(String newId) => Song(
        id: newId,
        title: title,
        artist: artist,
        year: year,
        yearSource: yearSource,
        providerIds: providerIds,
      );

  Song copyWith({
    String? title,
    String? artist,
    int? year,
    YearSource? yearSource,
    Map<MusicService, String>? providerIds,
  }) {
    return Song(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      year: year ?? this.year,
      yearSource: yearSource ?? this.yearSource,
      providerIds: providerIds ?? this.providerIds,
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song($id, "$title" – $artist, $year)';
}

/// Eine app-interne Songsammlung, aus der ein Spiel seine Karten zieht.
class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.songs,
  });

  final String id;
  final String name;
  final List<Song> songs;

  /// Songs, deren Jahr eine Nachprüfung verdient, bevor damit gespielt wird.
  List<Song> get songsWithDoubtfulYear =>
      songs.where((s) => !s.yearSource.isReliable).toList();

  /// Ob die Playlist auf diesem Anbieter vollständig spielbar ist.
  bool isFullyPlayableOn(MusicService service) =>
      songs.every((s) => s.isPlayableOn(service));
}

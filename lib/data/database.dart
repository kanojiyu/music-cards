/// Dauerhafte Ablage für Playlists, Songs und aufgelöste Jahre.
///
/// Relational, weil derselbe Song in mehreren Playlists stecken kann und der
/// Jahres-Cache playlist-übergreifend geteilt wird — genau einmal auflösen,
/// überall nutzen.
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/models.dart';

part 'database.g.dart';

class SongRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  IntColumn get year => integer()();

  /// Index in [YearSource] — hält fest, wie belastbar das Jahr ist.
  IntColumn get yearSource => integer()();

  /// Anbieter-IDs als JSON-Objekt, Schlüssel ist der Name aus [MusicService].
  TextColumn get providerIds => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Zuordnung von Songs zu Playlists. Die Position hält die vom Nutzer
/// gewählte Reihenfolge fest.
class PlaylistSongRows extends Table {
  TextColumn get playlistId =>
      text().references(PlaylistRows, #id, onDelete: KeyAction.cascade)();
  TextColumn get songId =>
      text().references(SongRows, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

/// Über MusicBrainz aufgelöste Jahre.
///
/// Eigene Tabelle statt eines Feldes am Song, weil die Auflösung auf eine
/// Anfrage pro Sekunde gedrosselt ist und ihr Ergebnis deshalb auch dann
/// erhalten bleiben muss, wenn ein Song aus allen Playlists fliegt.
class YearCacheRows extends Table {
  TextColumn get key => text()();
  IntColumn get year => integer().nullable()();
  IntColumn get source => integer()();
  RealColumn get confidence => real()();
  TextColumn get musicbrainzId => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Zuordnung einer gedruckten Karte zu einem Song.
///
/// Muss dauerhaft sein und darf nicht an einer Playlist hängen: Die Zuordnung
/// entsteht durch Handarbeit — bei einem vollständigen Kartensatz sind das
/// hunderte Einträge. Sie soll außerdem weitergegeben werden können, deshalb
/// steht sie für sich.
class CardMappingRows extends Table {
  /// Sprache, Ausgabe und Nummer, wie in `PrintedCard.mappingKey` gebildet.
  TextColumn get cardKey => text()();

  TextColumn get songId =>
      text().references(SongRows, #id, onDelete: KeyAction.cascade)();

  /// Der rohe Code des Scans — hilft, wenn sich das Kartenformat ändert.
  TextColumn get raw => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cardKey};
}

/// Eine Kartenausgabe — mitgeliefert oder selbst angelegt.
///
/// Sprache und Ausgabekennung bestimmen, unter welchem Schlüssel die Karten
/// liegen; dieselbe Nummer bezeichnet in einer anderen Ausgabe einen anderen
/// Titel.
class CardSetRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get sku => text().nullable()();

  /// Woher die Liste stammt. Leer bei selbst eingefügten Daten.
  TextColumn get sourceUrl => text().nullable()();

  IntColumn get cardCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get importedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Einstellungen als Schlüssel-Wert-Paare.
///
/// Bewusst schlicht: Es sind wenige Werte, und ein eigenes Schema pro
/// Einstellung wäre bei jeder Ergänzung eine Migration.
class SettingRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    SongRows,
    PlaylistRows,
    PlaylistSongRows,
    YearCacheRows,
    CardMappingRows,
    CardSetRows,
    SettingRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// Für Tests: eine Datenbank, die nur im Speicher lebt.
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // 2: Zuordnung gedruckter Karten zu Songs.
          if (from < 2) await m.createTable(cardMappingRows);
          // 3: Kartenausgaben und Einstellungen.
          if (from < 3) {
            await m.createTable(cardSetRows);
            await m.createTable(settingRows);
          }
        },
        beforeOpen: (details) async {
          // Ohne das greifen die onDelete-Regeln der Fremdschlüssel nicht.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _open() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      // Der Dateiname stammt aus der Zeit vor der Umbenennung und bleibt
      // bewusst stehen: Eine Änderung ließe die bereits importierten Karten
      // verwaisen, weil die alte Datei dann nicht mehr gefunden würde.
      final file = File(p.join(dir.path, 'music_year_guessing.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

/// Übersetzt zwischen Datenbankzeilen und den Modellen aus `core/models.dart`.
extension SongRowMapping on SongRow {
  Song toSong() => Song(
        id: id,
        title: title,
        artist: artist,
        year: year,
        yearSource: YearSource.values[yearSource],
        providerIds: _decodeProviderIds(providerIds),
      );
}

SongRowsCompanion songToRow(Song song) => SongRowsCompanion.insert(
      id: song.id,
      title: song.title,
      artist: song.artist,
      year: song.year,
      yearSource: song.yearSource.index,
      providerIds: Value(_encodeProviderIds(song.providerIds)),
    );

String _encodeProviderIds(Map<MusicService, String> ids) =>
    jsonEncode({for (final e in ids.entries) e.key.name: e.value});

Map<MusicService, String> _decodeProviderIds(String raw) {
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final entry in decoded.entries)
        ?_serviceByName(entry.key): entry.value as String,
    };
  } on Object {
    // Beschädigte Daten dürfen nicht das Laden der Playlist verhindern.
    return const {};
  }
}

MusicService? _serviceByName(String name) {
  for (final service in MusicService.values) {
    if (service.name == name) return service;
  }
  return null;
}

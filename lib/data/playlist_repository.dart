/// Zugriff auf Playlists und Songs.
///
/// Kapselt die Datenbank, damit die UI weder Drift-Typen noch SQL kennt.
library;

import 'package:drift/drift.dart';

import '../core/models.dart';
import 'database.dart';
import 'playlist_store.dart';

/// Die dauerhafte Ablage über SQLite.
class PlaylistRepository implements PlaylistStore {
  PlaylistRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Playlist>> watchPlaylists() {
    final query = _db.select(_db.playlistRows)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query.watch().asyncMap((rows) async {
      return [
        for (final row in rows)
          Playlist(id: row.id, name: row.name, songs: await songsOf(row.id)),
      ];
    });
  }

  @override
  Future<Playlist?> playlistById(String id) async {
    final row = await (_db.select(_db.playlistRows)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return Playlist(id: row.id, name: row.name, songs: await songsOf(id));
  }

  /// Songs einer Playlist in der vom Nutzer gewählten Reihenfolge.
  @override
  Future<List<Song>> songsOf(String playlistId) async {
    final query = _db.select(_db.playlistSongRows).join([
      innerJoin(_db.songRows, _db.songRows.id.equalsExp(_db.playlistSongRows.songId)),
    ])
      ..where(_db.playlistSongRows.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(_db.playlistSongRows.position)]);

    final rows = await query.get();
    return [for (final row in rows) row.readTable(_db.songRows).toSong()];
  }

  @override
  Future<void> createPlaylist({required String id, required String name}) {
    return _db.into(_db.playlistRows).insert(
          PlaylistRowsCompanion.insert(
            id: id,
            name: name,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> renamePlaylist(String id, String name) {
    return (_db.update(_db.playlistRows)..where((t) => t.id.equals(id)))
        .write(PlaylistRowsCompanion(name: Value(name)));
  }

  /// Löscht die Playlist. Die Zuordnungen fallen per Fremdschlüssel mit weg;
  /// die Songs selbst bleiben, weil sie in anderen Listen stecken können.
  @override
  Future<void> deletePlaylist(String id) {
    return (_db.delete(_db.playlistRows)..where((t) => t.id.equals(id))).go();
  }

  /// Legt Songs an oder aktualisiert sie und hängt sie hinten an die Playlist.
  ///
  /// Läuft in einer Transaktion: eine halb importierte Playlist wäre für den
  /// Nutzer schlimmer als eine fehlgeschlagene.
  @override
  Future<void> addSongs(String playlistId, List<Song> songs) {
    return _db.transaction(() async {
      final existing = await songsOf(playlistId);
      final known = {for (final s in existing) s.id};
      var position = existing.length;

      for (final song in songs) {
        await _db.into(_db.songRows).insertOnConflictUpdate(songToRow(song));
        if (known.contains(song.id)) continue;

        await _db.into(_db.playlistSongRows).insert(
              PlaylistSongRowsCompanion.insert(
                playlistId: playlistId,
                songId: song.id,
                position: position++,
              ),
            );
      }
    });
  }

  @override
  Future<void> removeSong(String playlistId, String songId) {
    return (_db.delete(_db.playlistSongRows)
          ..where((t) =>
              t.playlistId.equals(playlistId) & t.songId.equals(songId)))
        .go();
  }

  /// Korrigiert das Jahr eines Songs von Hand.
  ///
  /// Setzt die Quelle auf [YearSource.manual] — eine Nutzerkorrektur wiegt
  /// schwerer als jede automatische Auflösung und darf nicht überschrieben
  /// werden.
  @override
  Future<void> correctYear(String songId, int year) {
    return (_db.update(_db.songRows)..where((t) => t.id.equals(songId))).write(
      SongRowsCompanion(
        year: Value(year),
        yearSource: Value(YearSource.manual.index),
      ),
    );
  }
}


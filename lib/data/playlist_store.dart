/// Was die Oberfläche von der Playlist-Ablage braucht.
///
/// Als Schnittstelle, damit die Bildschirme nicht von der Datenbank abhängen:
/// Widget-Tests steuern die Uhr und blockieren echte Asynchronität, unter der
/// eine SQLite-Anbindung nicht vorankommt. Mit einer Ablage im Speicher
/// laufen sie schnell und ohne Aufbau.
library;

import '../core/models.dart';

abstract interface class PlaylistStore {
  /// Alle Playlists mit ihren Songs, neueste zuerst.
  Stream<List<Playlist>> watchPlaylists();

  Future<Playlist?> playlistById(String id);

  Future<List<Song>> songsOf(String playlistId);

  Future<void> createPlaylist({required String id, required String name});

  Future<void> renamePlaylist(String id, String name);

  /// Löscht die Playlist. Songs bleiben erhalten, weil sie in anderen Listen
  /// stecken können.
  Future<void> deletePlaylist(String id);

  /// Legt Songs an oder aktualisiert sie und hängt sie hinten an.
  Future<void> addSongs(String playlistId, List<Song> songs);

  Future<void> removeSong(String playlistId, String songId);

  /// Korrigiert das Jahr von Hand und markiert es als [YearSource.manual].
  Future<void> correctYear(String songId, int year);
}

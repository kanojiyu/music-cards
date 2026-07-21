/// Playlist-Ablage im Speicher, für Widget-Tests.
///
/// `testWidgets` steuert die Uhr und lässt echte Asynchronität nicht
/// vorankommen — eine SQLite-Anbindung blockiert darunter. Die Persistenz
/// selbst ist in `test/data/playlist_repository_test.dart` gegen die echte
/// Datenbank abgedeckt.
library;

import 'dart:async';

import 'package:music_cards/core/models.dart';
import 'package:music_cards/data/playlist_store.dart';

class InMemoryPlaylistStore implements PlaylistStore {
  final _playlists = <String, Playlist>{};
  final _controller = StreamController<List<Playlist>>.broadcast();

  List<Playlist> get _snapshot => _playlists.values.toList().reversed.toList();

  void _emit() => _controller.add(_snapshot);

  @override
  Stream<List<Playlist>> watchPlaylists() async* {
    yield _snapshot;
    yield* _controller.stream;
  }

  @override
  Future<Playlist?> playlistById(String id) async => _playlists[id];

  @override
  Future<List<Song>> songsOf(String playlistId) async =>
      _playlists[playlistId]?.songs ?? const [];

  @override
  Future<void> createPlaylist({required String id, required String name}) async {
    _playlists[id] = Playlist(id: id, name: name, songs: const []);
    _emit();
  }

  @override
  Future<void> renamePlaylist(String id, String name) async {
    final existing = _playlists[id];
    if (existing == null) return;
    _playlists[id] = Playlist(id: id, name: name, songs: existing.songs);
    _emit();
  }

  @override
  Future<void> deletePlaylist(String id) async {
    _playlists.remove(id);
    _emit();
  }

  @override
  Future<void> addSongs(String playlistId, List<Song> songs) async {
    final existing = _playlists[playlistId];
    if (existing == null) return;

    final known = {for (final s in existing.songs) s.id};
    _playlists[playlistId] = Playlist(
      id: existing.id,
      name: existing.name,
      songs: [
        ...existing.songs,
        for (final song in songs)
          if (known.add(song.id)) song,
      ],
    );
    _emit();
  }

  @override
  Future<void> removeSong(String playlistId, String songId) async {
    final existing = _playlists[playlistId];
    if (existing == null) return;
    _playlists[playlistId] = Playlist(
      id: existing.id,
      name: existing.name,
      songs: [
        for (final song in existing.songs)
          if (song.id != songId) song,
      ],
    );
    _emit();
  }

  @override
  Future<void> correctYear(String songId, int year) async {
    for (final entry in _playlists.entries.toList()) {
      _playlists[entry.key] = Playlist(
        id: entry.value.id,
        name: entry.value.name,
        songs: [
          for (final song in entry.value.songs)
            song.id == songId
                ? song.copyWith(year: year, yearSource: YearSource.manual)
                : song,
        ],
      );
    }
    _emit();
  }

  Future<void> dispose() => _controller.close();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/core/models.dart';
import 'package:music_cards/data/database.dart';
import 'package:music_cards/data/playlist_repository.dart';

Song song(String id, {int year = 1980, Map<MusicService, String>? ids}) => Song(
      id: id,
      title: 'Titel $id',
      artist: 'Künstler $id',
      year: year,
      yearSource: YearSource.musicbrainz,
      providerIds: ids ?? const {},
    );

void main() {
  late AppDatabase db;
  late PlaylistRepository repo;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = PlaylistRepository(db);
  });

  tearDown(() => db.close());

  group('Playlists', () {
    test('anlegen und wiederfinden', () async {
      await repo.createPlaylist(id: 'p1', name: 'Achtziger');

      final playlist = await repo.playlistById('p1');

      expect(playlist!.name, 'Achtziger');
      expect(playlist.songs, isEmpty);
    });

    test('umbenennen', () async {
      await repo.createPlaylist(id: 'p1', name: 'Alt');
      await repo.renamePlaylist('p1', 'Neu');

      expect((await repo.playlistById('p1'))!.name, 'Neu');
    });

    test('löschen', () async {
      await repo.createPlaylist(id: 'p1', name: 'Weg damit');
      await repo.deletePlaylist('p1');

      expect(await repo.playlistById('p1'), isNull);
    });

    test('unbekannte Playlist ergibt null', () async {
      expect(await repo.playlistById('gibtsnicht'), isNull);
    });
  });

  group('Songs', () {
    test('hinzufügen und in Reihenfolge zurückbekommen', () async {
      await repo.createPlaylist(id: 'p1', name: 'Liste');
      await repo.addSongs('p1', [song('a'), song('b'), song('c')]);

      final songs = await repo.songsOf('p1');

      expect(songs.map((s) => s.id), ['a', 'b', 'c']);
    });

    test('behält Anbieter-IDs über einen Neustart hinweg', () async {
      await repo.createPlaylist(id: 'p1', name: 'Liste');
      await repo.addSongs('p1', [
        song('a', ids: {MusicService.tidal: 'tidal-123'}),
      ]);

      final loaded = (await repo.songsOf('p1')).single;

      expect(loaded.providerIds[MusicService.tidal], 'tidal-123');
    });

    test('hängt neue Songs hinten an', () async {
      await repo.createPlaylist(id: 'p1', name: 'Liste');
      await repo.addSongs('p1', [song('a')]);
      await repo.addSongs('p1', [song('b')]);

      expect((await repo.songsOf('p1')).map((s) => s.id), ['a', 'b']);
    });

    // Sonst taucht derselbe Song zweimal in der Timeline auf.
    test('nimmt denselben Song nicht doppelt auf', () async {
      await repo.createPlaylist(id: 'p1', name: 'Liste');
      await repo.addSongs('p1', [song('a')]);
      await repo.addSongs('p1', [song('a'), song('b')]);

      expect((await repo.songsOf('p1')).map((s) => s.id), ['a', 'b']);
    });

    test('entfernen', () async {
      await repo.createPlaylist(id: 'p1', name: 'Liste');
      await repo.addSongs('p1', [song('a'), song('b')]);
      await repo.removeSong('p1', 'a');

      expect((await repo.songsOf('p1')).map((s) => s.id), ['b']);
    });

    // Ein Song kann in mehreren Listen stecken; er darf beim Löschen einer
    // Liste nicht aus den anderen verschwinden.
    test('derselbe Song lebt in mehreren Playlists', () async {
      await repo.createPlaylist(id: 'p1', name: 'Eins');
      await repo.createPlaylist(id: 'p2', name: 'Zwei');
      await repo.addSongs('p1', [song('a')]);
      await repo.addSongs('p2', [song('a')]);

      await repo.deletePlaylist('p1');

      expect((await repo.songsOf('p2')).map((s) => s.id), ['a']);
    });

    test('Löschen einer Playlist räumt ihre Zuordnungen weg', () async {
      await repo.createPlaylist(id: 'p1', name: 'Eins');
      await repo.addSongs('p1', [song('a')]);
      await repo.deletePlaylist('p1');

      expect(await repo.songsOf('p1'), isEmpty);
    });
  });

  group('Jahres-Korrektur', () {
    test('setzt Jahr und markiert es als manuell', () async {
      await repo.createPlaylist(id: 'p1', name: 'Liste');
      await repo.addSongs('p1', [song('a', year: 2011)]);

      await repo.correctYear('a', 1979);

      final loaded = (await repo.songsOf('p1')).single;
      expect(loaded.year, 1979);
      expect(loaded.yearSource, YearSource.manual);
    });
  });

}

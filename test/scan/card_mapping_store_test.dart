import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/core/models.dart';
import 'package:music_cards/data/database.dart';
import 'package:music_cards/scan/card_mapping_store.dart';
import 'package:music_cards/scan/printed_card.dart';

Song song(String id, {String title = 'Africa', int year = 1982}) => Song(
      id: id,
      title: title,
      artist: 'Toto',
      year: year,
      yearSource: YearSource.manual,
    );

void main() {
  late AppDatabase db;
  late DriftCardMappingStore store;

  setUp(() {
    db = AppDatabase.inMemory();
    store = DriftCardMappingStore(db);
  });

  tearDown(() => db.close());

  group('Zuordnen', () {
    test('speichert und findet wieder', () async {
      await store.assign(
        cardKey: 'de/-/00172',
        raw: 'www.example-game.com/de/00172',
        song: song('s1'),
      );

      final found = await store.songForCard('de/-/00172');

      expect(found!.title, 'Africa');
      expect(found.year, 1982);
    });

    test('unbekannte Karte ergibt null', () async {
      expect(await store.songForCard('de/-/99999'), isNull);
    });

    // Bei hunderten Karten von Hand passiert ein Fehlgriff; die Korrektur
    // darf keinen zweiten Eintrag hinterlassen.
    test('eine erneute Zuordnung ersetzt die alte', () async {
      await store.assign(
          cardKey: 'de/-/00172', raw: 'x', song: song('s1', title: 'Falsch'));
      await store.assign(
          cardKey: 'de/-/00172', raw: 'x', song: song('s2', title: 'Richtig'));

      expect((await store.songForCard('de/-/00172'))!.title, 'Richtig');
      expect(await store.count(), 1);
    });

    test('entfernen', () async {
      await store.assign(cardKey: 'de/-/00172', raw: 'x', song: song('s1'));
      await store.remove('de/-/00172');

      expect(await store.songForCard('de/-/00172'), isNull);
      expect(await store.count(), 0);
    });

    // Dieselbe Nummer bezeichnet in verschiedenen Ausgaben andere Titel.
    test('trennt Ausgaben und Sprachen', () async {
      await store.assign(
          cardKey: 'de/-/00172', raw: 'x', song: song('s1', title: 'Deutsch'));
      await store.assign(
          cardKey: 'en/-/00172', raw: 'x', song: song('s2', title: 'Englisch'));

      expect((await store.songForCard('de/-/00172'))!.title, 'Deutsch');
      expect((await store.songForCard('en/-/00172'))!.title, 'Englisch');
    });
  });

  group('mappingKey', () {
    test('entsteht aus Sprache, Ausgabe und Nummer', () {
      expect(parsePrintedCard('www.x.de/de/00172').mappingKey, 'de/-/00172');
      expect(parsePrintedCard('www.x.de/de/aa02/00172').mappingKey,
          'de/aa02/00172');
    });

    test('fehlt, wenn die Karte keine Nummer trägt', () {
      expect(parsePrintedCard('irgendwas').mappingKey, isNull);
    });
  });

  group('CSV-Import einer Kartenliste', () {
    const liste = '''
Card#,Artist,Title,URL,Hashed Info,Youtube-Title,Year
172,Ein Interpret,Ein Titel,https://www.youtube.com/watch?v=abc12345678,x,y,1987
1,Andere Band,Anderer Titel,https://youtu.be/def45678901,x,y,1965
''';

    test('legt die Karten unter dem Schlüssel aus dem Scan ab', () async {
      final outcome = await store.importCardListCsv(liste, language: 'de');

      expect(outcome.imported, 2);

      // Genau der Schlüssel, den ein Scan von www.../de/00172 erzeugt.
      final gefunden = await store.songForCard('de/-/00172');
      expect(gefunden!.year, 1987);
      expect(gefunden.title, 'Ein Titel');
    });

    test('merkt sich die YouTube-Kennung zum Abspielen', () async {
      await store.importCardListCsv(liste, language: 'de');

      final song = await store.songForCard('de/-/00172');
      expect(song!.providerIds[MusicService.youtube], 'abc12345678');
    });

    test('ein zweiter Import legt nichts doppelt an', () async {
      await store.importCardListCsv(liste, language: 'de');
      await store.importCardListCsv(liste, language: 'de');

      expect(await store.count(), 2);
    });

    // Dieselbe Nummer bezeichnet in einer anderen Ausgabe einen anderen Song.
    test('Ausgaben überschreiben sich nicht gegenseitig', () async {
      await store.importCardListCsv(liste, language: 'de');
      await store.importCardListCsv(
        'Card#,Artist,Title,Year\n172,Rock-Band,Rock-Titel,1975\n',
        language: 'de',
        sku: 'aaaa0039',
      );

      expect((await store.songForCard('de/-/00172'))!.year, 1987);
      expect((await store.songForCard('de/aaaa0039/00172'))!.year, 1975);
    });

    test('reicht einen Fehler der Datei durch', () async {
      final outcome =
          await store.importCardListCsv('Unsinn ohne Spalten\n', language: 'de');

      expect(outcome.isFailure, isTrue);
      expect(await store.count(), 0);
    });
  });

  group('Export und Import', () {
    test('gibt Zuordnungen zum Weitergeben aus', () async {
      await store.assign(cardKey: 'de/-/00172', raw: 'roh', song: song('s1'));

      final decoded = jsonDecode(await store.exportJson()) as Map;
      final entries = decoded['mappings'] as List;

      expect(decoded['format'], DriftCardMappingStore.formatVersion);
      expect(entries.single['card'], 'de/-/00172');
      expect(entries.single['title'], 'Africa');
      expect(entries.single['year'], 1982);
    });

    test('liest die eigene Ausgabe wieder ein', () async {
      await store.assign(cardKey: 'de/-/00172', raw: 'roh', song: song('s1'));
      final exported = await store.exportJson();

      final leer = AppDatabase.inMemory();
      addTearDown(leer.close);
      final ziel = DriftCardMappingStore(leer);

      final outcome = await ziel.importJson(exported);

      expect(outcome.imported, 1);
      expect((await ziel.songForCard('de/-/00172'))!.title, 'Africa');
    });

    test('ein zweiter Import legt nichts doppelt an', () async {
      const json = '''
{"format":1,"mappings":[
  {"card":"de/-/00172","title":"Africa","artist":"Toto","year":1982}
]}''';

      await store.importJson(json);
      await store.importJson(json);

      expect(await store.count(), 1);
    });

    test('nimmt auch ein nacktes Array entgegen', () async {
      const json =
          '[{"card":"de/-/1","title":"A","artist":"B","year":1990}]';

      expect((await store.importJson(json)).imported, 1);
    });

    // Der Nutzer hat die Datei mühsam erstellt — ein kaputter Eintrag darf
    // nicht die ganze Sammlung kosten.
    test('behält gute Einträge trotz kaputter Nachbarn', () async {
      const json = '''
[
  {"card":"de/-/1","title":"A","artist":"B","year":1990},
  {"card":"de/-/2","title":"ohne Jahr","artist":"B"},
  "kein Objekt",
  {"card":"de/-/3","title":"C","artist":"D","year":"1975"}
]''';

      final outcome = await store.importJson(json);

      expect(outcome.imported, 2);
      expect(outcome.skipped, 2);
      expect((await store.songForCard('de/-/3'))!.year, 1975);
    });

    test('markiert importierte Jahre als von der Karte stammend', () async {
      await store.importJson(
          '[{"card":"de/-/1","title":"A","artist":"B","year":1990}]');

      expect((await store.songForCard('de/-/1'))!.yearSource, YearSource.card);
    });

    group('unbrauchbare Dateien', () {
      test('kein JSON', () async {
        final outcome = await store.importJson('völliger Unsinn');

        expect(outcome.isFailure, isTrue);
        expect(outcome.error, contains('JSON'));
      });

      test('JSON ohne Zuordnungen', () async {
        final outcome = await store.importJson('{"format":1}');

        expect(outcome.isFailure, isTrue);
        expect(outcome.error, contains('Liste'));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:music_cards/data/database.dart';
import 'package:music_cards/scan/card_mapping_store.dart';
import 'package:music_cards/scan/card_set_catalog.dart';
import 'package:music_cards/scan/card_set_store.dart';

const _liste = '''
Card#,Artist,Title,URL,Year
1,Erste Band,Erster Titel,https://www.youtube.com/watch?v=abc12345678,1965
172,Zweite Band,Zweiter Titel,https://youtu.be/def45678901,1987
''';

void main() {
  late AppDatabase db;
  late DriftCardMappingStore mappings;

  setUp(() {
    db = AppDatabase.inMemory();
    mappings = DriftCardMappingStore(db);
  });

  tearDown(() => db.close());

  DriftCardSetStore storeReturning(String body, {int status = 200}) {
    return DriftCardSetStore(
      db,
      mappings: mappings,
      client: MockClient((_) async => http.Response(body, status)),
    );
  }

  group('Einrichten aus dem Verzeichnis', () {
    test('lädt die Liste und legt die Ausgabe an', () async {
      final store = storeReturning(_liste);

      final outcome = await store.installFromCatalog(cardSetCatalog.first);

      expect(outcome.imported, 2);
      final sets = await store.all();
      expect(sets.single.id, cardSetCatalog.first.id);
      expect(sets.single.cardCount, 2);
    });

    test('die Karten sind danach über den Scan-Schlüssel auffindbar', () async {
      await storeReturning(_liste).installFromCatalog(cardSetCatalog.first);

      // Genau der Schlüssel, den ein Scan von www.../de/00172 erzeugt.
      expect((await mappings.songForCard('de/-/00172'))!.year, 1987);
    });

    test('eine Erweiterung landet unter ihrer eigenen Kennung', () async {
      final rock =
          cardSetCatalog.firstWhere((e) => e.sku == 'aaaa0039');

      await storeReturning(_liste).installFromCatalog(rock);

      expect((await mappings.songForCard('de/aaaa0039/00172'))!.year, 1987);
      expect(await mappings.songForCard('de/-/00172'), isNull);
    });
  });

  group('Fehlschläge', () {
    // Eine leere Ausgabe in der Liste wäre irreführend.
    test('legt bei nicht erreichbarer Adresse keine Ausgabe an', () async {
      final store = storeReturning('', status: 404);

      final outcome = await store.installFromCatalog(cardSetCatalog.first);

      expect(outcome.isFailure, isTrue);
      expect(await store.all(), isEmpty);
    });

    test('legt bei unbrauchbarer Datei keine Ausgabe an', () async {
      final store = storeReturning('Nummer,Irgendwas\n1,x\n');

      final outcome = await store.installFromCatalog(cardSetCatalog.first);

      expect(outcome.isFailure, isTrue);
      expect(await store.all(), isEmpty);
    });
  });

  group('Eigene Ausgabe', () {
    test('lässt sich aus eingefügten Daten anlegen', () async {
      final store = storeReturning('');

      final outcome = await store.installFromCsv(
        id: 'eigene',
        name: 'Mein Kartensatz',
        language: 'de',
        sku: 'privat',
        csv: _liste,
      );

      expect(outcome.imported, 2);
      expect((await store.byId('eigene'))!.name, 'Mein Kartensatz');
      expect((await mappings.songForCard('de/privat/00172'))!.year, 1987);
    });
  });

  group('Entfernen', () {
    test('nimmt die Ausgabe samt ihrer Karten mit', () async {
      final store = storeReturning(_liste);
      await store.installFromCatalog(cardSetCatalog.first);

      await store.remove(cardSetCatalog.first.id);

      expect(await store.all(), isEmpty);
      expect(await mappings.songForCard('de/-/00172'), isNull);
    });

    // Sonst reißt das Entfernen einer Erweiterung die Grundausgabe mit.
    test('lässt andere Ausgaben unberührt', () async {
      final store = storeReturning(_liste);
      final rock = cardSetCatalog.firstWhere((e) => e.sku == 'aaaa0039');

      await store.installFromCatalog(cardSetCatalog.first);
      await store.installFromCatalog(rock);
      await store.remove(rock.id);

      expect(await mappings.songForCard('de/-/00172'), isNotNull);
      expect(await mappings.songForCard('de/aaaa0039/00172'), isNull);
      expect((await store.all()).single.id, cardSetCatalog.first.id);
    });
  });

  group('Sicherheit beim Entfernen', () {
    // Sprache und Ausgabekennung kommen aus einer Eingabe des Nutzers. Landen
    // sie ungeprüft in einem SQL-LIKE, wirken `%` und `_` als Platzhalter und
    // reißen fremde Ausgaben mit.
    test('ein Prozentzeichen in der Kennung löscht nichts Fremdes', () async {
      final store = storeReturning('');

      await store.installFromCsv(
        id: 'echt',
        name: 'Echte Ausgabe',
        language: 'de',
        sku: 'aaaa0039',
        csv: _liste,
      );
      await store.installFromCsv(
        id: 'platzhalter',
        name: 'Mit Platzhalter',
        language: 'de',
        sku: '%',
        csv: _liste,
      );

      await store.remove('platzhalter');

      // Die echte Ausgabe muss vollständig erhalten bleiben.
      expect(await mappings.songForCard('de/aaaa0039/00172'), isNotNull);
      expect(await mappings.songForCard('de/%/00172'), isNull);
    });

    test('ein Unterstrich in der Kennung wirkt ebenfalls nicht als Muster',
        () async {
      final store = storeReturning('');

      await store.installFromCsv(
        id: 'abc',
        name: 'Drei Zeichen',
        language: 'de',
        sku: 'abc',
        csv: _liste,
      );
      await store.installFromCsv(
        id: 'muster',
        name: 'Mit Unterstrich',
        language: 'de',
        sku: '___',
        csv: _liste,
      );

      await store.remove('muster');

      expect(await mappings.songForCard('de/abc/00172'), isNotNull);
    });
  });

  group('Verzeichnis', () {
    test('die Grundausgaben tragen keine Ausgabekennung', () {
      final basis = cardSetCatalog.where((e) => e.sku == null);

      expect(basis, isNotEmpty);
      expect(basis.map((e) => e.id), contains('de'));
    });

    test('alle Einträge haben eindeutige Kennungen', () {
      final ids = cardSetCatalog.map((e) => e.id).toSet();

      expect(ids, hasLength(cardSetCatalog.length));
    });

    test('alle Adressen zeigen auf CSV-Dateien', () {
      for (final entry in cardSetCatalog) {
        expect(entry.url.toString(), endsWith('.csv'), reason: entry.name);
        expect(entry.url.scheme, 'https');
      }
    });
  });
}

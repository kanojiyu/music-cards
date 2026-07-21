/// Verwaltung der Kartenausgaben.
///
/// Eine Ausgabe entsteht entweder aus dem eingebauten Verzeichnis (Liste wird
/// bei Bedarf geladen) oder aus eigenen Daten, die der Nutzer einfügt.
library;

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import 'card_mapping_store.dart';
import 'card_set_catalog.dart';

/// Eine eingerichtete Ausgabe.
class CardSet {
  const CardSet({
    required this.id,
    required this.name,
    required this.language,
    required this.cardCount,
    this.sku,
    this.sourceUrl,
  });

  final String id;
  final String name;
  final String language;
  final String? sku;
  final int cardCount;
  final String? sourceUrl;

  bool get isEmpty => cardCount == 0;
}

abstract interface class CardSetStore {
  /// Alle eingerichteten Ausgaben, neueste zuerst.
  Future<List<CardSet>> all();

  Future<CardSet?> byId(String id);

  /// Richtet eine Ausgabe aus dem Verzeichnis ein und lädt ihre Liste.
  Future<ImportOutcome> installFromCatalog(CatalogEntry entry);

  /// Richtet eine eigene Ausgabe aus CSV-Daten ein.
  Future<ImportOutcome> installFromCsv({
    required String id,
    required String name,
    required String language,
    String? sku,
    required String csv,
    String? sourceUrl,
  });

  /// Lädt eine Liste von einer Adresse und richtet sie ein.
  Future<ImportOutcome> installFromUrl({
    required String id,
    required String name,
    required String language,
    String? sku,
    required Uri url,
  });

  Future<void> remove(String id);
}

class DriftCardSetStore implements CardSetStore {
  DriftCardSetStore(this._db, {http.Client? client, CardMappingStore? mappings})
      : _client = client ?? http.Client(),
        _mappings = mappings ?? DriftCardMappingStore(_db);

  final AppDatabase _db;
  final http.Client _client;
  final CardMappingStore _mappings;

  @override
  Future<List<CardSet>> all() async {
    final query = _db.select(_db.cardSetRows)
      ..orderBy([(t) => OrderingTerm.desc(t.importedAt)]);

    return [for (final row in await query.get()) _toCardSet(row)];
  }

  @override
  Future<CardSet?> byId(String id) async {
    final row = await (_db.select(_db.cardSetRows)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toCardSet(row);
  }

  CardSet _toCardSet(CardSetRow row) => CardSet(
        id: row.id,
        name: row.name,
        language: row.language,
        sku: row.sku,
        cardCount: row.cardCount,
        sourceUrl: row.sourceUrl,
      );

  @override
  Future<ImportOutcome> installFromCatalog(CatalogEntry entry) {
    return installFromUrl(
      id: entry.id,
      name: entry.name,
      language: entry.language,
      sku: entry.sku,
      url: entry.url,
    );
  }

  @override
  Future<ImportOutcome> installFromUrl({
    required String id,
    required String name,
    required String language,
    String? sku,
    required Uri url,
  }) async {
    final http.Response response;
    try {
      response = await _client.get(url);
    } on Exception catch (error) {
      return ImportOutcome(
        imported: 0,
        skipped: 0,
        error: 'Die Liste ließ sich nicht laden: $error',
      );
    }

    if (response.statusCode != 200) {
      return ImportOutcome(
        imported: 0,
        skipped: 0,
        error: 'Die Adresse antwortete mit HTTP ${response.statusCode}.',
      );
    }

    return installFromCsv(
      id: id,
      name: name,
      language: language,
      sku: sku,
      csv: response.body,
      sourceUrl: url.toString(),
    );
  }

  @override
  Future<ImportOutcome> installFromCsv({
    required String id,
    required String name,
    required String language,
    String? sku,
    required String csv,
    String? sourceUrl,
  }) async {
    final outcome = await _mappings.importCardListCsv(
      csv,
      language: language,
      sku: sku,
    );

    // Bei einem Fehlschlag keine Ausgabe anlegen — eine leere Ausgabe in der
    // Liste wäre irreführend.
    if (outcome.isFailure) return outcome;

    await _db.into(_db.cardSetRows).insertOnConflictUpdate(
          CardSetRowsCompanion.insert(
            id: id,
            name: name,
            language: language,
            sku: Value(sku),
            sourceUrl: Value(sourceUrl),
            cardCount: Value(outcome.imported),
            importedAt: Value(DateTime.now()),
          ),
        );

    return outcome;
  }

  /// Entfernt die Ausgabe samt ihrer Kartenzuordnungen.
  @override
  Future<void> remove(String id) async {
    final set = await byId(id);
    if (set == null) return;

    // Nur die Karten dieser Ausgabe: Der Schlüssel beginnt mit Sprache und
    // Ausgabekennung, andere Ausgaben bleiben unberührt.
    //
    // Bewusst kein `LIKE`: Sprache und Ausgabekennung stammen aus einer
    // Eingabe des Nutzers. Ein `%` oder `_` darin wäre für SQL ein Platzhalter
    // und würde die Karten fremder Ausgaben mitlöschen. Der Vergleich läuft
    // deshalb in Dart, wo diese Zeichen nichts bedeuten.
    final prefix = '${set.language}/${set.sku ?? '-'}/';
    final rows = await _db.select(_db.cardMappingRows).get();
    final keys = [
      for (final row in rows)
        if (row.cardKey.startsWith(prefix)) row.cardKey,
    ];

    await _db.transaction(() async {
      await (_db.delete(_db.cardMappingRows)
            ..where((t) => t.cardKey.isIn(keys)))
          .go();
      await (_db.delete(_db.cardSetRows)..where((t) => t.id.equals(id))).go();
    });
  }
}

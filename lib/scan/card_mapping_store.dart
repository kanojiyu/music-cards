/// Dauerhafte Zuordnung gedruckter Karten zu Songs.
///
/// Die Zuordnung entsteht durch Handarbeit — bei einem vollständigen
/// Kartensatz sind das hunderte Einträge. Sie muss deshalb Programmstarts
/// überleben und weitergegeben werden können.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/models.dart';
import '../data/database.dart';
import 'card_list_import.dart';

/// Was die Oberfläche von der Zuordnungsablage braucht.
abstract interface class CardMappingStore {
  /// Der zugeordnete Song, oder `null`, wenn die Karte noch unbekannt ist.
  Future<Song?> songForCard(String cardKey);

  Future<void> assign({
    required String cardKey,
    required String raw,
    required Song song,
  });

  Future<void> remove(String cardKey);

  /// Wie viele Karten bereits zugeordnet sind.
  Future<int> count();

  /// Alle Zuordnungen zum Weitergeben.
  Future<String> exportJson();

  /// Übernimmt Zuordnungen aus einer zuvor ausgegebenen Datei.
  Future<ImportOutcome> importJson(String json);

  /// Übernimmt eine fertige Kartenliste im CSV-Format.
  ///
  /// [language] und [sku] bestimmen, unter welchem Schlüssel die Karten
  /// abgelegt werden — dieselbe Nummer bezeichnet in anderen Ausgaben andere
  /// Titel.
  Future<ImportOutcome> importCardListCsv(
    String csv, {
    required String language,
    String? sku,
  });
}

/// Was ein Import bewirkt hat.
class ImportOutcome {
  const ImportOutcome({
    required this.imported,
    required this.skipped,
    this.error,
  });

  final int imported;
  final int skipped;

  /// Gesetzt, wenn die Datei gar nicht lesbar war.
  final String? error;

  bool get isFailure => error != null;
}

class DriftCardMappingStore implements CardMappingStore {
  DriftCardMappingStore(this._db);

  /// Kennung des Dateiformats. Ändert sich der Aufbau, lässt sich daran
  /// erkennen, dass eine ältere Datei anders zu lesen ist.
  static const formatVersion = 1;

  final AppDatabase _db;

  @override
  Future<Song?> songForCard(String cardKey) async {
    final query = _db.select(_db.cardMappingRows).join([
      innerJoin(_db.songRows, _db.songRows.id.equalsExp(_db.cardMappingRows.songId)),
    ])
      ..where(_db.cardMappingRows.cardKey.equals(cardKey))
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.readTable(_db.songRows).toSong();
  }

  @override
  Future<void> assign({
    required String cardKey,
    required String raw,
    required Song song,
  }) {
    // In einer Transaktion: eine Zuordnung auf einen Song, den es nicht gibt,
    // wäre schlimmer als gar keine.
    return _db.transaction(() async {
      await _db.into(_db.songRows).insertOnConflictUpdate(songToRow(song));
      await _db.into(_db.cardMappingRows).insertOnConflictUpdate(
            CardMappingRowsCompanion.insert(
              cardKey: cardKey,
              songId: song.id,
              raw: Value(raw),
              createdAt: DateTime.now(),
            ),
          );
    });
  }

  @override
  Future<void> remove(String cardKey) {
    return (_db.delete(_db.cardMappingRows)
          ..where((t) => t.cardKey.equals(cardKey)))
        .go();
  }

  @override
  Future<int> count() async {
    final rows = await _db.select(_db.cardMappingRows).get();
    return rows.length;
  }

  @override
  Future<String> exportJson() async {
    final query = _db.select(_db.cardMappingRows).join([
      innerJoin(_db.songRows, _db.songRows.id.equalsExp(_db.cardMappingRows.songId)),
    ]);

    final entries = [
      for (final row in await query.get())
        {
          'card': row.readTable(_db.cardMappingRows).cardKey,
          'raw': row.readTable(_db.cardMappingRows).raw,
          'title': row.readTable(_db.songRows).title,
          'artist': row.readTable(_db.songRows).artist,
          'year': row.readTable(_db.songRows).year,
        },
    ];

    return const JsonEncoder.withIndent('  ').convert({
      'format': formatVersion,
      'mappings': entries,
    });
  }

  @override
  Future<ImportOutcome> importJson(String json) async {
    final List<dynamic> entries;
    try {
      final decoded = jsonDecode(json);
      final raw = decoded is Map ? decoded['mappings'] : decoded;
      if (raw is! List) {
        return const ImportOutcome(
          imported: 0,
          skipped: 0,
          error: 'Die Datei enthält keine Liste von Zuordnungen.',
        );
      }
      entries = raw;
    } on FormatException {
      return const ImportOutcome(
        imported: 0,
        skipped: 0,
        error: 'Die Datei ist kein lesbares JSON.',
      );
    }

    var imported = 0;
    var skipped = 0;

    for (final entry in entries) {
      if (entry is! Map) {
        skipped++;
        continue;
      }

      final cardKey = entry['card'] as String?;
      final title = entry['title'] as String?;
      final artist = entry['artist'] as String?;
      final year = switch (entry['year']) {
        final int v => v,
        final String v => int.tryParse(v),
        _ => null,
      };

      if (cardKey == null || title == null || artist == null || year == null) {
        skipped++;
        continue;
      }

      await assign(
        cardKey: cardKey,
        raw: entry['raw'] as String? ?? '',
        song: Song(
          // Aus der Karte abgeleitet, damit ein erneuter Import denselben
          // Song trifft statt einen zweiten anzulegen.
          id: 'card:$cardKey',
          title: title,
          artist: artist,
          year: year,
          // Von Hand zugeordnet — wiegt schwerer als jede automatische
          // Auflösung und darf nicht überschrieben werden.
          yearSource: YearSource.card,
        ),
      );
      imported++;
    }

    return ImportOutcome(imported: imported, skipped: skipped);
  }

  @override
  Future<ImportOutcome> importCardListCsv(
    String csv, {
    required String language,
    String? sku,
  }) async {
    final parsed = parseCardListCsv(csv);
    if (parsed.isFailure) {
      return ImportOutcome(imported: 0, skipped: 0, error: parsed.error);
    }

    // Eine Liste hat mehrere hundert Zeilen — als eine Transaktion, damit
    // ein Abbruch nicht die Hälfte einer Ausgabe hinterlässt.
    await _db.transaction(() async {
      for (final entry in parsed.entries) {
        final key = cardMappingKey(
          number: entry.cardNumber,
          language: language,
          sku: sku,
        );
        // Die Kennung enthält die Ausgabe, nicht nur die Nummer: sonst
        // überschriebe eine zweite Ausgabe die Songs der ersten.
        await _db.into(_db.songRows).insertOnConflictUpdate(
              songToRow(entry.song.withId('card:$key')),
            );
        await _db.into(_db.cardMappingRows).insertOnConflictUpdate(
              CardMappingRowsCompanion.insert(
                cardKey: key,
                songId: 'card:$key',
                raw: const Value(''),
                createdAt: DateTime.now(),
              ),
            );
      }
    });

    return ImportOutcome(
      imported: parsed.entries.length,
      skipped: parsed.skipped,
    );
  }
}

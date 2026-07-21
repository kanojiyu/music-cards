/// Einlesen fertiger Kartenlisten als CSV.
///
/// Für gekaufte Kartensätze ist das der einzige zumutbare Weg: Ein voller
/// Satz hat mehrere hundert Karten, und der Hersteller löst die Nummern
/// nicht öffentlich auf. Von Hand wäre das ein Abend Arbeit.
library;

import 'package:csv/csv.dart';

import '../core/models.dart';

/// Eine Zeile aus einer Kartenliste, bereits geprüft.
class CardListEntry {
  const CardListEntry({
    required this.cardNumber,
    required this.song,
  });

  /// Die Nummer, wie sie auf der Karte steht — ohne führende Nullen.
  final int cardNumber;
  final Song song;
}

/// Was beim Einlesen herauskam.
class CardListImport {
  const CardListImport({
    required this.entries,
    required this.skipped,
    this.error,
  });

  final List<CardListEntry> entries;

  /// Zeilen, die keine brauchbare Karte ergaben.
  final int skipped;

  /// Gesetzt, wenn die Datei insgesamt unlesbar war.
  final String? error;

  bool get isFailure => error != null;
}

/// Spaltennamen, die als Kartennummer, Titel, Künstler, Jahr und Adresse
/// gelten.
///
/// Mehrere Schreibweisen, weil Listen aus verschiedenen Quellen stammen und
/// niemand sie aufeinander abgestimmt hat.
const _columnAliases = {
  'number': ['card#', 'card', 'nummer', 'kartennummer', 'no', 'nr'],
  'title': ['title', 'titel', 'song', 'track'],
  'artist': ['artist', 'künstler', 'kuenstler', 'interpret'],
  'year': ['year', 'jahr'],
  'url': ['url', 'link', 'youtube', 'youtube-url'],
};

/// Liest eine Kartenliste ein.
///
/// Erwartet eine Kopfzeile. Welche Spalte was bedeutet, wird über ihren Namen
/// bestimmt — nicht über ihre Position, damit auch abweichend sortierte
/// Listen funktionieren.
CardListImport parseCardListCsv(String csv) {
  final List<List<dynamic>> rows;
  try {
    rows = Csv().decode(csv.replaceAll('\r\n', '\n'));
  } on Object {
    return const CardListImport(
      entries: [],
      skipped: 0,
      error: 'Die Datei ließ sich nicht als CSV lesen.',
    );
  }

  if (rows.length < 2) {
    return const CardListImport(
      entries: [],
      skipped: 0,
      error: 'Die Datei enthält keine Kopfzeile mit Daten darunter.',
    );
  }

  final header = [
    for (final cell in rows.first) cell.toString().trim().toLowerCase(),
  ];
  final columns = {
    for (final entry in _columnAliases.entries)
      entry.key: header.indexWhere((name) => entry.value.contains(name)),
  };

  if (columns['title'] == -1 ||
      columns['artist'] == -1 ||
      columns['year'] == -1) {
    return const CardListImport(
      entries: [],
      skipped: 0,
      error: 'Es fehlen Spalten. Nötig sind Titel, Künstler und Jahr, '
          'dazu die Kartennummer.',
    );
  }

  String? cell(List<dynamic> row, String column) {
    final index = columns[column]!;
    if (index == -1 || index >= row.length) return null;
    final value = row[index].toString().trim();
    return value.isEmpty ? null : value;
  }

  final entries = <CardListEntry>[];
  var skipped = 0;

  for (final row in rows.skip(1)) {
    final number = int.tryParse(cell(row, 'number') ?? '');
    final title = cell(row, 'title');
    final artist = cell(row, 'artist');
    final year = int.tryParse(cell(row, 'year') ?? '');

    if (number == null || title == null || artist == null || year == null) {
      skipped++;
      continue;
    }

    final videoId = youtubeVideoId(cell(row, 'url'));

    entries.add(CardListEntry(
      cardNumber: number,
      song: Song(
        // Aus Nummer und Titel abgeleitet, damit ein erneuter Import
        // dieselben Songs trifft statt Doppel anzulegen.
        id: 'card:$number',
        title: title,
        artist: artist,
        year: year,
        // Das Jahr steht auf der Karte und ist damit maßgeblich.
        yearSource: YearSource.card,
        providerIds:
            videoId == null ? const {} : {MusicService.youtube: videoId},
      ),
    ));
  }

  return CardListImport(entries: entries, skipped: skipped);
}

/// Zieht die Video-Kennung aus einer YouTube-Adresse.
///
/// Erkennt beide gebräuchlichen Formen: `youtube.com/watch?v=…` und
/// `youtu.be/…`.
String? youtubeVideoId(String? url) {
  if (url == null || url.isEmpty) return null;

  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  if (uri.host.endsWith('youtu.be')) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty);
    return segments.isEmpty ? null : segments.first;
  }

  if (uri.host.endsWith('youtube.com')) {
    final id = uri.queryParameters['v'];
    if (id != null && id.isNotEmpty) return id;
    // Kurzform /embed/<id> und /v/<id>
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2 && {'embed', 'v'}.contains(segments.first)) {
      return segments[1];
    }
  }

  return null;
}

/// Bildet den Schlüssel, unter dem eine Kartennummer abgelegt wird.
///
/// Muss zu `PrintedCard.mappingKey` passen: Der QR-Code trägt die Nummer mit
/// führenden Nullen, die Listen führen sie ohne.
String cardMappingKey({
  required int number,
  required String language,
  String? sku,
  int digits = 5,
}) {
  final padded = number.toString().padLeft(digits, '0');
  return [language, sku ?? '-', padded].join('/');
}

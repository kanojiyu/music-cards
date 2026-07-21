import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/core/models.dart';
import 'package:music_cards/scan/card_list_import.dart';
import 'package:music_cards/scan/printed_card.dart';

void main() {
  group('parseCardListCsv', () {
    test('liest eine Liste im Aufbau der Songseeker-Dateien', () {
      const csv = '''
Card#,Artist,Title,URL,Hashed Info,Youtube-Title,Year
1,Beispielband,Beispieltitel,https://www.youtube.com/watch?v=abc12345678,xx,yy,1987
2,Zweite Band,Zweiter Titel,https://youtu.be/def45678901,xx,yy,1999
''';

      final result = parseCardListCsv(csv);

      expect(result.entries, hasLength(2));
      expect(result.entries.first.cardNumber, 1);
      expect(result.entries.first.song.year, 1987);
      expect(result.entries.first.song.providerIds[MusicService.youtube],
          'abc12345678');
      expect(result.entries.last.song.providerIds[MusicService.youtube],
          'def45678901');
    });

    // Titel enthalten regelmäßig Kommas.
    test('kommt mit Kommas in Anführungszeichen zurecht', () {
      const csv = '''
Card#,Artist,Title,Year
7,"Band, mit Komma","Titel, mit Komma",1975
''';

      final entry = parseCardListCsv(csv).entries.single;

      expect(entry.song.artist, 'Band, mit Komma');
      expect(entry.song.title, 'Titel, mit Komma');
    });

    // Listen aus verschiedenen Quellen benennen die Spalten unterschiedlich.
    test('erkennt deutsche Spaltennamen und abweichende Reihenfolge', () {
      const csv = '''
Jahr,Titel,Interpret,Nummer
1982,Ein Titel,Ein Interpret,42
''';

      final entry = parseCardListCsv(csv).entries.single;

      expect(entry.cardNumber, 42);
      expect(entry.song.title, 'Ein Titel');
      expect(entry.song.artist, 'Ein Interpret');
      expect(entry.song.year, 1982);
    });

    test('markiert das Jahr als von der Karte stammend', () {
      const csv = 'Card#,Artist,Title,Year\n1,A,B,1990\n';

      expect(parseCardListCsv(csv).entries.single.song.yearSource,
          YearSource.card);
    });

    test('kommt ohne URL-Spalte zurecht', () {
      const csv = 'Card#,Artist,Title,Year\n1,A,B,1990\n';

      expect(parseCardListCsv(csv).entries.single.song.providerIds, isEmpty);
    });

    // Eine mühsam beschaffte Liste darf nicht an einer Zeile scheitern.
    test('überspringt unbrauchbare Zeilen und behält den Rest', () {
      const csv = '''
Card#,Artist,Title,Year
1,A,B,1990
,ohne Nummer,C,1990
3,ohne Jahr,D,
4,E,F,2001
''';

      final result = parseCardListCsv(csv);

      expect(result.entries, hasLength(2));
      expect(result.skipped, 2);
    });

    // Deutsche Titel und Künstlernamen enthalten regelmäßig Umlaute. Werden
    // die Dateibytes als Zeichen statt als UTF-8 gelesen, zerfällt jeder
    // Umlaut in zwei Wirrzeichen.
    test('gibt Umlaute unverfälscht zurück', () {
      const csv = 'Card#,Artist,Title,Year\n1,Nena,Für dich,1983\n';

      final entry = parseCardListCsv(csv).entries.single;

      expect(entry.song.title, 'Für dich');
    });

    test('verträgt Windows-Zeilenenden', () {
      const csv = 'Card#,Artist,Title,Year\r\n1,A,B,1990\r\n';

      expect(parseCardListCsv(csv).entries, hasLength(1));
    });

    group('unbrauchbare Dateien', () {
      test('nur eine Kopfzeile', () {
        final result = parseCardListCsv('Card#,Artist,Title,Year\n');

        expect(result.isFailure, isTrue);
        expect(result.error, contains('Kopfzeile'));
      });

      test('fehlende Pflichtspalten', () {
        final result = parseCardListCsv('Nummer,Irgendwas\n1,x\n');

        expect(result.isFailure, isTrue);
        expect(result.error, contains('fehlen Spalten'));
      });
    });
  });

  group('youtubeVideoId', () {
    test('erkennt die gebräuchlichen Adressformen', () {
      const id = 'abc12345678';
      for (final url in [
        'https://www.youtube.com/watch?v=$id',
        'https://youtu.be/$id',
        'https://www.youtube.com/embed/$id',
        'https://www.youtube.com/watch?v=$id&t=42s',
      ]) {
        expect(youtubeVideoId(url), id, reason: url);
      }
    });

    test('liefert nichts bei fremden oder leeren Adressen', () {
      expect(youtubeVideoId(null), isNull);
      expect(youtubeVideoId(''), isNull);
      expect(youtubeVideoId('https://example.org/watch?v=x'), isNull);
      expect(youtubeVideoId('https://www.youtube.com/'), isNull);
    });
  });

  group('cardMappingKey', () {
    // Der QR-Code trägt führende Nullen, die Listen führen die Nummer ohne.
    // Passt das nicht zusammen, findet der Scan die importierte Karte nicht.
    test('passt zum Schlüssel aus dem Scan', () {
      final ausScan = parsePrintedCard('www.example.com/de/00172').mappingKey;
      final ausListe = cardMappingKey(number: 172, language: 'de');

      expect(ausListe, ausScan);
    });

    test('füllt auf fünf Stellen auf', () {
      expect(cardMappingKey(number: 1, language: 'de'), 'de/-/00001');
      expect(cardMappingKey(number: 308, language: 'de'), 'de/-/00308');
    });

    test('berücksichtigt die Ausgabe, wenn eine angegeben ist', () {
      expect(cardMappingKey(number: 7, language: 'de', sku: 'aaaa0039'),
          'de/aaaa0039/00007');
    });
  });
}

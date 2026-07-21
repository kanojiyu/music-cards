import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/scan/printed_card.dart';

void main() {
  group('gekaufte Karten', () {
    // So steht es tatsächlich auf den Karten: ohne https:// davor. Ohne
    // Ergänzung erkennt Uri.tryParse darin keinen Host.
    test('erkennt eine Adresse ohne Schema', () {
      final card = parsePrintedCard('www.example-game.com/de/00172');

      expect(card.language, 'de');
      expect(card.number, '00172');
      expect(card.isResolvable, isTrue);
    });

    test('erkennt Sprache und Nummer', () {
      final card = parsePrintedCard('https://www.example-game.com/de/00268');

      expect(card.language, 'de');
      expect(card.number, '00268');
      expect(card.isResolvable, isTrue);
    });

    test('erkennt zusätzlich eine Artikelkennung', () {
      final card =
          parsePrintedCard('https://www.example-game.com/de/aaa02/00268');

      expect(card.language, 'de');
      expect(card.sku, 'aaa02');
      expect(card.number, '00268');
    });

    test('behält führende Nullen', () {
      expect(parsePrintedCard('https://x.de/de/00007').number, '00007');
    });

    test('nimmt die letzte Zahl als Kartennummer', () {
      final card = parsePrintedCard('https://x.de/de-de/2024/00268');

      expect(card.number, '00268');
      expect(card.sku, '2024');
    });
  });

  group('selbstgedruckte Karten', () {
    test('erkennt einen unmittelbaren Titel-Link', () {
      for (final url in [
        'https://open.spotify.com/track/0VjIjW4GlUZAMYd2vXMi3b',
        'https://tidal.com/browse/track/539204',
        'https://music.apple.com/de/album/x/123?i=456',
        'https://youtu.be/dQw4w9WgXcQ',
      ]) {
        final card = parsePrintedCard(url);
        expect(card.directTrackUrl, isNotNull, reason: url);
        expect(card.isResolvable, isTrue, reason: url);
      }
    });

    test('ein Titel-Link braucht keine Kartennummer', () {
      final card =
          parsePrintedCard('https://open.spotify.com/track/0VjIjW4GlUZ');

      expect(card.number, isNull);
      expect(card.directTrackUrl!.host, 'open.spotify.com');
    });
  });

  group('unbekannte Karten', () {
    // Ein Scanner, der bei Unbekanntem nichts liefert, verrät nicht, was er
    // gesehen hat — und ohne das lässt sich keine neue Kartensorte ergänzen.
    test('behält immer den Rohwert', () {
      for (final raw in [
        'völlig anderer Inhalt',
        'https://example.org/ohne/zahlen',
        '',
        '12345',
      ]) {
        expect(parsePrintedCard(raw).raw, raw.trim(), reason: raw);
      }
    });

    test('meldet ehrlich, dass nichts aufzulösen ist', () {
      expect(parsePrintedCard('irgendein Text').isResolvable, isFalse);
      expect(
          parsePrintedCard('https://example.org/ohne/zahlen').isResolvable,
          isFalse);
    });

    test('entfernt Leerraum am Rand', () {
      expect(parsePrintedCard('  https://x.de/de/00268  ').number, '00268');
      expect(parsePrintedCard('  www.x.de/de/00268  ').number, '00268');
    });

    // Fließtext darf nicht versehentlich als Adresse durchgehen.
    test('hält Text ohne Punkt für keine Adresse', () {
      expect(parsePrintedCard('karte 00172').isResolvable, isFalse);
      expect(parsePrintedCard('einfach nur text').isResolvable, isFalse);
    });
  });
}

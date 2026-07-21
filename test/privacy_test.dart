/// Hält fest, wohin die App überhaupt Verbindungen aufbauen darf.
///
/// Die App soll außer YouTube für die Videos und der Quelle der Kartenlisten
/// nichts kontaktieren und keine Daten über die Nutzung sammeln. Ohne einen
/// Test dafür schleicht sich so etwas beim nächsten Feature unbemerkt wieder
/// ein.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_cards/scan/card_set_catalog.dart';

/// Alle Adressen, die im Quelltext der App vorkommen.
List<({String file, String url})> _urlsInSource() {
  final found = <({String file, String url})>[];
  final pattern = RegExp(r'https?://[a-zA-Z0-9.\-]+');

  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    // Erzeugter Code zählt nicht — er enthält Verweise auf Werkzeuge.
    if (entity.path.endsWith('.g.dart')) continue;

    for (final line in entity.readAsLinesSync()) {
      final trimmed = line.trimLeft();
      // Kommentare beschreiben nur, sie verbinden nichts.
      if (trimmed.startsWith('//')) continue;

      for (final match in pattern.allMatches(line)) {
        found.add((file: entity.path, url: match.group(0)!));
      }
    }
  }
  return found;
}

void main() {
  group('Netzwerkziele', () {
    /// Wohin die App sprechen darf, und wofür.
    const erlaubt = {
      // Die Videos zu den Karten.
      'https://www.youtube-nocookie.com',
      'https://www.youtube.com',
      'https://youtu.be',
      // Die Kartenlisten.
      'https://raw.githubusercontent.com',
    };

    test('im Quelltext steht kein unerwartetes Ziel', () {
      final unerwartet = [
        for (final entry in _urlsInSource())
          if (!erlaubt.any(entry.url.startsWith)) entry,
      ];

      expect(
        unerwartet,
        isEmpty,
        reason: 'Unerwartete Ziele:\n'
            '${unerwartet.map((e) => "  ${e.url} in ${e.file}").join("\n")}',
      );
    });

    test('alle Ziele sind mit TLS gesichert', () {
      for (final entry in _urlsInSource()) {
        expect(entry.url, startsWith('https://'), reason: entry.file);
      }
    });

    test('das Verzeichnis der Ausgaben lädt nur von der bekannten Quelle', () {
      for (final entry in cardSetCatalog) {
        expect(entry.url.host, 'raw.githubusercontent.com',
            reason: entry.name);
        expect(entry.url.scheme, 'https', reason: entry.name);
      }
    });
  });

  group('Keine Datensammlung', () {
    // Analyse- und Absturzmelder senden Nutzungsdaten. Keiner davon gehört
    // in diese App.
    test('keine Analyse- oder Telemetriepakete eingebunden', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      for (final verdaechtig in [
        'firebase',
        'analytics',
        'crashlytics',
        'sentry',
        'mixpanel',
        'amplitude',
        'segment',
        'posthog',
        'appcenter',
        'matomo',
      ]) {
        expect(pubspec.toLowerCase(), isNot(contains(verdaechtig)),
            reason: 'Paket „$verdaechtig“ sammelt Nutzungsdaten.');
      }
    });

    test('keine Gerätekennungen ausgelesen', () {
      final quellen = [
        for (final entity in Directory('lib').listSync(recursive: true))
          if (entity is File &&
              entity.path.endsWith('.dart') &&
              !entity.path.endsWith('.g.dart'))
            entity.readAsStringSync(),
      ].join('\n');

      for (final verdaechtig in [
        'advertisingId',
        'androidId',
        'identifierForVendor',
        'deviceInfo',
      ]) {
        expect(quellen, isNot(contains(verdaechtig)), reason: verdaechtig);
      }
    });
  });
}

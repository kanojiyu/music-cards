/// Durchstich durch die neue Oberfläche: Startbildschirm und Einstellungen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:music_cards/app_dependencies.dart';
import 'package:music_cards/data/database.dart';
import 'package:music_cards/main.dart';
import 'package:music_cards/scan/card_mapping_store.dart';
import 'package:music_cards/scan/card_set_store.dart';
import 'package:music_cards/settings/app_settings.dart';

import 'support/in_memory_playlist_store.dart';

const _liste = '''
Card#,Artist,Title,URL,Year
172,Ein Interpret,Ein Titel,https://www.youtube.com/watch?v=abc12345678,1987
''';

void main() {
  late AppDatabase db;
  late AppDependencies deps;

  setUp(() {
    db = AppDatabase.inMemory();
    deps = AppDependencies(
      playlists: InMemoryPlaylistStore(),
      cardMappings: DriftCardMappingStore(db),
      cardSets: DriftCardSetStore(
        db,
        client: MockClient((_) async => http.Response(_liste, 200)),
      ),
      settings: DriftSettingsStore(db),
    );
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MusicCardsApp(deps: deps));
    await tester.pumpAndSettle();
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  /// Taktet einen Vorgang durch, der die Datenbank anfasst.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
  }

  group('Startbildschirm', () {
    // Beim Spielen liegt das Gerät auf dem Tisch und wird herumgereicht —
    // jede zusätzliche Schaltfläche wäre eine, die versehentlich trifft.
    testWidgets('zeigt nur Spielen und Einstellungen', (tester) async {
      await pumpApp(tester);

      expect(find.bySemanticsLabel('Spielen'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('ohne Karten lässt sich nicht spielen', (tester) async {
      await pumpApp(tester);

      expect(find.textContaining('Noch keine Karten'), findsOneWidget);
      expect(find.text('Ausgabe wählen'), findsOneWidget);
    });

    testWidgets('mit Karten wird die Anzahl genannt', (tester) async {
      await deps.cardMappings.importCardListCsv(_liste, language: 'de');

      await pumpApp(tester);

      expect(find.text('1 Karten bereit'), findsOneWidget);
      expect(find.textContaining('Noch keine Karten'), findsNothing);
    });
  });

  group('Einstellungen', () {
    testWidgets('lassen sich vom Startbildschirm öffnen', (tester) async {
      await pumpApp(tester);
      await openSettings(tester);

      expect(find.text('Wiedergabe starten'), findsOneWidget);
    });

    testWidgets('die Startart lässt sich umstellen und wird gespeichert',
        (tester) async {
      await pumpApp(tester);
      await openSettings(tester);

      await tester.tap(find.text('Nach einer festen Wartezeit'));
      await settle(tester);

      expect(find.textContaining('Wartezeit:'), findsOneWidget);
      expect((await deps.settings.read()).trigger, PlaybackTrigger.delay);
    });

    // Die Lizenz der Kartenlisten verlangt eine Nennung der Quelle.
    testWidgets('nennt die Herkunft der Kartenlisten', (tester) async {
      await pumpApp(tester);
      await openSettings(tester);

      expect(find.textContaining('MIT-Lizenz'), findsOneWidget);
    });

    testWidgets('ohne Ausgabe steht ein Hinweis statt einer leeren Liste',
        (tester) async {
      await pumpApp(tester);
      await openSettings(tester);

      expect(find.textContaining('Noch keine Ausgabe geladen'), findsOneWidget);
    });
  });

  group('Ausgabe hinzufügen', () {
    Future<void> openAdd(WidgetTester tester) async {
      await pumpApp(tester);
      await openSettings(tester);
      await tester.tap(find.text('Hinzufügen'));
      await tester.pumpAndSettle();
    }

    testWidgets('listet die mitgelieferten Ausgaben auf', (tester) async {
      await openAdd(tester);

      expect(find.text('Deutschland'), findsOneWidget);
      expect(find.textContaining('Rock'), findsOneWidget);
    });

    testWidgets('eine gewählte Ausgabe wird geladen und erscheint',
        (tester) async {
      await openAdd(tester);

      await tester.tap(find.text('Deutschland'));
      await settle(tester);

      expect((await deps.cardSets.all()).single.name, 'Deutschland');
      expect(find.textContaining('1 Karten'), findsOneWidget);
    });

    testWidgets('eine eigene Ausgabe braucht einen Namen', (tester) async {
      await openAdd(tester);

      await tester.enterText(
          find.widgetWithText(TextField, 'oder Adresse einer CSV-Datei'),
          'https://example.org/liste.csv');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laden'));
      await settle(tester);

      expect(find.textContaining('braucht einen Namen'), findsOneWidget);
    });
  });
}

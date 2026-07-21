# Music Cards

Eine App, mit der sich gedruckte Musik-Ratekarten digital abspielen lassen.
Karte scannen, Gerät umdrehen, Song hören, auflösen.

Die App braucht kein Konto, kein Abo und sammelt keine Daten. Sie verbindet
sich ausschließlich mit zwei Zielen: YouTube für die Videos und GitHub für die
Kartenlisten.

## Wie es funktioniert

Gedruckte Karten tragen einen QR-Code mit einer Adresse der Form
`.../<sprache>/<nummer>`. Der Hersteller löst diese Nummer nicht öffentlich
auf, deshalb arbeitet die App mit Zuordnungslisten: Kartennummer → Titel,
Künstler, Jahr und YouTube-Video.

Beim Spielen wird die Karte gescannt, ohne etwas zu verraten. Erst wenn das
Gerät mit dem Bildschirm nach unten liegt, startet die Wiedergabe — so sieht
niemand am Tisch, welcher Song läuft. Nach dem Zurückdrehen erscheinen Jahr,
Titel und Künstler.

## Einrichten

1. **Einstellungen → Hinzufügen** und eine Ausgabe wählen. Die Liste wird
   einmal geladen und dauerhaft gespeichert.
2. Zurück zum Startbildschirm, **Play** drücken.

Eigene Kartensätze lassen sich als CSV einlesen — per Datei, Adresse oder
Zwischenablage. Nötig sind die Spalten Kartennummer, Titel, Künstler und Jahr;
eine Spalte mit YouTube-Adressen wird mitgenommen, wenn vorhanden. Die
Spaltennamen dürfen deutsch oder englisch sein und in beliebiger Reihenfolge
stehen.

Startet die Wiedergabe auf deinem Gerät nicht zuverlässig beim Umdrehen —
etwa wegen einer dicken Hülle —, lässt sich in den Einstellungen auf eine
feste Wartezeit umstellen.

## Bauen

```bash
flutter pub get
dart run build_runner build
flutter run
```

## Aufbau

| Verzeichnis | Inhalt |
|---|---|
| `lib/scan/` | Karten lesen, zuordnen, Ausgaben verwalten, Lageerkennung |
| `lib/game/` | Spielregeln als reine Zustandsmaschine, ohne Oberfläche |
| `lib/data/` | Datenbank und Ablagen |
| `lib/ui/` | Bildschirme |
| `tool/make_icon.py` | erzeugt das App-Symbol in allen Größen |

Die Regeln in `lib/game/` gehören zu einem digitalen Spielmodus, der derzeit
nicht in der Navigation hängt. Sie sind vollständig getestet und als Grundlage
für einen Mehrgeräte-Modus gedacht.

```bash
flutter test
```

`test/privacy_test.dart` hält fest, dass die App keine anderen Ziele
kontaktiert und keine Analyse-Pakete einbindet. Der Test schlägt an, sobald
sich daran etwas ändert.

## Herkunft der Kartenlisten

Die Zuordnungslisten stammen aus
[andygruber/songseeker-hitster-playlists](https://github.com/andygruber/songseeker-hitster-playlists)
und stehen unter der MIT-Lizenz. Sie werden nicht mitgeliefert, sondern bei
Bedarf geladen.

Dieses Projekt steht in keiner Verbindung zu einem Kartenspiel-Hersteller. Es
hilft lediglich, bereits gekaufte Karten abzuspielen.

## Lizenz

CC0 1.0 Universal — siehe [`LICENSE`](LICENSE) und [`NOTICE.md`](NOTICE.md).
Nutze es, verändere es, gib es weiter. Es braucht keine Erlaubnis und keine
Nennung.

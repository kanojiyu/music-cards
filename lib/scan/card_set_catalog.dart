/// Verzeichnis der Kartenausgaben, die die App von Haus aus kennt.
///
/// Die Listen selbst liegen nicht in der App, sondern werden beim ersten
/// Auswählen geladen und danach dauerhaft gespeichert. Das hält die App klein
/// und die Daten aktuell.
///
/// Quelle der Listen: `andygruber/songseeker-hitster-playlists` auf GitHub,
/// veröffentlicht unter der MIT-Lizenz.
library;

/// Eine Ausgabe, die die App vorschlagen kann.
class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.name,
    required this.language,
    required this.file,
    this.sku,
  });

  final String id;

  /// Anzeigename, wie ihn die Quelle führt.
  final String name;

  /// Sprachkürzel, wie es im QR-Code der Karten steht.
  final String language;

  /// Kennung der Ausgabe. `null` für die jeweilige Grundausgabe, deren Karten
  /// keine Ausgabekennung im Code tragen.
  final String? sku;

  final String file;

  Uri get url => Uri.parse('$_baseUrl$file');
}

const _baseUrl =
    'https://raw.githubusercontent.com/andygruber/songseeker-hitster-playlists/main/';

/// Woher die Listen stammen — gehört in die Oberfläche, weil die Lizenz eine
/// Nennung verlangt.
const catalogAttribution =
    'Kartenlisten von andygruber/songseeker-hitster-playlists (MIT-Lizenz)';

/// Alle bekannten Ausgaben.
///
/// Die Grundausgaben tragen keine Ausgabekennung: Ihre QR-Codes haben die
/// Form `…/de/00172`, während Erweiterungen zusätzlich eine Kennung führen.
const cardSetCatalog = <CatalogEntry>[
  CatalogEntry(
    id: 'de',
    name: 'Deutschland',
    language: 'de',
    file: 'hitster-de.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0007',
    name: 'Deutschland — Schlagerparty',
    language: 'de',
    sku: 'aaaa0007',
    file: 'hitster-de-aaaa0007.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0012',
    name: 'Deutschland — Summer Party',
    language: 'de',
    sku: 'aaaa0012',
    file: 'hitster-de-aaaa0012.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0015',
    name: 'Deutschland — Guilty Pleasures',
    language: 'de',
    sku: 'aaaa0015',
    file: 'hitster-de-aaaa0015.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0019',
    name: 'Deutschland — Bingo',
    language: 'de',
    sku: 'aaaa0019',
    file: 'hitster-de-aaaa0019.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0025',
    name: 'Deutschland — Bayern 1',
    language: 'de',
    sku: 'aaaa0025',
    file: 'hitster-de-aaaa0025.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0026',
    name: 'Deutschland — Movies & TV',
    language: 'de',
    sku: 'aaaa0026',
    file: 'hitster-de-aaaa0026.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0039',
    name: 'Deutschland — Rock',
    language: 'de',
    sku: 'aaaa0039',
    file: 'hitster-de-aaaa0039.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0040',
    name: 'Deutschland — Celebration',
    language: 'de',
    sku: 'aaaa0040',
    file: 'hitster-de-aaaa0040.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0042',
    name: 'Deutschland — Christmas',
    language: 'de',
    sku: 'aaaa0042',
    file: 'hitster-de-aaaa0042.csv',
  ),
  CatalogEntry(
    id: 'de-aaaa0054',
    name: 'Deutschland — weitere Ausgabe',
    language: 'de',
    sku: 'aaaa0054',
    file: 'hitster-de-aaaa0054.csv',
  ),
  CatalogEntry(
    id: 'fr',
    name: 'France',
    language: 'fr',
    file: 'hitster-fr.csv',
  ),
  CatalogEntry(
    id: 'fr-aaaa0031',
    name: 'France — Summer Party',
    language: 'fr',
    sku: 'aaaa0031',
    file: 'hitster-fr-aaaa0031.csv',
  ),
  CatalogEntry(
    id: 'nl',
    name: 'Netherlands',
    language: 'nl',
    file: 'hitster-nl.csv',
  ),
  CatalogEntry(
    id: 'nordics',
    name: 'Nordics',
    language: 'fi',
    file: 'hitster-nordics.csv',
  ),
  CatalogEntry(
    id: 'ca-aaad0001',
    name: 'Canada',
    language: 'en',
    sku: 'aaad0001',
    file: 'hitster-ca-aaad0001.csv',
  ),
  CatalogEntry(
    id: 'hu-aaae0003',
    name: 'Magyar kiadás',
    language: 'hu',
    sku: 'aaae0003',
    file: 'hitster-hu-aaae0003.csv',
  ),
  CatalogEntry(
    id: 'pl-aaae0001',
    name: 'Central Europe',
    language: 'pl',
    sku: 'aaae0001',
    file: 'hitster-pl-aaae0001.csv',
  ),
  CatalogEntry(
    id: 'pl-aaae0004',
    name: 'Central Europe — Summer Party',
    language: 'pl',
    sku: 'aaae0004',
    file: 'hitster-pl-aaae0004.csv',
  ),
];

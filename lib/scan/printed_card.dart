/// Was auf einer gedruckten Karte steht.
///
/// Das gesamte herstellerspezifische Wissen liegt in dieser Datei. Der Rest
/// der App kennt nur [PrintedCard] und weiß nicht, woher sie stammt.
library;

/// Ein gescannter Code, bereits in seine Bestandteile zerlegt.
class PrintedCard {
  const PrintedCard({
    required this.raw,
    this.language,
    this.sku,
    this.number,
    this.directTrackUrl,
  });

  /// Der unveränderte Inhalt des QR-Codes.
  ///
  /// Wird immer mitgeführt: Solange nicht feststeht, welche Kartensorten es
  /// gibt, ist der Rohwert die einzig verlässliche Angabe — und das, was
  /// beim Melden einer unbekannten Karte weiterhilft.
  final String raw;

  final String? language;
  final String? sku;
  final String? number;

  /// Manche selbstgedruckten Karten zeigen direkt auf einen Titel bei einem
  /// Streaming-Anbieter. Dann braucht es keine Auflösung über den Hersteller.
  final Uri? directTrackUrl;

  /// Ob sich daraus überhaupt ein Titel ermitteln lässt.
  bool get isResolvable => directTrackUrl != null || number != null;

  /// Eindeutiger Schlüssel für die gespeicherte Zuordnung.
  ///
  /// Sprache und Ausgabe gehören dazu: dieselbe Nummer bezeichnet in der
  /// deutschen und der englischen Ausgabe verschiedene Titel.
  ///
  /// `null`, wenn die Karte keine Nummer trägt — dann gibt es nichts
  /// zuzuordnen.
  String? get mappingKey {
    if (number == null) return null;
    return [language ?? '-', sku ?? '-', number].join('/');
  }

  @override
  String toString() => directTrackUrl != null
      ? 'PrintedCard(direkt: $directTrackUrl)'
      : 'PrintedCard($language/$sku/$number)';
}

/// Zerlegt den Inhalt eines QR-Codes.
///
/// Erkennt bislang zwei Formen:
/// - Selbstgedruckte Karten, deren Code direkt auf einen Titel zeigt.
/// - Gekaufte Karten mit einer Hersteller-Adresse der Form
///   `<host>/<sprache>/<nummer>` oder `<host>/<sprache>/<sku>/<nummer>`.
///
/// Passt nichts davon, kommt trotzdem eine [PrintedCard] mit dem Rohwert
/// zurück. Ein Scanner, der bei unbekannten Karten gar nichts liefert,
/// verrät nicht, was er gesehen hat — und genau das braucht man, um eine
/// neue Kartensorte überhaupt zu unterstützen.
PrintedCard parsePrintedCard(String raw) {
  final trimmed = raw.trim();
  final uri = _asUri(trimmed);

  if (uri == null) {
    return PrintedCard(raw: trimmed);
  }

  if (_trackHosts.any((host) => uri.host.endsWith(host))) {
    return PrintedCard(raw: trimmed, directTrackUrl: uri);
  }

  final segments =
      uri.pathSegments.where((segment) => segment.isNotEmpty).toList();

  // Die Nummer ist das letzte rein numerische Segment; davor stehen je nach
  // Ausgabe Sprache und Artikelkennung.
  final numberIndex =
      segments.lastIndexWhere((segment) => RegExp(r'^\d+$').hasMatch(segment));
  if (numberIndex == -1) {
    return PrintedCard(raw: trimmed);
  }

  return PrintedCard(
    raw: trimmed,
    number: segments[numberIndex],
    language: numberIndex >= 1 ? segments[0] : null,
    sku: numberIndex >= 2 ? segments[numberIndex - 1] : null,
  );
}

/// Liest den Code als Adresse — auch ohne vorangestelltes Schema.
///
/// Gedruckte Karten tragen die Adresse häufig verkürzt, etwa
/// `www.beispiel.de/de/00172`. Ohne Ergänzung des Schemas erkennt
/// [Uri.tryParse] darin keinen Host, und die Karte bliebe unerkannt.
Uri? _asUri(String value) {
  if (value.isEmpty) return null;

  final direct = Uri.tryParse(value);
  if (direct != null && direct.hasScheme && direct.host.isNotEmpty) {
    return direct;
  }

  // Nur ergänzen, wenn es überhaupt nach einer Adresse aussieht: ein
  // Punkt im ersten Abschnitt, kein Leerzeichen.
  if (value.contains(' ')) return null;
  final firstSegment = value.split('/').first;
  if (!firstSegment.contains('.')) return null;

  final prefixed = Uri.tryParse('https://$value');
  return prefixed != null && prefixed.host.isNotEmpty ? prefixed : null;
}

/// Anbieter, deren Adressen unmittelbar einen Titel bezeichnen.
const _trackHosts = [
  'spotify.com',
  'tidal.com',
  'music.apple.com',
  'youtube.com',
  'youtu.be',
];

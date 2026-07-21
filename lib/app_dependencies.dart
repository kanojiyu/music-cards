/// Die Dienste, die die Bildschirme brauchen, an einer Stelle gebündelt.
///
/// Wird von `main` erzeugt und nach unten gereicht. Explizit statt global,
/// damit Tests eine Ablage im Speicher und einen stummen Anbieter einsetzen
/// können.
library;

import 'data/database.dart';
import 'data/playlist_repository.dart';
import 'data/playlist_store.dart';
import 'scan/card_mapping_store.dart';
import 'scan/card_set_store.dart';
import 'settings/app_settings.dart';


class AppDependencies {
  AppDependencies({
    required this.playlists,
    required this.cardMappings,
    required this.cardSets,
    required this.settings,
    this.database,
  });

  /// Die übliche Zusammenstellung: alles hängt an der SQLite-Datenbank.
  /// Die übliche Zusammenstellung fürs Kartenspiel.
  ///
  /// Ohne Anbieter und ohne Jahres-Auflösung: Damit ist ausgeschlossen, dass
  /// die App andere Dienste kontaktiert als YouTube für die Videos und die
  /// Quelle der Kartenlisten.
  factory AppDependencies.persistent({
    required AppDatabase database,
  }) {
    return AppDependencies(
      database: database,
      playlists: PlaylistRepository(database),
      cardMappings: DriftCardMappingStore(database),
      cardSets: DriftCardSetStore(database),
      settings: DriftSettingsStore(database),
    );
  }

  final PlaylistStore playlists;

  /// Zuordnung gedruckter Karten zu Songs.
  final CardMappingStore cardMappings;

  /// Die eingerichteten Kartenausgaben.
  final CardSetStore cardSets;

  final SettingsStore settings;


  /// Nur gesetzt, wenn dauerhaft gespeichert wird.
  final AppDatabase? database;


  Future<void> dispose() async => database?.close();
}

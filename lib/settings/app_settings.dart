/// Einstellungen der App.
library;

import '../data/database.dart';

/// Wodurch die Wiedergabe ausgelöst wird.
enum PlaybackTrigger {
  /// Sobald der Sensor meldet, dass das Gerät umgedreht liegt.
  ///
  /// Zuverlässig, solange das Gerät flach genug zu liegen kommt — bei dicker
  /// Hülle oder weicher Unterlage nicht immer der Fall.
  flip,

  /// Nach einer festen Wartezeit, unabhängig von der Lage.
  ///
  /// Der Ausweg, wenn die Lageerkennung am eigenen Gerät nicht greift.
  delay,
}

class AppSettings {
  const AppSettings({
    this.trigger = PlaybackTrigger.flip,
    this.delay = const Duration(seconds: 5),
    this.activeCardSetId,
  });

  final PlaybackTrigger trigger;

  /// Wartezeit bei [PlaybackTrigger.delay].
  final Duration delay;

  /// Die Ausgabe, mit der gespielt wird. `null`, solange keine gewählt ist.
  final String? activeCardSetId;

  AppSettings copyWith({
    PlaybackTrigger? trigger,
    Duration? delay,
    String? activeCardSetId,
  }) {
    return AppSettings(
      trigger: trigger ?? this.trigger,
      delay: delay ?? this.delay,
      activeCardSetId: activeCardSetId ?? this.activeCardSetId,
    );
  }
}

/// Liest und schreibt die Einstellungen.
abstract interface class SettingsStore {
  Future<AppSettings> read();
  Future<void> write(AppSettings settings);
}

class DriftSettingsStore implements SettingsStore {
  DriftSettingsStore(this._db);

  static const _trigger = 'playback_trigger';
  static const _delay = 'playback_delay_seconds';
  static const _cardSet = 'active_card_set';

  final AppDatabase _db;

  @override
  Future<AppSettings> read() async {
    final rows = await _db.select(_db.settingRows).get();
    final values = {for (final row in rows) row.key: row.value};

    return AppSettings(
      trigger: values[_trigger] == PlaybackTrigger.delay.name
          ? PlaybackTrigger.delay
          : PlaybackTrigger.flip,
      delay: Duration(seconds: int.tryParse(values[_delay] ?? '') ?? 5),
      // Leer bedeutet „keine gewählt“ — die Tabelle führt nur Zeichenketten.
      activeCardSetId:
          (values[_cardSet]?.isEmpty ?? true) ? null : values[_cardSet],
    );
  }

  @override
  Future<void> write(AppSettings settings) async {
    Future<void> put(String key, String value) {
      return _db.into(_db.settingRows).insertOnConflictUpdate(
            SettingRowsCompanion.insert(key: key, value: value),
          );
    }

    await _db.transaction(() async {
      await put(_trigger, settings.trigger.name);
      await put(_delay, '${settings.delay.inSeconds}');
      // Ein leerer Wert steht für „keine Ausgabe gewählt“; die Tabelle führt
      // nur Zeichenketten.
      await put(_cardSet, settings.activeCardSetId ?? '');
    });
  }
}

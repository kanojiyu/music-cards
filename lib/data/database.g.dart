// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SongRowsTable extends SongRows with TableInfo<$SongRowsTable, SongRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearSourceMeta = const VerificationMeta(
    'yearSource',
  );
  @override
  late final GeneratedColumn<int> yearSource = GeneratedColumn<int>(
    'year_source',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdsMeta = const VerificationMeta(
    'providerIds',
  );
  @override
  late final GeneratedColumn<String> providerIds = GeneratedColumn<String>(
    'provider_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artist,
    year,
    yearSource,
    providerIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('year_source')) {
      context.handle(
        _yearSourceMeta,
        yearSource.isAcceptableOrUnknown(data['year_source']!, _yearSourceMeta),
      );
    } else if (isInserting) {
      context.missing(_yearSourceMeta);
    }
    if (data.containsKey('provider_ids')) {
      context.handle(
        _providerIdsMeta,
        providerIds.isAcceptableOrUnknown(
          data['provider_ids']!,
          _providerIdsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      yearSource: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_source'],
      )!,
      providerIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_ids'],
      )!,
    );
  }

  @override
  $SongRowsTable createAlias(String alias) {
    return $SongRowsTable(attachedDatabase, alias);
  }
}

class SongRow extends DataClass implements Insertable<SongRow> {
  final String id;
  final String title;
  final String artist;
  final int year;

  /// Index in [YearSource] — hält fest, wie belastbar das Jahr ist.
  final int yearSource;

  /// Anbieter-IDs als JSON-Objekt, Schlüssel ist der Name aus [MusicService].
  final String providerIds;
  const SongRow({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.yearSource,
    required this.providerIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['year'] = Variable<int>(year);
    map['year_source'] = Variable<int>(yearSource);
    map['provider_ids'] = Variable<String>(providerIds);
    return map;
  }

  SongRowsCompanion toCompanion(bool nullToAbsent) {
    return SongRowsCompanion(
      id: Value(id),
      title: Value(title),
      artist: Value(artist),
      year: Value(year),
      yearSource: Value(yearSource),
      providerIds: Value(providerIds),
    );
  }

  factory SongRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      year: serializer.fromJson<int>(json['year']),
      yearSource: serializer.fromJson<int>(json['yearSource']),
      providerIds: serializer.fromJson<String>(json['providerIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'year': serializer.toJson<int>(year),
      'yearSource': serializer.toJson<int>(yearSource),
      'providerIds': serializer.toJson<String>(providerIds),
    };
  }

  SongRow copyWith({
    String? id,
    String? title,
    String? artist,
    int? year,
    int? yearSource,
    String? providerIds,
  }) => SongRow(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    year: year ?? this.year,
    yearSource: yearSource ?? this.yearSource,
    providerIds: providerIds ?? this.providerIds,
  );
  SongRow copyWithCompanion(SongRowsCompanion data) {
    return SongRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      year: data.year.present ? data.year.value : this.year,
      yearSource: data.yearSource.present
          ? data.yearSource.value
          : this.yearSource,
      providerIds: data.providerIds.present
          ? data.providerIds.value
          : this.providerIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('year: $year, ')
          ..write('yearSource: $yearSource, ')
          ..write('providerIds: $providerIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, artist, year, yearSource, providerIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.year == this.year &&
          other.yearSource == this.yearSource &&
          other.providerIds == this.providerIds);
}

class SongRowsCompanion extends UpdateCompanion<SongRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<int> year;
  final Value<int> yearSource;
  final Value<String> providerIds;
  final Value<int> rowid;
  const SongRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.year = const Value.absent(),
    this.yearSource = const Value.absent(),
    this.providerIds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongRowsCompanion.insert({
    required String id,
    required String title,
    required String artist,
    required int year,
    required int yearSource,
    this.providerIds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       artist = Value(artist),
       year = Value(year),
       yearSource = Value(yearSource);
  static Insertable<SongRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<int>? year,
    Expression<int>? yearSource,
    Expression<String>? providerIds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (year != null) 'year': year,
      if (yearSource != null) 'year_source': yearSource,
      if (providerIds != null) 'provider_ids': providerIds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? artist,
    Value<int>? year,
    Value<int>? yearSource,
    Value<String>? providerIds,
    Value<int>? rowid,
  }) {
    return SongRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      year: year ?? this.year,
      yearSource: yearSource ?? this.yearSource,
      providerIds: providerIds ?? this.providerIds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (yearSource.present) {
      map['year_source'] = Variable<int>(yearSource.value);
    }
    if (providerIds.present) {
      map['provider_ids'] = Variable<String>(providerIds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('year: $year, ')
          ..write('yearSource: $yearSource, ')
          ..write('providerIds: $providerIds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistRowsTable extends PlaylistRows
    with TableInfo<$PlaylistRowsTable, PlaylistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlaylistRowsTable createAlias(String alias) {
    return $PlaylistRowsTable(attachedDatabase, alias);
  }
}

class PlaylistRow extends DataClass implements Insertable<PlaylistRow> {
  final String id;
  final String name;
  final DateTime createdAt;
  const PlaylistRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlaylistRowsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistRowsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PlaylistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlaylistRow copyWith({String? id, String? name, DateTime? createdAt}) =>
      PlaylistRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  PlaylistRow copyWithCompanion(PlaylistRowsCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlaylistRowsCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlaylistRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistRowsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlaylistRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlaylistRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongRowsTable extends PlaylistSongRows
    with TableInfo<$PlaylistSongRowsTable, PlaylistSongRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlist_rows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES song_rows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playlistId, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_song_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistSongRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, songId};
  @override
  PlaylistSongRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSongRow(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistSongRowsTable createAlias(String alias) {
    return $PlaylistSongRowsTable(attachedDatabase, alias);
  }
}

class PlaylistSongRow extends DataClass implements Insertable<PlaylistSongRow> {
  final String playlistId;
  final String songId;
  final int position;
  const PlaylistSongRow({
    required this.playlistId,
    required this.songId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['song_id'] = Variable<String>(songId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistSongRowsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongRowsCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      position: Value(position),
    );
  }

  factory PlaylistSongRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSongRow(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistSongRow copyWith({
    String? playlistId,
    String? songId,
    int? position,
  }) => PlaylistSongRow(
    playlistId: playlistId ?? this.playlistId,
    songId: songId ?? this.songId,
    position: position ?? this.position,
  );
  PlaylistSongRow copyWithCompanion(PlaylistSongRowsCompanion data) {
    return PlaylistSongRow(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongRow(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSongRow &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.position == this.position);
}

class PlaylistSongRowsCompanion extends UpdateCompanion<PlaylistSongRow> {
  final Value<String> playlistId;
  final Value<String> songId;
  final Value<int> position;
  final Value<int> rowid;
  const PlaylistSongRowsCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongRowsCompanion.insert({
    required String playlistId,
    required String songId,
    required int position,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       songId = Value(songId),
       position = Value(position);
  static Insertable<PlaylistSongRow> custom({
    Expression<String>? playlistId,
    Expression<String>? songId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongRowsCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? songId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return PlaylistSongRowsCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongRowsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $YearCacheRowsTable extends YearCacheRows
    with TableInfo<$YearCacheRowsTable, YearCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YearCacheRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _musicbrainzIdMeta = const VerificationMeta(
    'musicbrainzId',
  );
  @override
  late final GeneratedColumn<String> musicbrainzId = GeneratedColumn<String>(
    'musicbrainz_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    year,
    source,
    confidence,
    musicbrainzId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'year_cache_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<YearCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('musicbrainz_id')) {
      context.handle(
        _musicbrainzIdMeta,
        musicbrainzId.isAcceptableOrUnknown(
          data['musicbrainz_id']!,
          _musicbrainzIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  YearCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YearCacheRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      musicbrainzId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}musicbrainz_id'],
      ),
    );
  }

  @override
  $YearCacheRowsTable createAlias(String alias) {
    return $YearCacheRowsTable(attachedDatabase, alias);
  }
}

class YearCacheRow extends DataClass implements Insertable<YearCacheRow> {
  final String key;
  final int? year;
  final int source;
  final double confidence;
  final String? musicbrainzId;
  const YearCacheRow({
    required this.key,
    this.year,
    required this.source,
    required this.confidence,
    this.musicbrainzId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['source'] = Variable<int>(source);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || musicbrainzId != null) {
      map['musicbrainz_id'] = Variable<String>(musicbrainzId);
    }
    return map;
  }

  YearCacheRowsCompanion toCompanion(bool nullToAbsent) {
    return YearCacheRowsCompanion(
      key: Value(key),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      source: Value(source),
      confidence: Value(confidence),
      musicbrainzId: musicbrainzId == null && nullToAbsent
          ? const Value.absent()
          : Value(musicbrainzId),
    );
  }

  factory YearCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YearCacheRow(
      key: serializer.fromJson<String>(json['key']),
      year: serializer.fromJson<int?>(json['year']),
      source: serializer.fromJson<int>(json['source']),
      confidence: serializer.fromJson<double>(json['confidence']),
      musicbrainzId: serializer.fromJson<String?>(json['musicbrainzId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'year': serializer.toJson<int?>(year),
      'source': serializer.toJson<int>(source),
      'confidence': serializer.toJson<double>(confidence),
      'musicbrainzId': serializer.toJson<String?>(musicbrainzId),
    };
  }

  YearCacheRow copyWith({
    String? key,
    Value<int?> year = const Value.absent(),
    int? source,
    double? confidence,
    Value<String?> musicbrainzId = const Value.absent(),
  }) => YearCacheRow(
    key: key ?? this.key,
    year: year.present ? year.value : this.year,
    source: source ?? this.source,
    confidence: confidence ?? this.confidence,
    musicbrainzId: musicbrainzId.present
        ? musicbrainzId.value
        : this.musicbrainzId,
  );
  YearCacheRow copyWithCompanion(YearCacheRowsCompanion data) {
    return YearCacheRow(
      key: data.key.present ? data.key.value : this.key,
      year: data.year.present ? data.year.value : this.year,
      source: data.source.present ? data.source.value : this.source,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      musicbrainzId: data.musicbrainzId.present
          ? data.musicbrainzId.value
          : this.musicbrainzId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YearCacheRow(')
          ..write('key: $key, ')
          ..write('year: $year, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('musicbrainzId: $musicbrainzId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, year, source, confidence, musicbrainzId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YearCacheRow &&
          other.key == this.key &&
          other.year == this.year &&
          other.source == this.source &&
          other.confidence == this.confidence &&
          other.musicbrainzId == this.musicbrainzId);
}

class YearCacheRowsCompanion extends UpdateCompanion<YearCacheRow> {
  final Value<String> key;
  final Value<int?> year;
  final Value<int> source;
  final Value<double> confidence;
  final Value<String?> musicbrainzId;
  final Value<int> rowid;
  const YearCacheRowsCompanion({
    this.key = const Value.absent(),
    this.year = const Value.absent(),
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    this.musicbrainzId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  YearCacheRowsCompanion.insert({
    required String key,
    this.year = const Value.absent(),
    required int source,
    required double confidence,
    this.musicbrainzId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       source = Value(source),
       confidence = Value(confidence);
  static Insertable<YearCacheRow> custom({
    Expression<String>? key,
    Expression<int>? year,
    Expression<int>? source,
    Expression<double>? confidence,
    Expression<String>? musicbrainzId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (year != null) 'year': year,
      if (source != null) 'source': source,
      if (confidence != null) 'confidence': confidence,
      if (musicbrainzId != null) 'musicbrainz_id': musicbrainzId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  YearCacheRowsCompanion copyWith({
    Value<String>? key,
    Value<int?>? year,
    Value<int>? source,
    Value<double>? confidence,
    Value<String?>? musicbrainzId,
    Value<int>? rowid,
  }) {
    return YearCacheRowsCompanion(
      key: key ?? this.key,
      year: year ?? this.year,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      musicbrainzId: musicbrainzId ?? this.musicbrainzId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (musicbrainzId.present) {
      map['musicbrainz_id'] = Variable<String>(musicbrainzId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YearCacheRowsCompanion(')
          ..write('key: $key, ')
          ..write('year: $year, ')
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('musicbrainzId: $musicbrainzId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardMappingRowsTable extends CardMappingRows
    with TableInfo<$CardMappingRowsTable, CardMappingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardMappingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardKeyMeta = const VerificationMeta(
    'cardKey',
  );
  @override
  late final GeneratedColumn<String> cardKey = GeneratedColumn<String>(
    'card_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES song_rows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardKey, songId, raw, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_mapping_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardMappingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_key')) {
      context.handle(
        _cardKeyMeta,
        cardKey.isAcceptableOrUnknown(data['card_key']!, _cardKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cardKeyMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardKey};
  @override
  CardMappingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardMappingRow(
      cardKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_key'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardMappingRowsTable createAlias(String alias) {
    return $CardMappingRowsTable(attachedDatabase, alias);
  }
}

class CardMappingRow extends DataClass implements Insertable<CardMappingRow> {
  /// Sprache, Ausgabe und Nummer, wie in `PrintedCard.mappingKey` gebildet.
  final String cardKey;
  final String songId;

  /// Der rohe Code des Scans — hilft, wenn sich das Kartenformat ändert.
  final String raw;
  final DateTime createdAt;
  const CardMappingRow({
    required this.cardKey,
    required this.songId,
    required this.raw,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_key'] = Variable<String>(cardKey);
    map['song_id'] = Variable<String>(songId);
    map['raw'] = Variable<String>(raw);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardMappingRowsCompanion toCompanion(bool nullToAbsent) {
    return CardMappingRowsCompanion(
      cardKey: Value(cardKey),
      songId: Value(songId),
      raw: Value(raw),
      createdAt: Value(createdAt),
    );
  }

  factory CardMappingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardMappingRow(
      cardKey: serializer.fromJson<String>(json['cardKey']),
      songId: serializer.fromJson<String>(json['songId']),
      raw: serializer.fromJson<String>(json['raw']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardKey': serializer.toJson<String>(cardKey),
      'songId': serializer.toJson<String>(songId),
      'raw': serializer.toJson<String>(raw),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardMappingRow copyWith({
    String? cardKey,
    String? songId,
    String? raw,
    DateTime? createdAt,
  }) => CardMappingRow(
    cardKey: cardKey ?? this.cardKey,
    songId: songId ?? this.songId,
    raw: raw ?? this.raw,
    createdAt: createdAt ?? this.createdAt,
  );
  CardMappingRow copyWithCompanion(CardMappingRowsCompanion data) {
    return CardMappingRow(
      cardKey: data.cardKey.present ? data.cardKey.value : this.cardKey,
      songId: data.songId.present ? data.songId.value : this.songId,
      raw: data.raw.present ? data.raw.value : this.raw,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardMappingRow(')
          ..write('cardKey: $cardKey, ')
          ..write('songId: $songId, ')
          ..write('raw: $raw, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardKey, songId, raw, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardMappingRow &&
          other.cardKey == this.cardKey &&
          other.songId == this.songId &&
          other.raw == this.raw &&
          other.createdAt == this.createdAt);
}

class CardMappingRowsCompanion extends UpdateCompanion<CardMappingRow> {
  final Value<String> cardKey;
  final Value<String> songId;
  final Value<String> raw;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CardMappingRowsCompanion({
    this.cardKey = const Value.absent(),
    this.songId = const Value.absent(),
    this.raw = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardMappingRowsCompanion.insert({
    required String cardKey,
    required String songId,
    this.raw = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : cardKey = Value(cardKey),
       songId = Value(songId),
       createdAt = Value(createdAt);
  static Insertable<CardMappingRow> custom({
    Expression<String>? cardKey,
    Expression<String>? songId,
    Expression<String>? raw,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardKey != null) 'card_key': cardKey,
      if (songId != null) 'song_id': songId,
      if (raw != null) 'raw': raw,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardMappingRowsCompanion copyWith({
    Value<String>? cardKey,
    Value<String>? songId,
    Value<String>? raw,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CardMappingRowsCompanion(
      cardKey: cardKey ?? this.cardKey,
      songId: songId ?? this.songId,
      raw: raw ?? this.raw,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardKey.present) {
      map['card_key'] = Variable<String>(cardKey.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardMappingRowsCompanion(')
          ..write('cardKey: $cardKey, ')
          ..write('songId: $songId, ')
          ..write('raw: $raw, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardSetRowsTable extends CardSetRows
    with TableInfo<$CardSetRowsTable, CardSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardSetRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardCountMeta = const VerificationMeta(
    'cardCount',
  );
  @override
  late final GeneratedColumn<int> cardCount = GeneratedColumn<int>(
    'card_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    language,
    sku,
    sourceUrl,
    cardCount,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_set_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('card_count')) {
      context.handle(
        _cardCountMeta,
        cardCount.isAcceptableOrUnknown(data['card_count']!, _cardCountMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardSetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      cardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_count'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      ),
    );
  }

  @override
  $CardSetRowsTable createAlias(String alias) {
    return $CardSetRowsTable(attachedDatabase, alias);
  }
}

class CardSetRow extends DataClass implements Insertable<CardSetRow> {
  final String id;
  final String name;
  final String language;
  final String? sku;

  /// Woher die Liste stammt. Leer bei selbst eingefügten Daten.
  final String? sourceUrl;
  final int cardCount;
  final DateTime? importedAt;
  const CardSetRow({
    required this.id,
    required this.name,
    required this.language,
    this.sku,
    this.sourceUrl,
    required this.cardCount,
    this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['card_count'] = Variable<int>(cardCount);
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<DateTime>(importedAt);
    }
    return map;
  }

  CardSetRowsCompanion toCompanion(bool nullToAbsent) {
    return CardSetRowsCompanion(
      id: Value(id),
      name: Value(name),
      language: Value(language),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      cardCount: Value(cardCount),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
    );
  }

  factory CardSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardSetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      language: serializer.fromJson<String>(json['language']),
      sku: serializer.fromJson<String?>(json['sku']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      cardCount: serializer.fromJson<int>(json['cardCount']),
      importedAt: serializer.fromJson<DateTime?>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'language': serializer.toJson<String>(language),
      'sku': serializer.toJson<String?>(sku),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'cardCount': serializer.toJson<int>(cardCount),
      'importedAt': serializer.toJson<DateTime?>(importedAt),
    };
  }

  CardSetRow copyWith({
    String? id,
    String? name,
    String? language,
    Value<String?> sku = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    int? cardCount,
    Value<DateTime?> importedAt = const Value.absent(),
  }) => CardSetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    language: language ?? this.language,
    sku: sku.present ? sku.value : this.sku,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    cardCount: cardCount ?? this.cardCount,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
  );
  CardSetRow copyWithCompanion(CardSetRowsCompanion data) {
    return CardSetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      language: data.language.present ? data.language.value : this.language,
      sku: data.sku.present ? data.sku.value : this.sku,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      cardCount: data.cardCount.present ? data.cardCount.value : this.cardCount,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardSetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('sku: $sku, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('cardCount: $cardCount, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, language, sku, sourceUrl, cardCount, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardSetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.language == this.language &&
          other.sku == this.sku &&
          other.sourceUrl == this.sourceUrl &&
          other.cardCount == this.cardCount &&
          other.importedAt == this.importedAt);
}

class CardSetRowsCompanion extends UpdateCompanion<CardSetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> language;
  final Value<String?> sku;
  final Value<String?> sourceUrl;
  final Value<int> cardCount;
  final Value<DateTime?> importedAt;
  final Value<int> rowid;
  const CardSetRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.language = const Value.absent(),
    this.sku = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardSetRowsCompanion.insert({
    required String id,
    required String name,
    required String language,
    this.sku = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       language = Value(language);
  static Insertable<CardSetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? language,
    Expression<String>? sku,
    Expression<String>? sourceUrl,
    Expression<int>? cardCount,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (sku != null) 'sku': sku,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (cardCount != null) 'card_count': cardCount,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardSetRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? language,
    Value<String?>? sku,
    Value<String?>? sourceUrl,
    Value<int>? cardCount,
    Value<DateTime?>? importedAt,
    Value<int>? rowid,
  }) {
    return CardSetRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      sku: sku ?? this.sku,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      cardCount: cardCount ?? this.cardCount,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (cardCount.present) {
      map['card_count'] = Variable<int>(cardCount.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardSetRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('sku: $sku, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('cardCount: $cardCount, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingRowsTable extends SettingRows
    with TableInfo<$SettingRowsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingRowsTable createAlias(String alias) {
    return $SettingRowsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingRowsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingRowsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingRowsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongRowsTable songRows = $SongRowsTable(this);
  late final $PlaylistRowsTable playlistRows = $PlaylistRowsTable(this);
  late final $PlaylistSongRowsTable playlistSongRows = $PlaylistSongRowsTable(
    this,
  );
  late final $YearCacheRowsTable yearCacheRows = $YearCacheRowsTable(this);
  late final $CardMappingRowsTable cardMappingRows = $CardMappingRowsTable(
    this,
  );
  late final $CardSetRowsTable cardSetRows = $CardSetRowsTable(this);
  late final $SettingRowsTable settingRows = $SettingRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songRows,
    playlistRows,
    playlistSongRows,
    yearCacheRows,
    cardMappingRows,
    cardSetRows,
    settingRows,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlist_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_song_rows', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'song_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_song_rows', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'song_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_mapping_rows', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SongRowsTableCreateCompanionBuilder =
    SongRowsCompanion Function({
      required String id,
      required String title,
      required String artist,
      required int year,
      required int yearSource,
      Value<String> providerIds,
      Value<int> rowid,
    });
typedef $$SongRowsTableUpdateCompanionBuilder =
    SongRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> artist,
      Value<int> year,
      Value<int> yearSource,
      Value<String> providerIds,
      Value<int> rowid,
    });

final class $$SongRowsTableReferences
    extends BaseReferences<_$AppDatabase, $SongRowsTable, SongRow> {
  $$SongRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistSongRowsTable, List<PlaylistSongRow>>
  _playlistSongRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistSongRows,
    aliasName: 'song_rows__id__playlist_song_rows__song_id',
  );

  $$PlaylistSongRowsTableProcessedTableManager get playlistSongRowsRefs {
    final manager = $$PlaylistSongRowsTableTableManager(
      $_db,
      $_db.playlistSongRows,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistSongRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardMappingRowsTable, List<CardMappingRow>>
  _cardMappingRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardMappingRows,
    aliasName: 'song_rows__id__card_mapping_rows__song_id',
  );

  $$CardMappingRowsTableProcessedTableManager get cardMappingRowsRefs {
    final manager = $$CardMappingRowsTableTableManager(
      $_db,
      $_db.cardMappingRows,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cardMappingRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SongRowsTable> {
  $$SongRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearSource => $composableBuilder(
    column: $table.yearSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerIds => $composableBuilder(
    column: $table.providerIds,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSongRowsRefs(
    Expression<bool> Function($$PlaylistSongRowsTableFilterComposer f) f,
  ) {
    final $$PlaylistSongRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongRows,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongRowsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardMappingRowsRefs(
    Expression<bool> Function($$CardMappingRowsTableFilterComposer f) f,
  ) {
    final $$CardMappingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardMappingRows,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardMappingRowsTableFilterComposer(
            $db: $db,
            $table: $db.cardMappingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongRowsTable> {
  $$SongRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearSource => $composableBuilder(
    column: $table.yearSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerIds => $composableBuilder(
    column: $table.providerIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongRowsTable> {
  $$SongRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get yearSource => $composableBuilder(
    column: $table.yearSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerIds => $composableBuilder(
    column: $table.providerIds,
    builder: (column) => column,
  );

  Expression<T> playlistSongRowsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongRowsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongRows,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistSongRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardMappingRowsRefs<T extends Object>(
    Expression<T> Function($$CardMappingRowsTableAnnotationComposer a) f,
  ) {
    final $$CardMappingRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardMappingRows,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardMappingRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardMappingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongRowsTable,
          SongRow,
          $$SongRowsTableFilterComposer,
          $$SongRowsTableOrderingComposer,
          $$SongRowsTableAnnotationComposer,
          $$SongRowsTableCreateCompanionBuilder,
          $$SongRowsTableUpdateCompanionBuilder,
          (SongRow, $$SongRowsTableReferences),
          SongRow,
          PrefetchHooks Function({
            bool playlistSongRowsRefs,
            bool cardMappingRowsRefs,
          })
        > {
  $$SongRowsTableTableManager(_$AppDatabase db, $SongRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> yearSource = const Value.absent(),
                Value<String> providerIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongRowsCompanion(
                id: id,
                title: title,
                artist: artist,
                year: year,
                yearSource: yearSource,
                providerIds: providerIds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String artist,
                required int year,
                required int yearSource,
                Value<String> providerIds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongRowsCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                year: year,
                yearSource: yearSource,
                providerIds: providerIds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SongRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({playlistSongRowsRefs = false, cardMappingRowsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playlistSongRowsRefs) db.playlistSongRows,
                    if (cardMappingRowsRefs) db.cardMappingRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playlistSongRowsRefs)
                        await $_getPrefetchedData<
                          SongRow,
                          $SongRowsTable,
                          PlaylistSongRow
                        >(
                          currentTable: table,
                          referencedTable: $$SongRowsTableReferences
                              ._playlistSongRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistSongRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardMappingRowsRefs)
                        await $_getPrefetchedData<
                          SongRow,
                          $SongRowsTable,
                          CardMappingRow
                        >(
                          currentTable: table,
                          referencedTable: $$SongRowsTableReferences
                              ._cardMappingRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardMappingRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SongRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongRowsTable,
      SongRow,
      $$SongRowsTableFilterComposer,
      $$SongRowsTableOrderingComposer,
      $$SongRowsTableAnnotationComposer,
      $$SongRowsTableCreateCompanionBuilder,
      $$SongRowsTableUpdateCompanionBuilder,
      (SongRow, $$SongRowsTableReferences),
      SongRow,
      PrefetchHooks Function({
        bool playlistSongRowsRefs,
        bool cardMappingRowsRefs,
      })
    >;
typedef $$PlaylistRowsTableCreateCompanionBuilder =
    PlaylistRowsCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlaylistRowsTableUpdateCompanionBuilder =
    PlaylistRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PlaylistRowsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistRowsTable, PlaylistRow> {
  $$PlaylistRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistSongRowsTable, List<PlaylistSongRow>>
  _playlistSongRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistSongRows,
    aliasName: 'playlist_rows__id__playlist_song_rows__playlist_id',
  );

  $$PlaylistSongRowsTableProcessedTableManager get playlistSongRowsRefs {
    final manager = $$PlaylistSongRowsTableTableManager(
      $_db,
      $_db.playlistSongRows,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playlistSongRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistRowsTable> {
  $$PlaylistRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistSongRowsRefs(
    Expression<bool> Function($$PlaylistSongRowsTableFilterComposer f) f,
  ) {
    final $$PlaylistSongRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongRows,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongRowsTableFilterComposer(
            $db: $db,
            $table: $db.playlistSongRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistRowsTable> {
  $$PlaylistRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistRowsTable> {
  $$PlaylistRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> playlistSongRowsRefs<T extends Object>(
    Expression<T> Function($$PlaylistSongRowsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistSongRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistSongRows,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistSongRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistSongRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistRowsTable,
          PlaylistRow,
          $$PlaylistRowsTableFilterComposer,
          $$PlaylistRowsTableOrderingComposer,
          $$PlaylistRowsTableAnnotationComposer,
          $$PlaylistRowsTableCreateCompanionBuilder,
          $$PlaylistRowsTableUpdateCompanionBuilder,
          (PlaylistRow, $$PlaylistRowsTableReferences),
          PlaylistRow,
          PrefetchHooks Function({bool playlistSongRowsRefs})
        > {
  $$PlaylistRowsTableTableManager(_$AppDatabase db, $PlaylistRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistRowsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistRowsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistSongRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistSongRowsRefs) db.playlistSongRows,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistSongRowsRefs)
                    await $_getPrefetchedData<
                      PlaylistRow,
                      $PlaylistRowsTable,
                      PlaylistSongRow
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistRowsTableReferences
                          ._playlistSongRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistSongRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistRowsTable,
      PlaylistRow,
      $$PlaylistRowsTableFilterComposer,
      $$PlaylistRowsTableOrderingComposer,
      $$PlaylistRowsTableAnnotationComposer,
      $$PlaylistRowsTableCreateCompanionBuilder,
      $$PlaylistRowsTableUpdateCompanionBuilder,
      (PlaylistRow, $$PlaylistRowsTableReferences),
      PlaylistRow,
      PrefetchHooks Function({bool playlistSongRowsRefs})
    >;
typedef $$PlaylistSongRowsTableCreateCompanionBuilder =
    PlaylistSongRowsCompanion Function({
      required String playlistId,
      required String songId,
      required int position,
      Value<int> rowid,
    });
typedef $$PlaylistSongRowsTableUpdateCompanionBuilder =
    PlaylistSongRowsCompanion Function({
      Value<String> playlistId,
      Value<String> songId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$PlaylistSongRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlaylistSongRowsTable, PlaylistSongRow> {
  $$PlaylistSongRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistRowsTable _playlistIdTable(_$AppDatabase db) => db
      .playlistRows
      .createAlias('playlist_song_rows__playlist_id__playlist_rows__id');

  $$PlaylistRowsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistRowsTableTableManager(
      $_db,
      $_db.playlistRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SongRowsTable _songIdTable(_$AppDatabase db) =>
      db.songRows.createAlias('playlist_song_rows__song_id__song_rows__id');

  $$SongRowsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongRowsTableTableManager(
      $_db,
      $_db.songRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistSongRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongRowsTable> {
  $$PlaylistSongRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistRowsTableFilterComposer get playlistId {
    final $$PlaylistRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistRowsTableFilterComposer(
            $db: $db,
            $table: $db.playlistRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongRowsTableFilterComposer get songId {
    final $$SongRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongRowsTableFilterComposer(
            $db: $db,
            $table: $db.songRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongRowsTable> {
  $$PlaylistSongRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistRowsTableOrderingComposer get playlistId {
    final $$PlaylistRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistRowsTableOrderingComposer(
            $db: $db,
            $table: $db.playlistRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongRowsTableOrderingComposer get songId {
    final $$SongRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongRowsTableOrderingComposer(
            $db: $db,
            $table: $db.songRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongRowsTable> {
  $$PlaylistSongRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistRowsTableAnnotationComposer get playlistId {
    final $$PlaylistRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlistRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SongRowsTableAnnotationComposer get songId {
    final $$SongRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.songRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistSongRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistSongRowsTable,
          PlaylistSongRow,
          $$PlaylistSongRowsTableFilterComposer,
          $$PlaylistSongRowsTableOrderingComposer,
          $$PlaylistSongRowsTableAnnotationComposer,
          $$PlaylistSongRowsTableCreateCompanionBuilder,
          $$PlaylistSongRowsTableUpdateCompanionBuilder,
          (PlaylistSongRow, $$PlaylistSongRowsTableReferences),
          PlaylistSongRow,
          PrefetchHooks Function({bool playlistId, bool songId})
        > {
  $$PlaylistSongRowsTableTableManager(
    _$AppDatabase db,
    $PlaylistSongRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongRowsCompanion(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String songId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => PlaylistSongRowsCompanion.insert(
                playlistId: playlistId,
                songId: songId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistSongRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$PlaylistSongRowsTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$PlaylistSongRowsTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable:
                                    $$PlaylistSongRowsTableReferences
                                        ._songIdTable(db),
                                referencedColumn:
                                    $$PlaylistSongRowsTableReferences
                                        ._songIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistSongRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistSongRowsTable,
      PlaylistSongRow,
      $$PlaylistSongRowsTableFilterComposer,
      $$PlaylistSongRowsTableOrderingComposer,
      $$PlaylistSongRowsTableAnnotationComposer,
      $$PlaylistSongRowsTableCreateCompanionBuilder,
      $$PlaylistSongRowsTableUpdateCompanionBuilder,
      (PlaylistSongRow, $$PlaylistSongRowsTableReferences),
      PlaylistSongRow,
      PrefetchHooks Function({bool playlistId, bool songId})
    >;
typedef $$YearCacheRowsTableCreateCompanionBuilder =
    YearCacheRowsCompanion Function({
      required String key,
      Value<int?> year,
      required int source,
      required double confidence,
      Value<String?> musicbrainzId,
      Value<int> rowid,
    });
typedef $$YearCacheRowsTableUpdateCompanionBuilder =
    YearCacheRowsCompanion Function({
      Value<String> key,
      Value<int?> year,
      Value<int> source,
      Value<double> confidence,
      Value<String?> musicbrainzId,
      Value<int> rowid,
    });

class $$YearCacheRowsTableFilterComposer
    extends Composer<_$AppDatabase, $YearCacheRowsTable> {
  $$YearCacheRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get musicbrainzId => $composableBuilder(
    column: $table.musicbrainzId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YearCacheRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $YearCacheRowsTable> {
  $$YearCacheRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musicbrainzId => $composableBuilder(
    column: $table.musicbrainzId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YearCacheRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $YearCacheRowsTable> {
  $$YearCacheRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get musicbrainzId => $composableBuilder(
    column: $table.musicbrainzId,
    builder: (column) => column,
  );
}

class $$YearCacheRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YearCacheRowsTable,
          YearCacheRow,
          $$YearCacheRowsTableFilterComposer,
          $$YearCacheRowsTableOrderingComposer,
          $$YearCacheRowsTableAnnotationComposer,
          $$YearCacheRowsTableCreateCompanionBuilder,
          $$YearCacheRowsTableUpdateCompanionBuilder,
          (
            YearCacheRow,
            BaseReferences<_$AppDatabase, $YearCacheRowsTable, YearCacheRow>,
          ),
          YearCacheRow,
          PrefetchHooks Function()
        > {
  $$YearCacheRowsTableTableManager(_$AppDatabase db, $YearCacheRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YearCacheRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YearCacheRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YearCacheRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int> source = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String?> musicbrainzId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YearCacheRowsCompanion(
                key: key,
                year: year,
                source: source,
                confidence: confidence,
                musicbrainzId: musicbrainzId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<int?> year = const Value.absent(),
                required int source,
                required double confidence,
                Value<String?> musicbrainzId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YearCacheRowsCompanion.insert(
                key: key,
                year: year,
                source: source,
                confidence: confidence,
                musicbrainzId: musicbrainzId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YearCacheRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YearCacheRowsTable,
      YearCacheRow,
      $$YearCacheRowsTableFilterComposer,
      $$YearCacheRowsTableOrderingComposer,
      $$YearCacheRowsTableAnnotationComposer,
      $$YearCacheRowsTableCreateCompanionBuilder,
      $$YearCacheRowsTableUpdateCompanionBuilder,
      (
        YearCacheRow,
        BaseReferences<_$AppDatabase, $YearCacheRowsTable, YearCacheRow>,
      ),
      YearCacheRow,
      PrefetchHooks Function()
    >;
typedef $$CardMappingRowsTableCreateCompanionBuilder =
    CardMappingRowsCompanion Function({
      required String cardKey,
      required String songId,
      Value<String> raw,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CardMappingRowsTableUpdateCompanionBuilder =
    CardMappingRowsCompanion Function({
      Value<String> cardKey,
      Value<String> songId,
      Value<String> raw,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CardMappingRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CardMappingRowsTable, CardMappingRow> {
  $$CardMappingRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongRowsTable _songIdTable(_$AppDatabase db) =>
      db.songRows.createAlias('card_mapping_rows__song_id__song_rows__id');

  $$SongRowsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongRowsTableTableManager(
      $_db,
      $_db.songRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardMappingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CardMappingRowsTable> {
  $$CardMappingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardKey => $composableBuilder(
    column: $table.cardKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SongRowsTableFilterComposer get songId {
    final $$SongRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongRowsTableFilterComposer(
            $db: $db,
            $table: $db.songRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardMappingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardMappingRowsTable> {
  $$CardMappingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardKey => $composableBuilder(
    column: $table.cardKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongRowsTableOrderingComposer get songId {
    final $$SongRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongRowsTableOrderingComposer(
            $db: $db,
            $table: $db.songRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardMappingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardMappingRowsTable> {
  $$CardMappingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardKey =>
      $composableBuilder(column: $table.cardKey, builder: (column) => column);

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SongRowsTableAnnotationComposer get songId {
    final $$SongRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.songRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardMappingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardMappingRowsTable,
          CardMappingRow,
          $$CardMappingRowsTableFilterComposer,
          $$CardMappingRowsTableOrderingComposer,
          $$CardMappingRowsTableAnnotationComposer,
          $$CardMappingRowsTableCreateCompanionBuilder,
          $$CardMappingRowsTableUpdateCompanionBuilder,
          (CardMappingRow, $$CardMappingRowsTableReferences),
          CardMappingRow,
          PrefetchHooks Function({bool songId})
        > {
  $$CardMappingRowsTableTableManager(
    _$AppDatabase db,
    $CardMappingRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardMappingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardMappingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardMappingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardKey = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<String> raw = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardMappingRowsCompanion(
                cardKey: cardKey,
                songId: songId,
                raw: raw,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardKey,
                required String songId,
                Value<String> raw = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardMappingRowsCompanion.insert(
                cardKey: cardKey,
                songId: songId,
                raw: raw,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardMappingRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable:
                                    $$CardMappingRowsTableReferences
                                        ._songIdTable(db),
                                referencedColumn:
                                    $$CardMappingRowsTableReferences
                                        ._songIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardMappingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardMappingRowsTable,
      CardMappingRow,
      $$CardMappingRowsTableFilterComposer,
      $$CardMappingRowsTableOrderingComposer,
      $$CardMappingRowsTableAnnotationComposer,
      $$CardMappingRowsTableCreateCompanionBuilder,
      $$CardMappingRowsTableUpdateCompanionBuilder,
      (CardMappingRow, $$CardMappingRowsTableReferences),
      CardMappingRow,
      PrefetchHooks Function({bool songId})
    >;
typedef $$CardSetRowsTableCreateCompanionBuilder =
    CardSetRowsCompanion Function({
      required String id,
      required String name,
      required String language,
      Value<String?> sku,
      Value<String?> sourceUrl,
      Value<int> cardCount,
      Value<DateTime?> importedAt,
      Value<int> rowid,
    });
typedef $$CardSetRowsTableUpdateCompanionBuilder =
    CardSetRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> language,
      Value<String?> sku,
      Value<String?> sourceUrl,
      Value<int> cardCount,
      Value<DateTime?> importedAt,
      Value<int> rowid,
    });

class $$CardSetRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CardSetRowsTable> {
  $$CardSetRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardSetRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardSetRowsTable> {
  $$CardSetRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardSetRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardSetRowsTable> {
  $$CardSetRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<int> get cardCount =>
      $composableBuilder(column: $table.cardCount, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$CardSetRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardSetRowsTable,
          CardSetRow,
          $$CardSetRowsTableFilterComposer,
          $$CardSetRowsTableOrderingComposer,
          $$CardSetRowsTableAnnotationComposer,
          $$CardSetRowsTableCreateCompanionBuilder,
          $$CardSetRowsTableUpdateCompanionBuilder,
          (
            CardSetRow,
            BaseReferences<_$AppDatabase, $CardSetRowsTable, CardSetRow>,
          ),
          CardSetRow,
          PrefetchHooks Function()
        > {
  $$CardSetRowsTableTableManager(_$AppDatabase db, $CardSetRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardSetRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardSetRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardSetRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardSetRowsCompanion(
                id: id,
                name: name,
                language: language,
                sku: sku,
                sourceUrl: sourceUrl,
                cardCount: cardCount,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String language,
                Value<String?> sku = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardSetRowsCompanion.insert(
                id: id,
                name: name,
                language: language,
                sku: sku,
                sourceUrl: sourceUrl,
                cardCount: cardCount,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardSetRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardSetRowsTable,
      CardSetRow,
      $$CardSetRowsTableFilterComposer,
      $$CardSetRowsTableOrderingComposer,
      $$CardSetRowsTableAnnotationComposer,
      $$CardSetRowsTableCreateCompanionBuilder,
      $$CardSetRowsTableUpdateCompanionBuilder,
      (
        CardSetRow,
        BaseReferences<_$AppDatabase, $CardSetRowsTable, CardSetRow>,
      ),
      CardSetRow,
      PrefetchHooks Function()
    >;
typedef $$SettingRowsTableCreateCompanionBuilder =
    SettingRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingRowsTableUpdateCompanionBuilder =
    SettingRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingRowsTable,
          SettingRow,
          $$SettingRowsTableFilterComposer,
          $$SettingRowsTableOrderingComposer,
          $$SettingRowsTableAnnotationComposer,
          $$SettingRowsTableCreateCompanionBuilder,
          $$SettingRowsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingRowsTableTableManager(_$AppDatabase db, $SettingRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingRowsTable,
      SettingRow,
      $$SettingRowsTableFilterComposer,
      $$SettingRowsTableOrderingComposer,
      $$SettingRowsTableAnnotationComposer,
      $$SettingRowsTableCreateCompanionBuilder,
      $$SettingRowsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongRowsTableTableManager get songRows =>
      $$SongRowsTableTableManager(_db, _db.songRows);
  $$PlaylistRowsTableTableManager get playlistRows =>
      $$PlaylistRowsTableTableManager(_db, _db.playlistRows);
  $$PlaylistSongRowsTableTableManager get playlistSongRows =>
      $$PlaylistSongRowsTableTableManager(_db, _db.playlistSongRows);
  $$YearCacheRowsTableTableManager get yearCacheRows =>
      $$YearCacheRowsTableTableManager(_db, _db.yearCacheRows);
  $$CardMappingRowsTableTableManager get cardMappingRows =>
      $$CardMappingRowsTableTableManager(_db, _db.cardMappingRows);
  $$CardSetRowsTableTableManager get cardSetRows =>
      $$CardSetRowsTableTableManager(_db, _db.cardSetRows);
  $$SettingRowsTableTableManager get settingRows =>
      $$SettingRowsTableTableManager(_db, _db.settingRows);
}

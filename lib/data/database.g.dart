// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SleepRecordsTable extends SleepRecords
    with TableInfo<$SleepRecordsTable, SleepRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _anchorDateMeta = const VerificationMeta(
    'anchorDate',
  );
  @override
  late final GeneratedColumn<DateTime> anchorDate = GeneratedColumn<DateTime>(
    'anchor_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bedTimeMeta = const VerificationMeta(
    'bedTime',
  );
  @override
  late final GeneratedColumn<DateTime> bedTime = GeneratedColumn<DateTime>(
    'bed_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wakeTimeMeta = const VerificationMeta(
    'wakeTime',
  );
  @override
  late final GeneratedColumn<DateTime> wakeTime = GeneratedColumn<DateTime>(
    'wake_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
    'quality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dreamMeta = const VerificationMeta('dream');
  @override
  late final GeneratedColumn<String> dream = GeneratedColumn<String>(
    'dream',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isManualMeta = const VerificationMeta(
    'isManual',
  );
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
    'is_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bed_only'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    anchorDate,
    bedTime,
    wakeTime,
    durationMin,
    quality,
    note,
    dream,
    isManual,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('anchor_date')) {
      context.handle(
        _anchorDateMeta,
        anchorDate.isAcceptableOrUnknown(data['anchor_date']!, _anchorDateMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDateMeta);
    }
    if (data.containsKey('bed_time')) {
      context.handle(
        _bedTimeMeta,
        bedTime.isAcceptableOrUnknown(data['bed_time']!, _bedTimeMeta),
      );
    }
    if (data.containsKey('wake_time')) {
      context.handle(
        _wakeTimeMeta,
        wakeTime.isAcceptableOrUnknown(data['wake_time']!, _wakeTimeMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('dream')) {
      context.handle(
        _dreamMeta,
        dream.isAcceptableOrUnknown(data['dream']!, _dreamMeta),
      );
    }
    if (data.containsKey('is_manual')) {
      context.handle(
        _isManualMeta,
        isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {anchorDate},
  ];
  @override
  SleepRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      anchorDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}anchor_date'],
      )!,
      bedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bed_time'],
      ),
      wakeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wake_time'],
      ),
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      dream: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dream'],
      ),
      isManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SleepRecordsTable createAlias(String alias) {
    return $SleepRecordsTable(attachedDatabase, alias);
  }
}

class SleepRecord extends DataClass implements Insertable<SleepRecord> {
  final int id;
  final DateTime anchorDate;
  final DateTime? bedTime;
  final DateTime? wakeTime;
  final int? durationMin;
  final int quality;
  final String? note;
  final String? dream;
  final bool isManual;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SleepRecord({
    required this.id,
    required this.anchorDate,
    this.bedTime,
    this.wakeTime,
    this.durationMin,
    required this.quality,
    this.note,
    this.dream,
    required this.isManual,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['anchor_date'] = Variable<DateTime>(anchorDate);
    if (!nullToAbsent || bedTime != null) {
      map['bed_time'] = Variable<DateTime>(bedTime);
    }
    if (!nullToAbsent || wakeTime != null) {
      map['wake_time'] = Variable<DateTime>(wakeTime);
    }
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    map['quality'] = Variable<int>(quality);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || dream != null) {
      map['dream'] = Variable<String>(dream);
    }
    map['is_manual'] = Variable<bool>(isManual);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SleepRecordsCompanion toCompanion(bool nullToAbsent) {
    return SleepRecordsCompanion(
      id: Value(id),
      anchorDate: Value(anchorDate),
      bedTime: bedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(bedTime),
      wakeTime: wakeTime == null && nullToAbsent
          ? const Value.absent()
          : Value(wakeTime),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      quality: Value(quality),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dream: dream == null && nullToAbsent
          ? const Value.absent()
          : Value(dream),
      isManual: Value(isManual),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SleepRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepRecord(
      id: serializer.fromJson<int>(json['id']),
      anchorDate: serializer.fromJson<DateTime>(json['anchorDate']),
      bedTime: serializer.fromJson<DateTime?>(json['bedTime']),
      wakeTime: serializer.fromJson<DateTime?>(json['wakeTime']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      quality: serializer.fromJson<int>(json['quality']),
      note: serializer.fromJson<String?>(json['note']),
      dream: serializer.fromJson<String?>(json['dream']),
      isManual: serializer.fromJson<bool>(json['isManual']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'anchorDate': serializer.toJson<DateTime>(anchorDate),
      'bedTime': serializer.toJson<DateTime?>(bedTime),
      'wakeTime': serializer.toJson<DateTime?>(wakeTime),
      'durationMin': serializer.toJson<int?>(durationMin),
      'quality': serializer.toJson<int>(quality),
      'note': serializer.toJson<String?>(note),
      'dream': serializer.toJson<String?>(dream),
      'isManual': serializer.toJson<bool>(isManual),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SleepRecord copyWith({
    int? id,
    DateTime? anchorDate,
    Value<DateTime?> bedTime = const Value.absent(),
    Value<DateTime?> wakeTime = const Value.absent(),
    Value<int?> durationMin = const Value.absent(),
    int? quality,
    Value<String?> note = const Value.absent(),
    Value<String?> dream = const Value.absent(),
    bool? isManual,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SleepRecord(
    id: id ?? this.id,
    anchorDate: anchorDate ?? this.anchorDate,
    bedTime: bedTime.present ? bedTime.value : this.bedTime,
    wakeTime: wakeTime.present ? wakeTime.value : this.wakeTime,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    quality: quality ?? this.quality,
    note: note.present ? note.value : this.note,
    dream: dream.present ? dream.value : this.dream,
    isManual: isManual ?? this.isManual,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SleepRecord copyWithCompanion(SleepRecordsCompanion data) {
    return SleepRecord(
      id: data.id.present ? data.id.value : this.id,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      bedTime: data.bedTime.present ? data.bedTime.value : this.bedTime,
      wakeTime: data.wakeTime.present ? data.wakeTime.value : this.wakeTime,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      quality: data.quality.present ? data.quality.value : this.quality,
      note: data.note.present ? data.note.value : this.note,
      dream: data.dream.present ? data.dream.value : this.dream,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepRecord(')
          ..write('id: $id, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('bedTime: $bedTime, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('quality: $quality, ')
          ..write('note: $note, ')
          ..write('dream: $dream, ')
          ..write('isManual: $isManual, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    anchorDate,
    bedTime,
    wakeTime,
    durationMin,
    quality,
    note,
    dream,
    isManual,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepRecord &&
          other.id == this.id &&
          other.anchorDate == this.anchorDate &&
          other.bedTime == this.bedTime &&
          other.wakeTime == this.wakeTime &&
          other.durationMin == this.durationMin &&
          other.quality == this.quality &&
          other.note == this.note &&
          other.dream == this.dream &&
          other.isManual == this.isManual &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SleepRecordsCompanion extends UpdateCompanion<SleepRecord> {
  final Value<int> id;
  final Value<DateTime> anchorDate;
  final Value<DateTime?> bedTime;
  final Value<DateTime?> wakeTime;
  final Value<int?> durationMin;
  final Value<int> quality;
  final Value<String?> note;
  final Value<String?> dream;
  final Value<bool> isManual;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SleepRecordsCompanion({
    this.id = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.bedTime = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.quality = const Value.absent(),
    this.note = const Value.absent(),
    this.dream = const Value.absent(),
    this.isManual = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SleepRecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime anchorDate,
    this.bedTime = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.quality = const Value.absent(),
    this.note = const Value.absent(),
    this.dream = const Value.absent(),
    this.isManual = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : anchorDate = Value(anchorDate);
  static Insertable<SleepRecord> custom({
    Expression<int>? id,
    Expression<DateTime>? anchorDate,
    Expression<DateTime>? bedTime,
    Expression<DateTime>? wakeTime,
    Expression<int>? durationMin,
    Expression<int>? quality,
    Expression<String>? note,
    Expression<String>? dream,
    Expression<bool>? isManual,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (bedTime != null) 'bed_time': bedTime,
      if (wakeTime != null) 'wake_time': wakeTime,
      if (durationMin != null) 'duration_min': durationMin,
      if (quality != null) 'quality': quality,
      if (note != null) 'note': note,
      if (dream != null) 'dream': dream,
      if (isManual != null) 'is_manual': isManual,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SleepRecordsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? anchorDate,
    Value<DateTime?>? bedTime,
    Value<DateTime?>? wakeTime,
    Value<int?>? durationMin,
    Value<int>? quality,
    Value<String?>? note,
    Value<String?>? dream,
    Value<bool>? isManual,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SleepRecordsCompanion(
      id: id ?? this.id,
      anchorDate: anchorDate ?? this.anchorDate,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      durationMin: durationMin ?? this.durationMin,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      dream: dream ?? this.dream,
      isManual: isManual ?? this.isManual,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<DateTime>(anchorDate.value);
    }
    if (bedTime.present) {
      map['bed_time'] = Variable<DateTime>(bedTime.value);
    }
    if (wakeTime.present) {
      map['wake_time'] = Variable<DateTime>(wakeTime.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dream.present) {
      map['dream'] = Variable<String>(dream.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepRecordsCompanion(')
          ..write('id: $id, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('bedTime: $bedTime, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('durationMin: $durationMin, ')
          ..write('quality: $quality, ')
          ..write('note: $note, ')
          ..write('dream: $dream, ')
          ..write('isManual: $isManual, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
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
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
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
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
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

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
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
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
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

  SettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsEntriesCompanion(
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
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgesTable extends Badges with TableInfo<$BadgesTable, UnlockedBadge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _badgeKeyMeta = const VerificationMeta(
    'badgeKey',
  );
  @override
  late final GeneratedColumn<String> badgeKey = GeneratedColumn<String>(
    'badge_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [badgeKey, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badges';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnlockedBadge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('badge_key')) {
      context.handle(
        _badgeKeyMeta,
        badgeKey.isAcceptableOrUnknown(data['badge_key']!, _badgeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeKeyMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {badgeKey};
  @override
  UnlockedBadge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnlockedBadge(
      badgeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_key'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $BadgesTable createAlias(String alias) {
    return $BadgesTable(attachedDatabase, alias);
  }
}

class UnlockedBadge extends DataClass implements Insertable<UnlockedBadge> {
  final String badgeKey;
  final DateTime unlockedAt;
  const UnlockedBadge({required this.badgeKey, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['badge_key'] = Variable<String>(badgeKey);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  BadgesCompanion toCompanion(bool nullToAbsent) {
    return BadgesCompanion(
      badgeKey: Value(badgeKey),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory UnlockedBadge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnlockedBadge(
      badgeKey: serializer.fromJson<String>(json['badgeKey']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'badgeKey': serializer.toJson<String>(badgeKey),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  UnlockedBadge copyWith({String? badgeKey, DateTime? unlockedAt}) =>
      UnlockedBadge(
        badgeKey: badgeKey ?? this.badgeKey,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  UnlockedBadge copyWithCompanion(BadgesCompanion data) {
    return UnlockedBadge(
      badgeKey: data.badgeKey.present ? data.badgeKey.value : this.badgeKey,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedBadge(')
          ..write('badgeKey: $badgeKey, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(badgeKey, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnlockedBadge &&
          other.badgeKey == this.badgeKey &&
          other.unlockedAt == this.unlockedAt);
}

class BadgesCompanion extends UpdateCompanion<UnlockedBadge> {
  final Value<String> badgeKey;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const BadgesCompanion({
    this.badgeKey = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgesCompanion.insert({
    required String badgeKey,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : badgeKey = Value(badgeKey),
       unlockedAt = Value(unlockedAt);
  static Insertable<UnlockedBadge> custom({
    Expression<String>? badgeKey,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (badgeKey != null) 'badge_key': badgeKey,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgesCompanion copyWith({
    Value<String>? badgeKey,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return BadgesCompanion(
      badgeKey: badgeKey ?? this.badgeKey,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (badgeKey.present) {
      map['badge_key'] = Variable<String>(badgeKey.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesCompanion(')
          ..write('badgeKey: $badgeKey, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SleepRecordsTable sleepRecords = $SleepRecordsTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(
    this,
  );
  late final $BadgesTable badges = $BadgesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sleepRecords,
    settingsEntries,
    badges,
  ];
}

typedef $$SleepRecordsTableCreateCompanionBuilder =
    SleepRecordsCompanion Function({
      Value<int> id,
      required DateTime anchorDate,
      Value<DateTime?> bedTime,
      Value<DateTime?> wakeTime,
      Value<int?> durationMin,
      Value<int> quality,
      Value<String?> note,
      Value<String?> dream,
      Value<bool> isManual,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SleepRecordsTableUpdateCompanionBuilder =
    SleepRecordsCompanion Function({
      Value<int> id,
      Value<DateTime> anchorDate,
      Value<DateTime?> bedTime,
      Value<DateTime?> wakeTime,
      Value<int?> durationMin,
      Value<int> quality,
      Value<String?> note,
      Value<String?> dream,
      Value<bool> isManual,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$SleepRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bedTime => $composableBuilder(
    column: $table.bedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dream => $composableBuilder(
    column: $table.dream,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bedTime => $composableBuilder(
    column: $table.bedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dream => $composableBuilder(
    column: $table.dream,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get bedTime =>
      $composableBuilder(column: $table.bedTime, builder: (column) => column);

  GeneratedColumn<DateTime> get wakeTime =>
      $composableBuilder(column: $table.wakeTime, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get dream =>
      $composableBuilder(column: $table.dream, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SleepRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepRecordsTable,
          SleepRecord,
          $$SleepRecordsTableFilterComposer,
          $$SleepRecordsTableOrderingComposer,
          $$SleepRecordsTableAnnotationComposer,
          $$SleepRecordsTableCreateCompanionBuilder,
          $$SleepRecordsTableUpdateCompanionBuilder,
          (
            SleepRecord,
            BaseReferences<_$AppDatabase, $SleepRecordsTable, SleepRecord>,
          ),
          SleepRecord,
          PrefetchHooks Function()
        > {
  $$SleepRecordsTableTableManager(_$AppDatabase db, $SleepRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> anchorDate = const Value.absent(),
                Value<DateTime?> bedTime = const Value.absent(),
                Value<DateTime?> wakeTime = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int> quality = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> dream = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SleepRecordsCompanion(
                id: id,
                anchorDate: anchorDate,
                bedTime: bedTime,
                wakeTime: wakeTime,
                durationMin: durationMin,
                quality: quality,
                note: note,
                dream: dream,
                isManual: isManual,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime anchorDate,
                Value<DateTime?> bedTime = const Value.absent(),
                Value<DateTime?> wakeTime = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int> quality = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> dream = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SleepRecordsCompanion.insert(
                id: id,
                anchorDate: anchorDate,
                bedTime: bedTime,
                wakeTime: wakeTime,
                durationMin: durationMin,
                quality: quality,
                note: note,
                dream: dream,
                isManual: isManual,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepRecordsTable, SleepRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SleepRecordsTable,
                    SleepRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepRecordsTable,
      SleepRecord,
      $$SleepRecordsTableFilterComposer,
      $$SleepRecordsTableOrderingComposer,
      $$SleepRecordsTableAnnotationComposer,
      $$SleepRecordsTableCreateCompanionBuilder,
      $$SleepRecordsTableUpdateCompanionBuilder,
      (
        SleepRecord,
        BaseReferences<_$AppDatabase, $SleepRecordsTable, SleepRecord>,
      ),
      SleepRecord,
      PrefetchHooks Function()
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder =
    SettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsEntriesTableUpdateCompanionBuilder =
    SettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
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

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
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

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
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

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingEntry,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(
    _$AppDatabase db,
    $SettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsEntriesTable, SettingEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsEntriesTable,
                    SettingEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingEntry,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;
typedef $$BadgesTableCreateCompanionBuilder = BadgesCompanion Function({
  required String badgeKey,
  required DateTime unlockedAt,
  Value<int> rowid,
});
typedef $$BadgesTableUpdateCompanionBuilder = BadgesCompanion Function({
  Value<String> badgeKey,
  Value<DateTime> unlockedAt,
  Value<int> rowid,
});

class $$BadgesTableFilterComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get badgeKey => $composableBuilder(
    column: $table.badgeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BadgesTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get badgeKey => $composableBuilder(
    column: $table.badgeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgesTable> {
  $$BadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get badgeKey =>
      $composableBuilder(column: $table.badgeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$BadgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgesTable,
          UnlockedBadge,
          $$BadgesTableFilterComposer,
          $$BadgesTableOrderingComposer,
          $$BadgesTableAnnotationComposer,
          $$BadgesTableCreateCompanionBuilder,
          $$BadgesTableUpdateCompanionBuilder,
          (
            UnlockedBadge,
            BaseReferences<_$AppDatabase, $BadgesTable, UnlockedBadge>,
          ),
          UnlockedBadge,
          PrefetchHooks Function()
        > {
  $$BadgesTableTableManager(_$AppDatabase db, $BadgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> badgeKey = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgesCompanion(
                badgeKey: badgeKey,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String badgeKey,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => BadgesCompanion.insert(
                badgeKey: badgeKey,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BadgesTable, UnlockedBadge>(table),
                  BaseReferences<_$AppDatabase, $BadgesTable, UnlockedBadge>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgesTable,
      UnlockedBadge,
      $$BadgesTableFilterComposer,
      $$BadgesTableOrderingComposer,
      $$BadgesTableAnnotationComposer,
      $$BadgesTableCreateCompanionBuilder,
      $$BadgesTableUpdateCompanionBuilder,
      (
        UnlockedBadge,
        BaseReferences<_$AppDatabase, $BadgesTable, UnlockedBadge>,
      ),
      UnlockedBadge,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SleepRecordsTableTableManager get sleepRecords =>
      $$SleepRecordsTableTableManager(_db, _db.sleepRecords);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
  $$BadgesTableTableManager get badges =>
      $$BadgesTableTableManager(_db, _db.badges);
}

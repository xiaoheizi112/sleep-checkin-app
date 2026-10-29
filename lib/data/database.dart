import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// 睡眠记录表：anchorDate 是"醒来的那一天"，一天最多一条。
@DataClassName('SleepRecord')
class SleepRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get anchorDate => dateTime()();
  DateTimeColumn get bedTime => dateTime().nullable()();
  DateTimeColumn get wakeTime => dateTime().nullable()();
  IntColumn get durationMin => integer().nullable()();
  IntColumn get quality => integer().withDefault(const Constant(3))();
  TextColumn get note => text().nullable()();
  TextColumn get dream => text().nullable()();
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('bed_only'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {anchorDate},
      ];
}

/// 设置表：key-value 结构（达标时长、早睡目标等）。
@DataClassName('SettingEntry')
class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 已解锁徽章。徽章定义在代码里，这张表只记录解锁时间。
@DataClassName('UnlockedBadge')
class Badges extends Table {
  TextColumn get badgeKey => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {badgeKey};
}

@DriftDatabase(tables: [SleepRecords, SettingsEntries, Badges])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(badges);
          }
        },
      );

  Stream<List<SleepRecord>> watchAllRecords() => (select(sleepRecords)
        ..orderBy([(t) => OrderingTerm.desc(t.anchorDate)]))
      .watch();

  Future<List<SleepRecord>> allRecords() => (select(sleepRecords)
        ..orderBy([(t) => OrderingTerm.asc(t.anchorDate)]))
      .get();

  Future<SleepRecord?> recordForDate(DateTime day) {
    final d = _dateOnly(day);
    return (select(sleepRecords)..where((t) => t.anchorDate.equals(d)))
        .getSingleOrNull();
  }

  /// 睡前打卡：18 点后打卡归属到明天（醒来那天），凌晨打卡归属当天。
  Future<SleepRecord> startBedCheckIn(DateTime now) async {
    final anchor = _bedAnchorDate(now);
    final existing = await recordForDate(anchor);
    if (existing != null) return existing;
    return into(sleepRecords).insertReturning(
      SleepRecordsCompanion.insert(
        anchorDate: _dateOnly(anchor),
        bedTime: Value(now),
        status: const Value('bed_only'),
      ),
    );
  }

  /// 起床打卡：补全入睡时间、时长、评分、备注与梦境小记。
  Future<SleepRecord> completeWake({
    required DateTime anchorDate,
    required DateTime bedTime,
    required DateTime wakeTime,
    required int quality,
    String? dream,
    String? note,
  }) async {
    final d = _dateOnly(anchorDate);
    final duration = wakeTime.difference(bedTime).inMinutes;
    final existing = await recordForDate(d);
    if (existing == null) {
      return into(sleepRecords).insertReturning(
        SleepRecordsCompanion.insert(
          anchorDate: d,
          bedTime: Value(bedTime),
          wakeTime: Value(wakeTime),
          durationMin: Value(duration),
          quality: Value(quality),
          dream: Value(dream),
          note: Value(note),
          status: const Value('complete'),
        ),
      );
    }
    await (update(sleepRecords)..where((t) => t.id.equals(existing.id))).write(
      SleepRecordsCompanion(
        bedTime: Value(bedTime),
        wakeTime: Value(wakeTime),
        durationMin: Value(duration),
        quality: Value(quality),
        dream: Value(dream),
        note: Value(note),
        status: const Value('complete'),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return (await recordForDate(d))!;
  }

  /// 补录/编辑记录。新建的补录记录标记 isManual。
  Future<void> saveManualRecord({
    required DateTime anchorDate,
    required DateTime bedTime,
    required DateTime wakeTime,
    required int quality,
    String? dream,
    String? note,
  }) async {
    final d = _dateOnly(anchorDate);
    final duration = wakeTime.difference(bedTime).inMinutes;
    final existing = await recordForDate(d);
    if (existing == null) {
      await into(sleepRecords).insert(
        SleepRecordsCompanion.insert(
          anchorDate: d,
          bedTime: Value(bedTime),
          wakeTime: Value(wakeTime),
          durationMin: Value(duration),
          quality: Value(quality),
          dream: Value(dream),
          note: Value(note),
          isManual: const Value(true),
          status: const Value('complete'),
        ),
      );
    } else {
      await (update(sleepRecords)..where((t) => t.id.equals(existing.id)))
          .write(
        SleepRecordsCompanion(
          bedTime: Value(bedTime),
          wakeTime: Value(wakeTime),
          durationMin: Value(duration),
          quality: Value(quality),
          dream: Value(dream),
          note: Value(note),
          status: const Value('complete'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> deleteRecord(int id) =>
      (delete(sleepRecords)..where((t) => t.id.equals(id))).go();

  Stream<Map<String, String>> watchSettings() =>
      select(settingsEntries).watch().map(
            (rows) => {for (final row in rows) row.key: row.value},
          );

  Future<Map<String, String>> allSettingsMap() async {
    final rows = await select(settingsEntries).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> setSetting(String key, String value) =>
      into(settingsEntries).insertOnConflictUpdate(
        SettingsEntriesCompanion.insert(key: key, value: value),
      );

  Stream<List<UnlockedBadge>> watchBadges() => (select(badges)
        ..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
      .watch();

  Future<List<UnlockedBadge>> allBadges() => select(badges).get();

  Future<void> unlockBadge(String key, DateTime at) => into(badges).insert(
        BadgesCompanion.insert(badgeKey: key, unlockedAt: at),
        mode: InsertMode.insertOrIgnore,
      );

  /// 备份恢复用：保留原始时间与状态，不保留自增 id。
  Future<void> insertRecordFromBackup(SleepRecord record) =>
      into(sleepRecords).insert(
        SleepRecordsCompanion.insert(
          anchorDate: _dateOnly(record.anchorDate),
          bedTime: Value(record.bedTime),
          wakeTime: Value(record.wakeTime),
          durationMin: Value(record.durationMin),
          quality: Value(record.quality),
          note: Value(record.note),
          dream: Value(record.dream),
          isManual: Value(record.isManual),
          status: Value(record.status),
          createdAt: Value(record.createdAt),
          updatedAt: Value(record.updatedAt),
        ),
        mode: InsertMode.insertOrReplace,
      );

  Future<void> clearAllData() async {
    await delete(sleepRecords).go();
    await delete(settingsEntries).go();
    await delete(badges).go();
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _bedAnchorDate(DateTime now) {
  if (now.hour >= 18) return _dateOnly(now).add(const Duration(days: 1));
  return _dateOnly(now);
}

Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'sleep_checkin.sqlite'));
  return AppDatabase(NativeDatabase.createInBackground(file));
}
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../data/database.dart';

class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  Future<String> buildJson() async {
    final records = await db.allRecords();
    final settings = await db.allSettingsMap();
    final badges = await db.allBadges();
    final data = <String, Object?>{
      'app': 'sleep_checkin',
      'schemaVersion': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'records': [
        for (final r in records)
          {
            'anchorDate': r.anchorDate.toIso8601String(),
            'bedTime': r.bedTime?.toIso8601String(),
            'wakeTime': r.wakeTime?.toIso8601String(),
            'durationMin': r.durationMin,
            'quality': r.quality,
            'note': r.note,
            'dream': r.dream,
            'isManual': r.isManual,
            'status': r.status,
            'createdAt': r.createdAt.toIso8601String(),
            'updatedAt': r.updatedAt.toIso8601String(),
          },
      ],
      'settings': settings,
      'badges': [
        for (final b in badges)
          {
            'badgeKey': b.badgeKey,
            'unlockedAt': b.unlockedAt.toIso8601String(),
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// 返回 false 表示用户取消了保存。
  Future<bool> exportToFile() async {
    final content = await buildJson();
    final uri = await FilePicker.saveFile(
      fileName: '睡眠打卡备份_${_stamp(DateTime.now())}.json',
      bytes: Uint8List.fromList(utf8.encode(content)),
      mimeType: 'application/json',
      dialogTitle: '导出睡眠数据',
    );
    return uri != null;
  }

  /// 返回导入的睡眠记录条数，-1 表示用户取消。
  Future<int> importFromFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: '选择睡眠备份文件',
    );
    if (file == null) return -1;
    final bytes = await file.readAsBytes();
    return importJson(utf8.decode(bytes));
  }

  Future<int> importJson(String content) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map || decoded['records'] is! List) {
      throw const FormatException('不是有效的睡眠打卡备份文件');
    }

    final records = <SleepRecord>[];
    for (final item in decoded['records'] as List) {
      if (item is! Map) continue;
      final anchor = _parseDate(item['anchorDate']);
      if (anchor == null) continue;
      final bed = _parseDate(item['bedTime']);
      final wake = _parseDate(item['wakeTime']);
      records.add(SleepRecord(
        id: 0,
        anchorDate: anchor,
        bedTime: bed,
        wakeTime: wake,
        durationMin: (item['durationMin'] as num?)?.toInt() ??
            (bed != null && wake != null
                ? wake.difference(bed).inMinutes
                : null),
        quality: ((item['quality'] as num?)?.toInt() ?? 3).clamp(1, 5),
        note: item['note'] is String ? item['note'] as String : null,
        dream: item['dream'] is String ? item['dream'] as String : null,
        isManual: item['isManual'] == true,
        status: item['status'] is String
            ? item['status'] as String
            : (wake != null ? 'complete' : 'bed_only'),
        createdAt: _parseDate(item['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDate(item['updatedAt']) ?? DateTime.now(),
      ));
    }
    if (records.isEmpty) {
      throw const FormatException('备份文件中没有可恢复的睡眠记录');
    }

    final settings = <String, String>{};
    final rawSettings = decoded['settings'];
    if (rawSettings is Map) {
      for (final entry in rawSettings.entries) {
        if (entry.key is String && entry.value is String) {
          settings[entry.key as String] = entry.value as String;
        }
      }
    }

    final badges = <UnlockedBadge>[];
    final rawBadges = decoded['badges'];
    if (rawBadges is List) {
      for (final item in rawBadges) {
        if (item is Map && item['badgeKey'] is String) {
          badges.add(UnlockedBadge(
            badgeKey: item['badgeKey'] as String,
            unlockedAt: _parseDate(item['unlockedAt']) ?? DateTime.now(),
          ));
        }
      }
    }

    await db.transaction(() async {
      await db.clearAllData();
      for (final record in records) {
        await db.insertRecordFromBackup(record);
      }
      for (final entry in settings.entries) {
        await db.setSetting(entry.key, entry.value);
      }
      for (final badge in badges) {
        await db.unlockBadge(badge.badgeKey, badge.unlockedAt);
      }
    });
    return records.length;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  static String _stamp(DateTime time) {
    final date =
        '${time.year}${time.month.toString().padLeft(2, '0')}${time.day.toString().padLeft(2, '0')}';
    final clock =
        '${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}';
    return '${date}_$clock';
  }
}
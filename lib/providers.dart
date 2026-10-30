import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'logic/badges.dart';
import 'logic/setting_keys.dart';
import 'logic/stats_math.dart';
import 'services/backup_service.dart';

export 'logic/setting_keys.dart';

/// 在 main() 中用真实数据库 override。
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider 未初始化'),
);

final recordsProvider = StreamProvider<List<SleepRecord>>(
  (ref) => ref.watch(databaseProvider).watchAllRecords(),
);

final settingsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(databaseProvider).watchSettings(),
);

final badgesProvider = StreamProvider<List<UnlockedBadge>>(
  (ref) => ref.watch(databaseProvider).watchBadges(),
);

final badgeServiceProvider = Provider<BadgeChecker>(
  (ref) => BadgeService(ref.watch(databaseProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

/// 每 20 秒刷新一次当前时间，用于首页打卡状态切换。
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 20), (_) => DateTime.now());
});

/// 每晚达标时长（分钟），默认 7 小时。
final targetDurationProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final raw = settings?[SettingKeys.targetDurationMin];
  return int.tryParse(raw ?? '') ?? 420;
});

/// 早睡目标（折算后的分钟数），默认 23:30。
final earlyBedMinutesProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return parseEarlyBedMinutes(settings?[SettingKeys.earlyBedTime]);
});

/// 每周早睡达标天数，默认 5 天。
final weeklyGoalDaysProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return int.tryParse(settings?[SettingKeys.weeklyGoalDays] ?? '') ?? 5;
});

/// 睡前提醒，默认开启（23:00）。
final reminderBedEnabledProvider = Provider<bool>((ref) {
  final raw = ref.watch(settingsProvider).value?[SettingKeys.reminderBedEnabled];
  return raw != '0';
});

final reminderBedMinutesProvider = Provider<int>((ref) {
  final raw = ref.watch(settingsProvider).value?[SettingKeys.reminderBedTime];
  return parseClockMinutes(raw, fallback: 23 * 60);
});

/// 起床提醒，默认开启（07:00）。
final reminderWakeEnabledProvider = Provider<bool>((ref) {
  final raw =
      ref.watch(settingsProvider).value?[SettingKeys.reminderWakeEnabled];
  return raw != '0';
});

final reminderWakeMinutesProvider = Provider<int>((ref) {
  final raw = ref.watch(settingsProvider).value?[SettingKeys.reminderWakeTime];
  return parseClockMinutes(raw, fallback: 7 * 60);
});

/// 白天（7:00–19:00）浅色，夜间深色。
final themeModeProvider = Provider<ThemeMode>((ref) {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  final isDaytime = now.hour >= 7 && now.hour < 19;
  return isDaytime ? ThemeMode.light : ThemeMode.dark;
});
import 'package:flutter/material.dart';

import '../data/database.dart';
import 'setting_keys.dart';
import 'sleep_math.dart';
import 'stats_math.dart';

class BadgeDef {
  const BadgeDef({
    required this.key,
    required this.name,
    required this.description,
    required this.icon,
    this.streakTarget,
  });

  final String key;
  final String name;
  final String description;
  final IconData icon;
  final int? streakTarget;
}

class BadgeCatalog {
  BadgeCatalog._();

  static const List<BadgeDef> all = [
    BadgeDef(
      key: 'first_record',
      name: '千里之行',
      description: '完成第一次完整打卡',
      icon: Icons.flag_rounded,
    ),
    BadgeDef(
      key: 'streak_3',
      name: '小试牛刀',
      description: '连续打卡 3 天',
      icon: Icons.local_fire_department_rounded,
      streakTarget: 3,
    ),
    BadgeDef(
      key: 'streak_7',
      name: '一周之约',
      description: '连续打卡 7 天',
      icon: Icons.whatshot_rounded,
      streakTarget: 7,
    ),
    BadgeDef(
      key: 'streak_21',
      name: '习惯养成',
      description: '连续打卡 21 天',
      icon: Icons.auto_awesome_rounded,
      streakTarget: 21,
    ),
    BadgeDef(
      key: 'streak_66',
      name: '刻入 DNA',
      description: '连续打卡 66 天',
      icon: Icons.diamond_rounded,
      streakTarget: 66,
    ),
    BadgeDef(
      key: 'streak_100',
      name: '百日筑基',
      description: '连续打卡 100 天',
      icon: Icons.workspace_premium_rounded,
      streakTarget: 100,
    ),
    BadgeDef(
      key: 'early_week',
      name: '早睡之星',
      description: '单周早睡目标达标',
      icon: Icons.nightlight_round,
    ),
    BadgeDef(
      key: 'early_month',
      name: '自律之月',
      description: '累计 4 个早睡达标周',
      icon: Icons.calendar_month_rounded,
    ),
    BadgeDef(
      key: 'regular_90',
      name: '钟表体质',
      description: '规律性评分达到 90 分',
      icon: Icons.schedule_rounded,
    ),
    BadgeDef(
      key: 'catchup',
      name: '亡羊补牢',
      description: '通过补卡接上断开的连续记录',
      icon: Icons.healing_rounded,
    ),
    BadgeDef(
      key: 'full_month',
      name: '满月全勤',
      description: '单个自然月每天都完成打卡',
      icon: Icons.verified_rounded,
    ),
    BadgeDef(
      key: 'night_owl_reform',
      name: '浪子回头',
      description: '从 1 点后入睡改善到 23:30 前',
      icon: Icons.wb_twilight_rounded,
    ),
  ];

  static int get total => all.length;

  static BadgeDef byKey(String key) =>
      all.firstWhere((badge) => badge.key == key);
}

abstract class BadgeChecker {
  Future<List<BadgeDef>> checkAndUnlock({DateTime? now});
}

class BadgeService implements BadgeChecker {
  BadgeService(this.db);

  final AppDatabase db;

  @override
  Future<List<BadgeDef>> checkAndUnlock({DateTime? now}) async {
    final records = await db.allRecords();
    final settings = await db.allSettingsMap();
    final unlocked = await db.allBadges();
    final unlockedKeys = unlocked.map((b) => b.badgeKey).toSet();

    final complete = records.where((r) => r.status == 'complete').toList();
    final days = completedDaysOf(complete);
    final today = dateOnly(now ?? DateTime.now());
    final best = bestStreak(days);
    final targetBed = parseEarlyBedMinutes(settings[SettingKeys.earlyBedTime]);
    final goalDays = int.tryParse(settings[SettingKeys.weeklyGoalDays] ?? '') ?? 5;
    final earlyWeeks = earlyWeekStats(
      complete,
      targetBedMin: targetBed,
      goalDays: goalDays,
      now: today,
    );
    final starWeeks = earlyWeeks.where((w) => w.isStar).length;
    final score = regularityScore(complete, now: today);
    final last14 = complete.where((r) {
      final d = dateOnly(r.anchorDate);
      return !d.isBefore(today.subtract(const Duration(days: 13))) &&
          !d.isAfter(today);
    }).length;

    var catchup = false;
    for (final r in complete.where((r) => r.isManual)) {
      final d = dateOnly(r.anchorDate);
      if (days.contains(d.subtract(const Duration(days: 1))) &&
          days.contains(d.add(const Duration(days: 1)))) {
        catchup = true;
        break;
      }
    }

    final conditions = <String, bool>{
      'first_record': complete.isNotEmpty,
      'streak_3': best >= 3,
      'streak_7': best >= 7,
      'streak_21': best >= 21,
      'streak_66': best >= 66,
      'streak_100': best >= 100,
      'early_week': earlyWeeks.any((w) => w.isStar),
      'early_month': starWeeks >= 4,
      'regular_90': score != null && score >= 90 && last14 >= 7,
      'catchup': catchup,
      'full_month': _hasFullMonth(days, today),
      'night_owl_reform': _nightOwlReform(complete),
    };

    final newly = <BadgeDef>[];
    for (final def in BadgeCatalog.all) {
      if (conditions[def.key] == true && !unlockedKeys.contains(def.key)) {
        await db.unlockBadge(def.key, DateTime.now());
        newly.add(def);
      }
    }
    return newly;
  }

  bool _hasFullMonth(Set<DateTime> days, DateTime today) {
    if (days.isEmpty) return false;
    final sorted = days.toList()..sort();
    var cursor = DateTime(sorted.first.year, sorted.first.month);
    final lastMonth = DateTime(today.year, today.month);
    while (!cursor.isAfter(lastMonth)) {
      final monthEnd = DateTime(cursor.year, cursor.month + 1, 0);
      final monthFinished =
          monthEnd.isBefore(today) || isSameDate(monthEnd, today);
      if (monthFinished) {
        var full = true;
        for (var day = 1; day <= monthEnd.day; day++) {
          if (!days.contains(DateTime(cursor.year, cursor.month, day))) {
            full = false;
            break;
          }
        }
        if (full) return true;
      }
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return false;
  }

  /// 数据前半段平均入睡晚于 1:00，后半段早于 23:30。
  bool _nightOwlReform(List<SleepRecord> complete) {
    final withBed = complete.where((r) => r.bedTime != null).toList()
      ..sort((a, b) => a.anchorDate.compareTo(b.anchorDate));
    if (withBed.length < 20) return false;
    final mid = withBed.length ~/ 2;
    final first = withBed.sublist(0, mid);
    final last = withBed.sublist(mid);
    if (first.length < 10 || last.length < 10) return false;
    final firstAvg = first
            .map((r) => normalizedBedMinutes(r.bedTime!))
            .reduce((a, b) => a + b) /
        first.length;
    final lastAvg =
        last.map((r) => normalizedBedMinutes(r.bedTime!)).reduce((a, b) => a + b) /
            last.length;
    return firstAvg >= 25 * 60 && lastAvg <= 23 * 60 + 30;
  }
}
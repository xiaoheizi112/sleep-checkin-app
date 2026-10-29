import 'dart:math' as math;

import '../data/database.dart';
import 'sleep_math.dart';

/// 入睡时间统一折算成分钟：中午 12 点前视为跨零点，+24 小时。
int normalizedBedMinutes(DateTime bed) {
  final minutes = bed.hour * 60 + bed.minute;
  return minutes < 12 * 60 ? minutes + 24 * 60 : minutes;
}

double _stdDev(List<int> values) {
  final mean = values.reduce((a, b) => a + b) / values.length;
  final variance =
      values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) /
          values.length;
  return math.sqrt(variance);
}

/// 规律性评分（0~100）：入睡与起床时间的波动越小分越高，1 分对应 4 分钟波动。
int? regularityScoreOf(Iterable<SleepRecord> records) {
  final valid = records
      .where((r) =>
          r.status == 'complete' && r.bedTime != null && r.wakeTime != null)
      .toList();
  if (valid.length < 3) return null;
  final beds = valid.map((r) => normalizedBedMinutes(r.bedTime!)).toList();
  final wakes =
      valid.map((r) => r.wakeTime!.hour * 60 + r.wakeTime!.minute).toList();
  final score = 100 - (_stdDev(beds) + _stdDev(wakes)) * 0.25;
  return score.clamp(0, 100).round();
}

int? regularityScore(
  List<SleepRecord> records, {
  DateTime? now,
  int days = 14,
}) {
  final end = dateOnly(now ?? DateTime.now());
  final start = end.subtract(Duration(days: days - 1));
  final filtered = records.where((r) {
    final d = dateOnly(r.anchorDate);
    return !d.isBefore(start) && !d.isAfter(end);
  });
  return regularityScoreOf(filtered);
}

class WindowStats {
  const WindowStats({
    this.avgBedMin,
    this.avgWakeMin,
    this.avgDurationMin,
    this.avgQuality,
    this.completionRate = 0,
  });

  final int? avgBedMin;
  final int? avgWakeMin;
  final int? avgDurationMin;
  final double? avgQuality;
  final double completionRate;

  static const empty = WindowStats();
}

/// 最近 N 天的关键指标（默认 30 天）。
WindowStats computeWindowStats(
  List<SleepRecord> records,
  DateTime now, {
  int days = 30,
}) {
  final end = dateOnly(now);
  final start = end.subtract(Duration(days: days - 1));
  final recs = records.where((r) {
    if (r.status != 'complete') return false;
    final d = dateOnly(r.anchorDate);
    return !d.isBefore(start) && !d.isAfter(end);
  }).toList();
  if (recs.isEmpty) return WindowStats.empty;

  final beds = recs
      .where((r) => r.bedTime != null)
      .map((r) => normalizedBedMinutes(r.bedTime!))
      .toList();
  final wakes = recs
      .where((r) => r.wakeTime != null)
      .map((r) => r.wakeTime!.hour * 60 + r.wakeTime!.minute)
      .toList();
  final durations = recs
      .where((r) => r.durationMin != null)
      .map((r) => r.durationMin!)
      .toList();
  final qualities = recs.map((r) => r.quality.toDouble()).toList();
  final distinctDays = recs.map((r) => dateOnly(r.anchorDate)).toSet().length;

  int? avg(List<int> values) =>
      values.isEmpty ? null : (values.reduce((a, b) => a + b) / values.length).round();

  return WindowStats(
    avgBedMin: avg(beds),
    avgWakeMin: avg(wakes),
    avgDurationMin: avg(durations),
    avgQuality: qualities.isEmpty
        ? null
        : qualities.reduce((a, b) => a + b) / qualities.length,
    completionRate: (distinctDays / days).clamp(0, 1),
  );
}

DateTime mondayOf(DateTime d) =>
    dateOnly(d).subtract(Duration(days: d.weekday - 1));

class WeekEarlyStats {
  const WeekEarlyStats({
    required this.weekStart,
    required this.achievedDays,
    required this.goalDays,
  });

  final DateTime weekStart;
  final int achievedDays;
  final int goalDays;

  bool get isStar => achievedDays >= goalDays;
}

/// 所有出现过的周（周一开始）的早睡达成情况。
List<WeekEarlyStats> earlyWeekStats(
  List<SleepRecord> records, {
  required int targetBedMin,
  required int goalDays,
  DateTime? now,
}) {
  final withBed = records
      .where((r) => r.status == 'complete' && r.bedTime != null)
      .toList();
  if (withBed.isEmpty) return const [];

  final today = dateOnly(now ?? DateTime.now());
  final first = withBed
      .map((r) => dateOnly(r.anchorDate))
      .reduce((a, b) => a.isBefore(b) ? a : b);
  var cursor = mondayOf(first);
  final current = mondayOf(today);
  final result = <WeekEarlyStats>[];

  while (!cursor.isAfter(current)) {
    final end = cursor.add(const Duration(days: 7));
    var count = 0;
    for (final r in withBed) {
      final d = dateOnly(r.anchorDate);
      if (d.isBefore(cursor) || !d.isBefore(end)) continue;
      if (normalizedBedMinutes(r.bedTime!) <= targetBedMin) count++;
    }
    result.add(WeekEarlyStats(
      weekStart: cursor,
      achievedDays: count,
      goalDays: goalDays,
    ));
    cursor = end;
  }
  return result;
}

/// 本周（周一至今）早睡达标天数。
int earlyDaysThisWeek(
  List<SleepRecord> records,
  DateTime now,
  int targetBedMin,
) {
  final start = mondayOf(now);
  final end = start.add(const Duration(days: 7));
  return records.where((r) {
    if (r.status != 'complete' || r.bedTime == null) return false;
    final d = dateOnly(r.anchorDate);
    return !d.isBefore(start) &&
        d.isBefore(end) &&
        normalizedBedMinutes(r.bedTime!) <= targetBedMin;
  }).length;
}

class WeekSummary {
  const WeekSummary({
    required this.weekStart,
    required this.completeDays,
    required this.avgDurationMin,
    required this.regularity,
    required this.bestDay,
    required this.bestDurationMin,
    required this.diffFromPreviousMin,
  });

  final DateTime weekStart;
  final int completeDays;
  final int avgDurationMin;
  final int? regularity;
  final DateTime? bestDay;
  final int? bestDurationMin;
  final int? diffFromPreviousMin;
}

/// 最近 N 周周报（只包含有完整记录的周，倒序）。
List<WeekSummary> weeklySummaries(
  List<SleepRecord> records, {
  DateTime? now,
  int weeks = 8,
}) {
  final today = dateOnly(now ?? DateTime.now());
  final complete = records
      .where((r) =>
          r.status == 'complete' &&
          r.durationMin != null &&
          r.wakeTime != null)
      .toList();
  final currentWeek = mondayOf(today);
  final result = <WeekSummary>[];

  List<SleepRecord> inWeek(DateTime start) {
    final end = start.add(const Duration(days: 7));
    return complete.where((r) {
      final d = dateOnly(r.anchorDate);
      return !d.isBefore(start) && d.isBefore(end);
    }).toList();
  }

  int? avgDuration(List<SleepRecord> recs) => recs.isEmpty
      ? null
      : (recs.map((r) => r.durationMin!).reduce((a, b) => a + b) /
              recs.length)
          .round();

  for (var i = 0; i < weeks; i++) {
    final start = currentWeek.subtract(Duration(days: 7 * i));
    final recs = inWeek(start);
    if (recs.isEmpty) continue;
    final avg = avgDuration(recs)!;
    final prevAvg = avgDuration(inWeek(start.subtract(const Duration(days: 7))));
    SleepRecord? best;
    for (final r in recs) {
      if (best == null || (r.durationMin ?? 0) > (best.durationMin ?? 0)) {
        best = r;
      }
    }
    result.add(WeekSummary(
      weekStart: start,
      completeDays: recs.length,
      avgDurationMin: avg,
      regularity: regularityScoreOf(recs),
      bestDay: best == null ? null : dateOnly(best.anchorDate),
      bestDurationMin: best?.durationMin,
      diffFromPreviousMin: prevAvg == null ? null : avg - prevAvg,
    ));
  }
  return result;
}

/// 解析 "HH:mm" 形式的早睡目标；默认 23:30。
int parseEarlyBedMinutes(String? raw) {
  if (raw == null) return 23 * 60 + 30;
  final parts = raw.split(':');
  if (parts.length != 2) return 23 * 60 + 30;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
    return 23 * 60 + 30;
  }
  final minutes = h * 60 + m;
  return minutes < 12 * 60 ? minutes + 24 * 60 : minutes;
}

/// 把 0~1440+ 的分钟数显示成 HH:mm（超过 24 点自动回绕）。
String formatClockMinutes(int minutes) {
  final m = minutes % (24 * 60);
  final h = m ~/ 60;
  final min = m % 60;
  return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
}

String formatDeltaMinutes(int? diff) {
  if (diff == null) return '首周';
  if (diff == 0) return '与上周持平';
  return diff > 0 ? '比上周多 $diff 分钟' : '比上周少 ${-diff} 分钟';
}
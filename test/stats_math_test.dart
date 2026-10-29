import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_checkin/data/database.dart';
import 'package:sleep_checkin/logic/stats_math.dart';

SleepRecord rec(
  DateTime anchor, {
  DateTime? bed,
  DateTime? wake,
  int? duration,
  int quality = 3,
  bool manual = false,
}) {
  final a = DateTime(anchor.year, anchor.month, anchor.day);
  final w = wake ?? (duration != null ? DateTime(a.year, a.month, a.day, 7) : null);
  final b = bed ??
      (w != null && duration != null ? w.subtract(Duration(minutes: duration)) : null);
  return SleepRecord(
    id: 0,
    anchorDate: a,
    bedTime: b,
    wakeTime: w,
    durationMin: duration ??
        (b != null && w != null ? w.difference(b).inMinutes : null),
    quality: quality,
    note: null,
    dream: null,
    isManual: manual,
    status: w != null ? 'complete' : 'bed_only',
    createdAt: a,
    updatedAt: a,
  );
}

void main() {
  group('normalizedBedMinutes', () {
    test('23:30 不跨零点', () {
      expect(normalizedBedMinutes(DateTime(2026, 10, 29, 23, 30)), 1410);
    });

    test('00:30 折算加 24 小时', () {
      expect(normalizedBedMinutes(DateTime(2026, 10, 30, 0, 30)), 1470);
    });
  });

  group('regularityScore', () {
    test('记录不足 3 条返回 null', () {
      final records = [
        rec(DateTime(2026, 10, 28), duration: 450),
        rec(DateTime(2026, 10, 29), duration: 450),
      ];
      expect(regularityScoreOf(records), isNull);
    });

    test('作息完全固定得 100 分', () {
      final records = [
        for (var i = 0; i < 7; i++)
          rec(
            DateTime(2026, 10, 1).add(Duration(days: i)),
            bed: DateTime(2026, 10, 1, 23, 30),
            wake: DateTime(2026, 10, 2, 7, 0),
            duration: 450,
          ),
      ];
      expect(regularityScoreOf(records), 100);
    });

    test('作息波动大分数明显下降', () {
      final records = <SleepRecord>[];
      for (var i = 0; i < 6; i++) {
        final evening = i.isEven;
        records.add(rec(
          DateTime(2026, 10, 1).add(Duration(days: i)),
          bed: evening
              ? DateTime(2026, 10, 1, 22, 0)
              : DateTime(2026, 10, 2, 2, 0),
          wake: evening
              ? DateTime(2026, 10, 2, 6, 0)
              : DateTime(2026, 10, 2, 10, 0),
        ));
      }
      final score = regularityScoreOf(records);
      expect(score, isNotNull);
      expect(score! < 70, isTrue);
    });
  });

  group('weeklySummaries', () {
    test('计算周平均与较上周差值', () {
      final now = DateTime(2026, 10, 29); // 周四，本周一为 10月26日
      final records = [
        rec(DateTime(2026, 10, 27), duration: 450, bed: DateTime(2026, 10, 26, 23, 30)),
        rec(DateTime(2026, 10, 20), duration: 400),
        rec(DateTime(2026, 10, 21), duration: 420),
      ];
      final weeks = weeklySummaries(records, now: now);
      expect(weeks.length, 2);
      expect(weeks.first.weekStart, DateTime(2026, 10, 26));
      expect(weeks.first.avgDurationMin, 450);
      expect(weeks.first.diffFromPreviousMin, 40);
      expect(weeks.last.weekStart, DateTime(2026, 10, 19));
      expect(weeks.last.diffFromPreviousMin, isNull);
    });
  });

  group('earlyWeekStats', () {
    test('达到每周目标天数即为达标周', () {
      final records = [
        rec(DateTime(2026, 10, 26), bed: DateTime(2026, 10, 26, 23, 0), duration: 450),
        rec(DateTime(2026, 10, 27), bed: DateTime(2026, 10, 27, 22, 30), duration: 450),
        rec(DateTime(2026, 10, 28), bed: DateTime(2026, 10, 29, 0, 30), duration: 450),
      ];
      final weeks = earlyWeekStats(
        records,
        targetBedMin: 1410,
        goalDays: 2,
        now: DateTime(2026, 10, 29),
      );
      expect(weeks.length, 1);
      expect(weeks.first.achievedDays, 2);
      expect(weeks.first.isStar, isTrue);
    });

    test('早睡目标解析支持跨零点', () {
      expect(parseEarlyBedMinutes('23:30'), 1410);
      expect(parseEarlyBedMinutes('00:30'), 1470);
      expect(parseEarlyBedMinutes(null), 1410);
      expect(parseEarlyBedMinutes('bad'), 1410);
    });
  });

  group('formatClockMinutes', () {
    test('跨零点自动回绕', () {
      expect(formatClockMinutes(1410), '23:30');
      expect(formatClockMinutes(1470), '00:30');
      expect(formatClockMinutes(1440), '00:00');
    });
  });
}
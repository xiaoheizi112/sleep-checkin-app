import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_checkin/data/database.dart';
import 'package:sleep_checkin/logic/sleep_assessment.dart';

DateTime d(int year, int month, int day) => DateTime(year, month, day);

SleepRecord rec(
  DateTime anchor, {
  required int bedHour,
  required int bedMinute,
  required int wakeHour,
  required int wakeMinute,
  int quality = 4,
  bool manual = false,
}) {
  final a = DateTime(anchor.year, anchor.month, anchor.day);
  var bed = DateTime(a.year, a.month, a.day, bedHour, bedMinute);
  final wake = DateTime(a.year, a.month, a.day, wakeHour, wakeMinute);
  if (!bed.isBefore(wake)) {
    bed = bed.subtract(const Duration(days: 1));
  }
  return SleepRecord(
    id: 0,
    anchorDate: a,
    bedTime: bed,
    wakeTime: wake,
    durationMin: wake.difference(bed).inMinutes,
    quality: quality,
    note: null,
    dream: null,
    isManual: manual,
    status: 'complete',
    createdAt: a,
    updatedAt: a,
  );
}

void main() {
  final now = d(2026, 10, 29);

  test('没有记录时提示先积累数据', () {
    final result = assessSleep([], now: now);
    expect(result.hasEnoughData, isFalse);
    expect(result.score, 0);
    expect(result.grade, '数据不足');
    expect(result.suggestions, isNotEmpty);
  });

  test('作息稳定的记录得到高分和正向结论', () {
    final records = [
      for (var i = 0; i < 7; i++)
        rec(
          d(2026, 10, 23).add(Duration(days: i)),
          bedHour: 23,
          bedMinute: 0,
          wakeHour: 7,
          wakeMinute: 0,
          quality: 4,
        ),
    ];
    final result = assessSleep(records, now: now);
    expect(result.hasEnoughData, isTrue);
    expect(result.score, greaterThanOrEqualTo(85));
    expect(result.grade, '优秀');
    expect(result.findings.any((f) => f.positive), isTrue);
    expect(result.score, inInclusiveRange(0, 100));
  });

  test('晚睡且时长短时能识别问题并给出建议', () {
    final records = [
      for (var i = 0; i < 7; i++)
        rec(
          d(2026, 10, 23).add(Duration(days: i)),
          bedHour: 1,
          bedMinute: 30,
          wakeHour: 7,
          wakeMinute: 0,
          quality: 2,
        ),
    ];
    final result = assessSleep(records, now: now);
    final titles = result.findings.map((f) => f.title).toList();
    expect(titles, contains('睡眠时长偏短'));
    expect(titles, contains('入睡时间偏晚'));
    expect(titles, contains('主观质量偏低'));
    expect(result.suggestions.length, greaterThan(2));
    expect(result.score, inInclusiveRange(0, 100));
  });

  test('识别周末作息漂移', () {
    final records = <SleepRecord>[];
    for (var i = 0; i < 14; i++) {
      final day = d(2026, 10, 16).add(Duration(days: i));
      final weekend = day.weekday >= 6;
      records.add(rec(
        day,
        bedHour: weekend ? 2 : 23,
        bedMinute: weekend ? 30 : 30,
        wakeHour: weekend ? 10 : 6,
        wakeMinute: 30,
        quality: weekend ? 3 : 4,
      ));
    }
    final result = assessSleep(records, now: now);
    expect(
      result.findings.map((f) => f.title),
      contains('周末作息漂移'),
    );
    expect(result.findings.map((f) => f.title), contains('作息波动较大'));
  });

  test('记录 4 天时标记样本较少但仍给出分数', () {
    final records = [
      for (var i = 0; i < 4; i++)
        rec(
          d(2026, 10, 26).add(Duration(days: i)),
          bedHour: 23,
          bedMinute: 30,
          wakeHour: 7,
          wakeMinute: 0,
        ),
    ];
    final result = assessSleep(records, now: now);
    expect(result.hasEnoughData, isFalse);
    expect(result.grade, '样本较少');
    expect(result.score, greaterThan(0));
    expect(result.score, inInclusiveRange(0, 100));
  });
}
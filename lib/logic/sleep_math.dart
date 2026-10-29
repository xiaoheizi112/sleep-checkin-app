import '../data/database.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String weekdayZh(DateTime d) =>
    const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][d.weekday - 1];

String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String formatDuration(int? minutes) {
  if (minutes == null) return '—';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m 分钟';
  return m == 0 ? '$h 小时' : '$h 小时 $m 分';
}

/// 根据起床日（anchor）和两个时刻计算具体入睡/起床时间与时长。
/// 入睡时刻不早于起床时刻时，视为前一天晚上入睡。
({DateTime bed, DateTime wake, int minutes}) sleepWindow(
  DateTime anchorDate, {
  required int bedHour,
  required int bedMinute,
  required int wakeHour,
  required int wakeMinute,
}) {
  final anchor = dateOnly(anchorDate);
  final wake =
      DateTime(anchor.year, anchor.month, anchor.day, wakeHour, wakeMinute);
  var bed =
      DateTime(anchor.year, anchor.month, anchor.day, bedHour, bedMinute);
  if (!bed.isBefore(wake)) {
    bed = bed.subtract(const Duration(days: 1));
  }
  return (bed: bed, wake: wake, minutes: wake.difference(bed).inMinutes);
}

/// 一条睡眠记录的合理时长范围：10 分钟到 16 小时。
bool isValidSleepDuration(int minutes) => minutes >= 10 && minutes <= 16 * 60;

/// 睡前打卡的归属日期：18 点之后算作第二天（醒来那天）。
DateTime bedAnchorDate(DateTime now) {
  if (now.hour >= 18) return dateOnly(now).add(const Duration(days: 1));
  return dateOnly(now);
}

Set<DateTime> completedDaysOf(Iterable<SleepRecord> records) => records
    .where((r) => r.status == 'complete')
    .map((r) => dateOnly(r.anchorDate))
    .toSet();

/// 当前连续打卡天数：从今天往前数，今天没打则从昨天起算。
int currentStreak(Set<DateTime> days, DateTime today) {
  var cursor = dateOnly(today);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// 历史最长连续打卡天数。
int bestStreak(Set<DateTime> days) {
  if (days.isEmpty) return 0;
  final sorted = days.toList()..sort();
  var best = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final diff = sorted[i].difference(sorted[i - 1]).inDays;
    if (diff == 1) {
      run++;
      if (run > best) best = run;
    } else {
      run = 1;
    }
  }
  return best;
}
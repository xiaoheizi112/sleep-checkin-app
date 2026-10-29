import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_checkin/logic/sleep_math.dart';

DateTime d(int year, int month, int day) => DateTime(year, month, day);

void main() {
  group('bedAnchorDate', () {
    test('18 点后打卡归属第二天', () {
      expect(bedAnchorDate(DateTime(2026, 10, 29, 23, 10)), d(2026, 10, 30));
    });

    test('凌晨打卡归属当天', () {
      expect(bedAnchorDate(DateTime(2026, 10, 30, 1, 20)), d(2026, 10, 30));
    });

    test('傍晚前打卡归属当天', () {
      expect(bedAnchorDate(DateTime(2026, 10, 29, 17, 59)), d(2026, 10, 29));
    });
  });

  group('currentStreak', () {
    test('今天已打卡时从今天往前数', () {
      final days = {d(2026, 10, 27), d(2026, 10, 28), d(2026, 10, 29)};
      expect(currentStreak(days, d(2026, 10, 29)), 3);
    });

    test('今天未打卡但从昨天连续，仍计数', () {
      final days = {d(2026, 10, 27), d(2026, 10, 28)};
      expect(currentStreak(days, d(2026, 10, 29)), 2);
    });

    test('断签之后清零', () {
      final days = {d(2026, 10, 26)};
      expect(currentStreak(days, d(2026, 10, 29)), 0);
    });
  });

  group('bestStreak', () {
    test('空集合返回 0', () {
      expect(bestStreak({}), 0);
    });

    test('跨断档取最长连续段', () {
      final days = {
        d(2026, 10, 1),
        d(2026, 10, 2),
        d(2026, 10, 3),
        d(2026, 10, 10),
        d(2026, 10, 11),
      };
      expect(bestStreak(days), 3);
    });

    test('单日返回 1', () {
      expect(bestStreak({d(2026, 10, 29)}), 1);
    });
  });

  group('格式化', () {
    test('formatDuration', () {
      expect(formatDuration(null), '—');
      expect(formatDuration(45), '45 分钟');
      expect(formatDuration(420), '7 小时');
      expect(formatDuration(445), '7 小时 25 分');
    });

    test('weekdayZh', () {
      expect(weekdayZh(d(2026, 10, 26)), '周一');
      expect(weekdayZh(d(2026, 11, 1)), '周日');
    });
  });

  group('sleepWindow', () {
    test('23:30 入睡、07:00 起床归到前一天晚上', () {
      final w = sleepWindow(
        d(2026, 10, 29),
        bedHour: 23,
        bedMinute: 30,
        wakeHour: 7,
        wakeMinute: 0,
      );
      expect(w.bed, DateTime(2026, 10, 28, 23, 30));
      expect(w.wake, DateTime(2026, 10, 29, 7, 0));
      expect(w.minutes, 450);
    });

    test('01:30 入睡、09:00 起床属于当天凌晨', () {
      final w = sleepWindow(
        d(2026, 10, 29),
        bedHour: 1,
        bedMinute: 30,
        wakeHour: 9,
        wakeMinute: 0,
      );
      expect(w.bed, DateTime(2026, 10, 29, 1, 30));
      expect(w.wake, DateTime(2026, 10, 29, 9, 0));
      expect(w.minutes, 450);
    });
  });

  group('isValidSleepDuration', () {
    test('边界值', () {
      expect(isValidSleepDuration(9), isFalse);
      expect(isValidSleepDuration(10), isTrue);
      expect(isValidSleepDuration(16 * 60), isTrue);
      expect(isValidSleepDuration(16 * 60 + 1), isFalse);
    });
  });
}
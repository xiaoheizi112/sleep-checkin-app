import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../logic/badges.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _bedReminderId = 1001;
  static const _wakeReminderId = 1002;
  static bool _timeZoneReady = false;

  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    await _ensureTimeZone();
  }

  static Future<void> _ensureTimeZone() async {
    if (_timeZoneReady) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // 拿不到系统时区时按中国时区排期，保证提醒仍然可用。
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    }
    _timeZoneReady = true;
  }

  static Future<bool> requestPermission() async {
    try {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    } catch (_) {
      // 测试环境或用户拒绝授权时静默处理，站内弹窗仍然可见。
      return false;
    }
  }

  /// 取消旧排期，按当前设置重新安排每天的睡前/起床提醒。
  static Future<void> scheduleReminders({
    required bool bedEnabled,
    required int bedMinutes,
    required bool wakeEnabled,
    required int wakeMinutes,
  }) async {
    try {
      await _ensureTimeZone();
      await _plugin.cancel(id: _bedReminderId);
      await _plugin.cancel(id: _wakeReminderId);
      if (bedEnabled) {
        await _scheduleDaily(
          id: _bedReminderId,
          hour: bedMinutes ~/ 60 % 24,
          minute: bedMinutes % 60,
          title: '该准备睡觉了',
          body: '到点啦，点一下记录入睡时间。',
        );
      }
      if (wakeEnabled) {
        await _scheduleDaily(
          id: _wakeReminderId,
          hour: wakeMinutes ~/ 60 % 24,
          minute: wakeMinutes % 60,
          title: '早上好，记得打卡',
          body: '记录起床时间，顺手给昨晚打个分。',
        );
      }
    } catch (_) {
      // 排期失败不影响 App 使用。
    }
  }

  static Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          '打卡提醒',
          channelDescription: '每天睡前与起床打卡提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showBadgeUnlocked(BadgeDef badge) async {
    try {
      const details = AndroidNotificationDetails(
        'badges',
        '徽章解锁',
        channelDescription: '连续打卡与里程碑徽章解锁提醒',
        importance: Importance.high,
        priority: Priority.high,
      );
      await _plugin.show(
        id: badge.key.hashCode,
        title: '解锁徽章：${badge.name}',
        body: badge.description,
        notificationDetails: const NotificationDetails(android: details),
      );
    } catch (_) {
      // 通知失败不影响站内庆祝。
    }
  }
}
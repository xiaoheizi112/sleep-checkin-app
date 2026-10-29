import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../logic/badges.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
  }

  static Future<void> requestPermission() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // 测试环境或用户拒绝授权时静默处理，站内弹窗仍然可见。
    }
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
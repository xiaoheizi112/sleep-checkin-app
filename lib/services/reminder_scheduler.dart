import '../data/database.dart';
import '../logic/setting_keys.dart';
import '../logic/stats_math.dart';
import 'notification_service.dart';

/// 从设置表读取提醒配置并同步到本地通知。
class ReminderScheduler {
  ReminderScheduler._();

  static Future<void> sync(AppDatabase db) async {
    final settings = await db.allSettingsMap();
    await NotificationService.scheduleReminders(
      bedEnabled: (settings[SettingKeys.reminderBedEnabled] ?? '1') == '1',
      bedMinutes:
          parseClockMinutes(settings[SettingKeys.reminderBedTime], fallback: 23 * 60),
      wakeEnabled: (settings[SettingKeys.reminderWakeEnabled] ?? '1') == '1',
      wakeMinutes:
          parseClockMinutes(settings[SettingKeys.reminderWakeTime], fallback: 7 * 60),
    );
  }
}
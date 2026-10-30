import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../logic/sleep_math.dart';
import '../logic/stats_math.dart';
import '../providers.dart';
import '../services/notification_service.dart';
import '../services/reminder_scheduler.dart';
import '../theme/app_colors.dart';
import 'badges_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(targetDurationProvider);
    final earlyBed = ref.watch(earlyBedMinutesProvider);
    final goalDays = ref.watch(weeklyGoalDaysProvider);
    final records =
        ref.watch(recordsProvider).value ?? const <SleepRecord>[];
    final best = bestStreak(completedDaysOf(records));
    final badges = ref.watch(badgesProvider).value ?? const <UnlockedBadge>[];
    final bedReminderOn = ref.watch(reminderBedEnabledProvider);
    final bedReminderMinutes = ref.watch(reminderBedMinutesProvider);
    final wakeReminderOn = ref.watch(reminderWakeEnabledProvider);
    final wakeReminderMinutes = ref.watch(reminderWakeMinutesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Card(
            title: '睡眠目标',
            children: [
              _TargetDurationSlider(
                key: ValueKey('target-$target'),
                initialMinutes: target,
                onSave: (minutes) => ref
                    .read(databaseProvider)
                    .setSetting(SettingKeys.targetDurationMin, '$minutes'),
              ),
              const SizedBox(height: 4),
              const Divider(),
              _EarlyBedRow(
                initialMinutes: earlyBed,
                onSave: (time) => ref.read(databaseProvider).setSetting(
                      SettingKeys.earlyBedTime,
                      '${time.hour.toString().padLeft(2, '0')}:'
                          '${time.minute.toString().padLeft(2, '0')}',
                    ),
              ),
              _WeeklyGoalSlider(
                key: ValueKey('goal-$goalDays'),
                initialDays: goalDays,
                onSave: (days) => ref
                    .read(databaseProvider)
                    .setSetting(SettingKeys.weeklyGoalDays, '$days'),
              ),
              const SizedBox(height: 4),
              Text(
                '达到达标时长记录显示为绿色；早睡目标用于首页进度与徽章判定',
                style: TextStyle(fontSize: 12, color: context.appColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Card(
            title: '打卡提醒',
            children: [
              _ReminderRow(
                icon: Icons.nightlight_round,
                title: '睡前提醒',
                minutes: bedReminderMinutes,
                enabled: bedReminderOn,
                onToggle: (value) => _toggleReminder(
                  context,
                  ref,
                  SettingKeys.reminderBedEnabled,
                  value,
                ),
                onPickTime: () => _pickReminderTime(
                  context,
                  ref,
                  helpText: '睡前提醒时间',
                  initialMinutes: bedReminderMinutes,
                  settingKey: SettingKeys.reminderBedTime,
                ),
              ),
              const Divider(),
              _ReminderRow(
                icon: Icons.wb_sunny_rounded,
                title: '起床提醒',
                minutes: wakeReminderMinutes,
                enabled: wakeReminderOn,
                onToggle: (value) => _toggleReminder(
                  context,
                  ref,
                  SettingKeys.reminderWakeEnabled,
                  value,
                ),
                onPickTime: () => _pickReminderTime(
                  context,
                  ref,
                  helpText: '起床提醒时间',
                  initialMinutes: wakeReminderMinutes,
                  settingKey: SettingKeys.reminderWakeTime,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '本地通知，每天重复；修改后立即生效。',
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Card(
            title: '成就',
            children: [
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BadgesScreen()),
                ),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        color: context.appColors.moonGold,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '徽章墙',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '已点亮 ${badges.length} / 12',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: context.appColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Card(
            title: '数据',
            children: [
              _InfoRow(label: '最长连续打卡', value: '$best 天'),
              const SizedBox(height: 12),
              const _InfoRow(label: '数据存储', value: '仅本机'),
              const SizedBox(height: 10),
              const Divider(),
              _BackupRow(
                icon: Icons.upload_file_rounded,
                title: '导出备份',
                subtitle: '保存为 JSON 文件，换机或重装前使用',
                onTap: () => _export(context, ref),
              ),
              _BackupRow(
                icon: Icons.download_rounded,
                title: '导入恢复',
                subtitle: '选择 JSON 备份，覆盖当前所有数据',
                onTap: () => _import(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Card(
            title: '关于',
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.appColors.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.nightlight_round,
                      color: context.appColors.moonGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '睡眠打卡',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'v0.6.0 · 提醒与动效',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '数据只保存在本机，不联网、不上传。',
                style: TextStyle(fontSize: 12, color: context.appColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReminder(
    BuildContext context,
    WidgetRef ref,
    String settingKey,
    bool enabled,
  ) async {
    final db = ref.read(databaseProvider);
    await db.setSetting(settingKey, enabled ? '1' : '0');
    if (enabled) {
      final granted = await NotificationService.requestPermission();
      if (!granted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('通知权限未开启，提醒可能不会显示')),
        );
      }
    }
    await ReminderScheduler.sync(db);
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref, {
    required String helpText,
    required int initialMinutes,
    required String settingKey,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialMinutes ~/ 60 % 24,
        minute: initialMinutes % 60,
      ),
      helpText: helpText,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    final db = ref.read(databaseProvider);
    await db.setSetting(
      settingKey,
      '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}',
    );
    await ReminderScheduler.sync(db);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await ref.read(backupServiceProvider).exportToFile();
      messenger.showSnackBar(
        SnackBar(content: Text(saved ? '备份已导出' : '已取消导出')),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('导出失败：$error')));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入备份'),
        content: const Text('导入会覆盖当前所有睡眠记录、设置和徽章，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.appColors.danger),
            child: const Text('继续导入'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final count = await ref.read(backupServiceProvider).importFromFile();
      messenger.showSnackBar(
        SnackBar(content: Text(count >= 0 ? '已恢复 $count 条记录' : '已取消导入')),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('导入失败：$error')));
    }
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.appColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.appColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: context.appColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetDurationSlider extends StatefulWidget {
  const _TargetDurationSlider({
    super.key,
    required this.initialMinutes,
    required this.onSave,
  });

  final int initialMinutes;
  final Future<void> Function(int minutes) onSave;

  @override
  State<_TargetDurationSlider> createState() => _TargetDurationSliderState();
}

class _TargetDurationSliderState extends State<_TargetDurationSlider> {
  late int _minutes = widget.initialMinutes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('每晚达标时长', style: TextStyle(fontSize: 13)),
            const Spacer(),
            Text(
              '${(_minutes / 60).toStringAsFixed(1)} 小时',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.appColors.moonGold,
              ),
            ),
          ],
        ),
        Slider(
          value: _minutes / 60,
          min: 4,
          max: 12,
          divisions: 16,
          activeColor: context.appColors.moonGold,
          inactiveColor: context.appColors.inactive,
          onChanged: (v) => setState(() => _minutes = (v * 60).round()),
          onChangeEnd: (v) => widget.onSave(_minutes),
        ),
      ],
    );
  }
}

class _EarlyBedRow extends StatelessWidget {
  const _EarlyBedRow({required this.initialMinutes, required this.onSave});

  final int initialMinutes;
  final Future<void> Function(TimeOfDay time) onSave;

  @override
  Widget build(BuildContext context) {
    final minutes = initialMinutes % (24 * 60);
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          helpText: '早睡目标时间',
        );
        if (picked != null) await onSave(picked);
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Text('早睡目标', style: TextStyle(fontSize: 13)),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.appColors.moonGold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.schedule,
              size: 16,
              color: context.appColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyGoalSlider extends StatefulWidget {
  const _WeeklyGoalSlider({
    super.key,
    required this.initialDays,
    required this.onSave,
  });

  final int initialDays;
  final Future<void> Function(int days) onSave;

  @override
  State<_WeeklyGoalSlider> createState() => _WeeklyGoalSliderState();
}

class _WeeklyGoalSliderState extends State<_WeeklyGoalSlider> {
  late int _days = widget.initialDays;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('每周早睡达标天数', style: TextStyle(fontSize: 13)),
            const Spacer(),
            Text(
              '$_days 天',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.appColors.moonGold,
              ),
            ),
          ],
        ),
        Slider(
          value: _days.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          activeColor: context.appColors.moonGold,
          inactiveColor: context.appColors.inactive,
          onChanged: (v) => setState(() => _days = v.round()),
          onChangeEnd: (v) => widget.onSave(_days),
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.icon,
    required this.title,
    required this.minutes,
    required this.enabled,
    required this.onToggle,
    required this.onPickTime,
  });

  final IconData icon;
  final String title;
  final int minutes;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: enabled
                ? context.appColors.moonGold
                : context.appColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 3),
                InkWell(
                  onTap: enabled ? onPickTime : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          enabled
                              ? '每天 ${formatClockMinutes(minutes)}'
                              : '已关闭',
                          style: TextStyle(
                            fontSize: 12,
                            color: enabled
                                ? context.appColors.moonGold
                                : context.appColors.textSecondary,
                          ),
                        ),
                        if (enabled) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: context.appColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onToggle),
        ],
      ),
    );
  }
}
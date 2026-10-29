import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../logic/sleep_math.dart';
import '../logic/stats_math.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_celebration.dart';
import '../widgets/star_rating.dart';

enum _Phase { sleep, bedDone, wake, done }

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final records = recordsAsync.value ?? const <SleepRecord>[];
    final today = dateOnly(now);
    final byDate = <String, SleepRecord>{
      for (final r in records) dayKey(r.anchorDate): r,
    };
    final todayRec = byDate[dayKey(today)];
    final tomorrowRec = byDate[dayKey(today.add(const Duration(days: 1)))];
    final earlyBed = ref.watch(earlyBedMinutesProvider);
    final goalDays = ref.watch(weeklyGoalDaysProvider);
    final earlyDays = earlyDaysThisWeek(records, today, earlyBed);

    final _Phase phase;
    SleepRecord? activeBed;
    if (todayRec != null && todayRec.status == 'complete') {
      phase = _Phase.done;
      activeBed = todayRec;
    } else if (todayRec != null &&
        todayRec.status == 'bed_only' &&
        now.hour >= 4) {
      phase = _Phase.wake;
      activeBed = todayRec;
    } else if (tomorrowRec != null && tomorrowRec.status == 'bed_only') {
      phase = _Phase.bedDone;
      activeBed = tomorrowRec;
    } else if (todayRec != null && todayRec.status == 'bed_only') {
      phase = _Phase.bedDone;
      activeBed = todayRec;
    } else if (now.hour >= 18 || now.hour < 4) {
      phase = _Phase.sleep;
    } else {
      phase = _Phase.wake;
    }

    final completedDays = completedDaysOf(records);
    final streak = currentStreak(completedDays, today);
    final best = bestStreak(completedDays);

    SleepRecord? latestComplete;
    for (final r in records) {
      if (r.status == 'complete' && r.durationMin != null) {
        latestComplete = r;
        break;
      }
    }

    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = monday.add(const Duration(days: 7));
    final weekRecords = records.where((r) {
      final d = dateOnly(r.anchorDate);
      return r.status == 'complete' &&
          r.durationMin != null &&
          !d.isBefore(monday) &&
          d.isBefore(weekEnd);
    }).toList();
    final weekAvg = weekRecords.isEmpty
        ? null
        : (weekRecords.fold<int>(0, (sum, r) => sum + (r.durationMin ?? 0)) /
                weekRecords.length)
            .round();

    Future<void> handlePrimaryTap() async {
      final db = ref.read(databaseProvider);
      switch (phase) {
        case _Phase.sleep:
          await db.startBedCheckIn(DateTime.now());
          if (context.mounted) {
            await checkBadgesAndCelebrate(context, ref);
          }
          break;
        case _Phase.wake:
          final wakeNow = DateTime.now();
          final bedTime = activeBed?.bedTime ?? _defaultBedTime(wakeNow);
          if (!context.mounted) return;
          final saved = await showWakeSheet(
            context,
            anchorDate: dateOnly(wakeNow),
            bedTime: bedTime,
            wakeTime: wakeNow,
          );
          if (saved == true && context.mounted) {
            await checkBadgesAndCelebrate(context, ref);
          }
          break;
        default:
          break;
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(now.hour),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${now.month}月${now.day}日 · ${weekdayZh(now)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Theme.of(context).brightness == Brightness.light
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: Theme.of(context).brightness == Brightness.light
                      ? context.appColors.dawnOrange
                      : context.appColors.moonGold.withValues(alpha: 0.75),
                  size: 26,
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPrimaryButton(
                      phase, activeBed, handlePrimaryTap, context.appColors),
                      if (phase == _Phase.bedDone && activeBed != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton(
                            onPressed: () => ref
                                .read(databaseProvider)
                                .deleteRecord(activeBed!.id),
                            child: Text(
                              '撤销本次打卡',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _OverviewCard(
              lastNight: formatDuration(latestComplete?.durationMin),
              weekAvg: formatDuration(weekAvg),
              streak: streak,
              best: best,
              earlyDays: earlyDays,
              goalDays: goalDays,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    _Phase phase,
    SleepRecord? rec,
    VoidCallback onTap,
    AppPalette palette,
  ) {
    switch (phase) {
      case _Phase.sleep:
        return _CheckInButton(
          icon: Icons.nightlight_round,
          title: '我要睡了',
          subtitle: '点一下记录入睡时间',
          gradient: [palette.moonGold, const Color(0xFFC99A55)],
          foreground: palette.onAccent,
          glow: palette.moonGold,
          onTap: onTap,
        );
      case _Phase.wake:
        return _CheckInButton(
          icon: Icons.wb_sunny_rounded,
          title: '我醒了',
          subtitle: rec?.bedTime != null
              ? '已记录入睡 ${formatTime(rec!.bedTime!)}'
              : '记录起床时间，可补全昨晚入睡时间',
          gradient: [palette.dawnOrange, const Color(0xFFD98A45)],
          foreground: palette.onAccent,
          glow: palette.dawnOrange,
          onTap: onTap,
        );
      case _Phase.bedDone:
        return _CheckInButton(
          icon: Icons.nightlight_round,
          title: rec?.bedTime != null
              ? '已打卡 ${formatTime(rec!.bedTime!)}'
              : '已打卡',
          subtitle: '晚安，明早点「我醒了」',
          foreground: palette.moonGold,
          iconColor: palette.moonGold,
          onTap: null,
        );
      case _Phase.done:
        return _CheckInButton(
          icon: Icons.check_circle_rounded,
          title: '今日已记录',
          subtitle: rec?.bedTime != null && rec?.wakeTime != null
              ? '${formatTime(rec!.bedTime!)} → ${formatTime(rec.wakeTime!)} · ${formatDuration(rec.durationMin)}'
              : '今天已完成打卡',
          foreground: palette.textPrimary,
          iconColor: palette.success,
          onTap: null,
        );
    }
  }
}

String _greeting(int hour) {
  if (hour >= 5 && hour < 11) return '早上好';
  if (hour >= 11 && hour < 14) return '中午好';
  if (hour >= 14 && hour < 18) return '下午好';
  if (hour >= 18 && hour < 23) return '晚上好';
  return '夜深了';
}

DateTime _defaultBedTime(DateTime wake) {
  final bed = DateTime(wake.year, wake.month, wake.day, 23, 30);
  return bed.isBefore(wake) ? bed : bed.subtract(const Duration(days: 1));
}

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.foreground,
    this.gradient,
    this.iconColor,
    this.glow,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color foreground;
  final List<Color>? gradient;
  final Color? iconColor;
  final Color? glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = gradient != null;
    return Container(
      width: 212,
      height: 212,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active
            ? LinearGradient(
                colors: gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: active ? null : context.appColors.surface,
        border: active ? null : Border.all(color: context.appColors.inactive),
        boxShadow: glow == null
            ? null
            : [
                BoxShadow(
                  color: glow!.withValues(alpha: 0.22),
                  blurRadius: 34,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 46, color: iconColor ?? foreground),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: foreground.withValues(alpha: 0.62),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.lastNight,
    required this.weekAvg,
    required this.streak,
    required this.best,
    required this.earlyDays,
    required this.goalDays,
  });

  final String lastNight;
  final String weekAvg;
  final int streak;
  final int best;
  final int earlyDays;
  final int goalDays;

  @override
  Widget build(BuildContext context) {
    final isStar = earlyDays >= goalDays;
    final progress =
        goalDays <= 0 ? 0.0 : (earlyDays.clamp(0, goalDays) / goalDays);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Metric(label: '上次睡眠', value: lastNight),
              _Metric(label: '本周平均', value: weekAvg),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          Row(
            children: [
              _Metric(label: '连续打卡', value: '$streak 天'),
              _Metric(label: '最长记录', value: '$best 天'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          Row(
            children: [
              Text(
                '本周早睡',
                style: TextStyle(fontSize: 12, color: context.appColors.textSecondary),
              ),
              const Spacer(),
              if (isStar) ...[
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: context.appColors.moonGold,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                '$earlyDays/$goalDays 天',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isStar ? context.appColors.moonGold : context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: context.appColors.inactive.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(context.appColors.moonGold),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showWakeSheet(
  BuildContext context, {
  required DateTime anchorDate,
  required DateTime bedTime,
  required DateTime wakeTime,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _WakeSheet(
      anchorDate: anchorDate,
      bedTime: bedTime,
      wakeTime: wakeTime,
    ),
  );
}

class _WakeSheet extends ConsumerStatefulWidget {
  const _WakeSheet({
    required this.anchorDate,
    required this.bedTime,
    required this.wakeTime,
  });

  final DateTime anchorDate;
  final DateTime bedTime;
  final DateTime wakeTime;

  @override
  ConsumerState<_WakeSheet> createState() => _WakeSheetState();
}

class _WakeSheetState extends ConsumerState<_WakeSheet> {
  int _quality = 3;
  bool _saving = false;
  late TimeOfDay _bedTod;
  late TimeOfDay _wakeTod;
  final _dreamController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bedTod = TimeOfDay.fromDateTime(widget.bedTime);
    _wakeTod = TimeOfDay.fromDateTime(widget.wakeTime);
  }

  @override
  void dispose() {
    _dreamController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  ({DateTime bed, DateTime wake, int minutes}) get _window => sleepWindow(
        widget.anchorDate,
        bedHour: _bedTod.hour,
        bedMinute: _bedTod.minute,
        wakeHour: _wakeTod.hour,
        wakeMinute: _wakeTod.minute,
      );

  Future<void> _pickTime({required bool isBed}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBed ? _bedTod : _wakeTod,
      helpText: isBed ? '入睡时间' : '起床时间',
    );
    if (picked == null) return;
    setState(() {
      if (isBed) {
        _bedTod = picked;
      } else {
        _wakeTod = picked;
      }
    });
  }

  Future<void> _save() async {
    final window = _window;
    if (!isValidSleepDuration(window.minutes)) return;
    setState(() => _saving = true);
    final dream = _dreamController.text.trim();
    final note = _noteController.text.trim();
    await ref.read(databaseProvider).completeWake(
          anchorDate: widget.anchorDate,
          bedTime: window.bed,
          wakeTime: window.wake,
          quality: _quality,
          dream: dream.isEmpty ? null : dream,
          note: note.isEmpty ? null : note,
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final window = _window;
    final valid = isValidSleepDuration(window.minutes);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.inactive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '本次睡眠',
              style: TextStyle(fontSize: 13, color: c.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              formatDuration(window.minutes),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SheetTimeField(
                    label: '入睡时间',
                    time: _bedTod,
                    onTap: () => _pickTime(isBed: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetTimeField(
                    label: '起床时间',
                    time: _wakeTod,
                    onTap: () => _pickTime(isBed: false),
                  ),
                ),
              ],
            ),
            if (!valid) ...[
              const SizedBox(height: 8),
              Text(
                '时长看起来不对，请检查入睡和起床时间',
                style: TextStyle(fontSize: 12, color: c.danger),
              ),
            ],
            const SizedBox(height: 18),
            Center(
              child: StarRating(
                value: _quality,
                size: 34,
                onChanged: (v) => setState(() => _quality = v),
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _dreamController,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: '记一句梦（可选）',
                hintText: '醒来还记得的那个梦…',
                filled: true,
                fillColor: c.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: '备注（可选）',
                hintText: '咖啡、运动、身体感受…',
                filled: true,
                fillColor: c.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: (_saving || !valid) ? null : _save,
              child: Text(_saving ? '保存中…' : '保存打卡'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTimeField extends StatelessWidget {
  const _SheetTimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: c.textSecondary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.schedule, size: 14, color: c.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
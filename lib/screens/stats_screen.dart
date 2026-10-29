import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/database.dart';
import '../logic/sleep_assessment.dart';
import '../logic/sleep_math.dart';
import '../logic/stats_math.dart';
import '../providers.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_celebration.dart';
import '../widgets/star_rating.dart';
import '../widgets/trend_charts.dart';
import 'assessment_screen.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime _selectedDay = dateOnly(DateTime.now());
  DateTime _focusedDay = DateTime.now();
  int _trendDays = 7;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(recordsProvider).value ?? const <SleepRecord>[];
    final target = ref.watch(targetDurationProvider);
    final earlyBed = ref.watch(earlyBedMinutesProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final byDate = <String, SleepRecord>{
      for (final r in records) dayKey(r.anchorDate): r,
    };
    final rec = byDate[dayKey(_selectedDay)];
    final today = dateOnly(now);
    final score = regularityScore(records, now: now);
    final monthStats = computeWindowStats(records, now, days: 30);
    final weeks = weeklySummaries(records, now: now);
    final assessment = assessSleep(
      records,
      now: now,
      targetDurationMin: target,
      earlyBedMinutes: earlyBed,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildCalendarCard(byDate, target, today),
          const SizedBox(height: 16),
          _buildDetailCard(rec),
          const SizedBox(height: 16),
          _buildAssessmentCard(assessment),
          const SizedBox(height: 16),
          _buildTrendCard(records, now, target),
          const SizedBox(height: 16),
          _buildRegularityCard(score),
          const SizedBox(height: 16),
          _buildMetricsCard(monthStats, score),
          const SizedBox(height: 16),
          _buildWeeklyCard(weeks),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(SleepAssessment assessment) {
    final c = context.appColors;
    final hint = assessment.hasEnoughData
        ? '${assessment.grade} · 近 ${assessment.windowDays} 天记录 ${assessment.sampleDays} 天'
        : (assessment.sampleDays == 0
            ? '连续记录 5 天后生成评估'
            : '已记录 ${assessment.sampleDays} 天，满 5 天后更准确');
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AssessmentScreen()),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, size: 20, color: c.moonGold),
                const SizedBox(width: 8),
                const Text(
                  '睡眠质量测评',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  assessment.sampleDays == 0 ? '—' : '${assessment.score}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: c.moonGold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 2),
                  child: Text(
                    ' 分',
                    style: TextStyle(fontSize: 11, color: c.textSecondary),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: c.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
            if (assessment.findings.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                assessment.findings.first.title,
                style: TextStyle(
                  fontSize: 12,
                  color: assessment.findings.first.positive
                      ? c.success
                      : c.warning,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '查看完整分析与建议 →',
              style: TextStyle(fontSize: 12, color: c.moonGold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(
    Map<String, SleepRecord> byDate,
    int target,
    DateTime today,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TableCalendar(
            locale: 'zh_CN',
            firstDay: DateTime(2024, 1, 1),
            lastDay: today.add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDate(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = dateOnly(selected);
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: '月'},
            startingDayOfWeek: StartingDayOfWeek.monday,
            daysOfWeekHeight: 30,
            rowHeight: 46,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                size: 22,
                color: context.appColors.textSecondary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                size: 22,
                color: context.appColors.textSecondary,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 12,
                color: context.appColors.textSecondary,
              ),
              weekendStyle: TextStyle(
                fontSize: 12,
                color: context.appColors.textSecondary,
              ),
            ),
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, byDate, target),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _LegendDot(color: context.appColors.success, label: '达标'),
              _LegendDot(color: context.appColors.warning, label: '时长不足'),
              _LegendHollow(label: '只打睡前卡'),
              _LegendDot(color: context.appColors.inactive, label: '未打卡'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    Map<String, SleepRecord> byDate,
    int targetMinutes,
  ) {
    final rec = byDate[dayKey(day)];
    final isToday = isSameDate(day, DateTime.now());
    final isSelected = isSameDate(day, _selectedDay);
    final isFuture = dateOnly(day).isAfter(dateOnly(DateTime.now()));

    Color? bg;
    Color fg;
    Border? border;

    if (rec != null && rec.status == 'complete') {
      final achieved = (rec.durationMin ?? 0) >= targetMinutes;
      bg = achieved ? context.appColors.success : context.appColors.warning;
      fg = context.appColors.bg;
    } else if (rec != null) {
      fg = context.appColors.warning;
      border = Border.all(
        color: context.appColors.warning.withValues(alpha: 0.75),
        width: 1.2,
      );
    } else {
      bg = isFuture ? null : context.appColors.inactive.withValues(alpha: 0.45);
      fg = isFuture
          ? context.appColors.textSecondary.withValues(alpha: 0.35)
          : context.appColors.textSecondary;
    }

    if (isSelected) {
      border = Border.all(color: context.appColors.moonGold, width: 2);
    } else if (isToday) {
      border = Border.all(
        color: context.appColors.moonGold.withValues(alpha: 0.6),
        width: 1.2,
      );
    }

    return Container(
      margin: const EdgeInsets.all(5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildDetailCard(SleepRecord? rec) {
    final d = _selectedDay;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${d.month}月${d.day}日 · ${weekdayZh(d)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (rec != null && rec.isManual)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.appColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '手动补录',
                    style: TextStyle(fontSize: 11, color: context.appColors.warning),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (rec == null) ...[
            Text(
              '这一天还没有记录',
              style: TextStyle(fontSize: 13, color: context.appColors.textSecondary),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openEditor(null),
                child: const Text('补录睡眠记录'),
              ),
            ),
          ] else ...[
            Row(
              children: [
                _DetailMetric(
                  label: '入睡',
                  value: rec.bedTime == null ? '—' : formatTime(rec.bedTime!),
                ),
                _DetailMetric(
                  label: '起床',
                  value: rec.wakeTime == null ? '—' : formatTime(rec.wakeTime!),
                ),
                _DetailMetric(
                  label: '时长',
                  value: formatDuration(rec.durationMin),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rec.status == 'bed_only')
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  '只记录了睡前打卡，点击编辑可补全起床时间',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
            Row(
              children: [
                StarRating(value: rec.quality, size: 16),
                const SizedBox(width: 8),
                Text(
                  '睡眠质量',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (rec.dream != null && rec.dream!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _QuoteBlock(
                icon: Icons.nightlight_round,
                text: rec.dream!,
              ),
            ],
            if (rec.note != null && rec.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _QuoteBlock(
                icon: Icons.edit_note_rounded,
                text: rec.note!,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: () => _confirmDelete(rec),
                  style: TextButton.styleFrom(
                    foregroundColor: context.appColors.danger,
                  ),
                  child: const Text('删除'),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => _openEditor(rec),
                  child: Text(rec.status == 'bed_only' ? '补全记录' : '编辑'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendCard(List<SleepRecord> records, DateTime now, int target) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '睡眠趋势',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('周')),
                  ButtonSegment(value: 30, label: Text('月')),
                ],
                selected: {_trendDays},
                onSelectionChanged: (selection) =>
                    setState(() => _trendDays = selection.first),
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SleepTrendCharts(
            records: records,
            now: now,
            days: _trendDays,
            targetMinutes: target,
          ),
        ],
      ),
    );
  }

  Widget _buildRegularityCard(int? score) {
    final label = score == null
        ? '记录满 3 天后生成评分'
        : score >= 85
            ? '很规律，继续保持'
            : score >= 70
                ? '比较规律'
                : score >= 50
                    ? '波动明显，可以再稳定一些'
                    : '作息偏乱，先从固定入睡时间开始';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '规律性评分',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                score == null ? '—' : '$score',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.moonGold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, left: 2),
                child: Text(
                  '分',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (score ?? 0) / 100,
              minHeight: 5,
              backgroundColor: context.appColors.inactive.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(context.appColors.moonGold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '近 14 天入睡与起床时间的波动，越高越规律',
            style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(WindowStats stats, int? score) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '近 30 天',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 1.35,
            children: [
              _StatItem(
                label: '平均入睡',
                value: stats.avgBedMin == null
                    ? '—'
                    : formatClockMinutes(stats.avgBedMin!),
              ),
              _StatItem(
                label: '平均起床',
                value: stats.avgWakeMin == null
                    ? '—'
                    : formatClockMinutes(stats.avgWakeMin!),
              ),
              _StatItem(
                label: '平均时长',
                value: formatDuration(stats.avgDurationMin),
              ),
              _StatItem(
                label: '平均质量',
                value: stats.avgQuality == null
                    ? '—'
                    : '${stats.avgQuality!.toStringAsFixed(1)} 分',
              ),
              _StatItem(
                label: '打卡完成率',
                value: '${(stats.completionRate * 100).round()}%',
              ),
              _StatItem(
                label: '规律性评分',
                value: score == null ? '—' : '$score 分',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard(List<WeekSummary> weeks) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '周报',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (weeks.isEmpty)
            Text(
              '完整打卡一周后生成周报',
              style: TextStyle(fontSize: 12, color: context.appColors.textSecondary),
            )
          else
            for (var i = 0; i < weeks.length; i++) ...[
              _WeekEntry(week: weeks[i]),
              if (i != weeks.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
            ],
        ],
      ),
    );
  }

  Future<void> _openEditor(SleepRecord? rec) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _RecordEditorDialog(
        anchorDate: _selectedDay,
        record: rec,
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
      await checkBadgesAndCelebrate(context, ref);
    }
  }

  Future<void> _confirmDelete(SleepRecord rec) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('删除后无法恢复，确定删除这一天的睡眠记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.appColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(databaseProvider).deleteRecord(rec.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      }
    }
  }
}

class _WeekEntry extends StatelessWidget {
  const _WeekEntry({required this.week});

  final WeekSummary week;

  @override
  Widget build(BuildContext context) {
    final start = week.weekStart;
    final end = start.add(const Duration(days: 6));
    final best = week.bestDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${start.month}月${start.day}日 – ${end.month}月${end.day}日',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '打卡 ${week.completeDays} 天',
              style: TextStyle(
                fontSize: 11,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '平均 ${formatDuration(week.avgDurationMin)} · '
          '${formatDeltaMinutes(week.diffFromPreviousMin)}',
          style: TextStyle(fontSize: 12, color: context.appColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          '规律性 ${week.regularity ?? '—'} 分'
          '${best != null ? ' · 最好 ${weekdayZh(best)} ${formatDuration(week.bestDurationMin)}' : ''}',
          style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.appColors.moonGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});

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
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}

class _LegendHollow extends StatelessWidget {
  const _LegendHollow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.appColors.warning, width: 1.2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}

class _RecordEditorDialog extends ConsumerStatefulWidget {
  const _RecordEditorDialog({required this.anchorDate, this.record});

  final DateTime anchorDate;
  final SleepRecord? record;

  @override
  ConsumerState<_RecordEditorDialog> createState() =>
      _RecordEditorDialogState();
}

class _RecordEditorDialogState extends ConsumerState<_RecordEditorDialog> {
  late TimeOfDay _bed;
  late TimeOfDay _wake;
  late int _quality;
  late final TextEditingController _dream;
  late final TextEditingController _note;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _bed = r?.bedTime != null
        ? TimeOfDay.fromDateTime(r!.bedTime!)
        : const TimeOfDay(hour: 23, minute: 30);
    _wake = r?.wakeTime != null
        ? TimeOfDay.fromDateTime(r!.wakeTime!)
        : const TimeOfDay(hour: 7, minute: 0);
    _quality = r?.quality ?? 3;
    _dream = TextEditingController(text: r?.dream ?? '');
    _note = TextEditingController(text: r?.note ?? '');
  }

  @override
  void dispose() {
    _dream.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isBed}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBed ? _bed : _wake,
      helpText: isBed ? '入睡时间' : '起床时间',
    );
    if (picked == null) return;
    setState(() {
      if (isBed) {
        _bed = picked;
      } else {
        _wake = picked;
      }
      _error = null;
    });
  }

  Future<void> _save() async {
    final anchor = widget.anchorDate;
    final window = sleepWindow(
      anchor,
      bedHour: _bed.hour,
      bedMinute: _bed.minute,
      wakeHour: _wake.hour,
      wakeMinute: _wake.minute,
    );
    if (!isValidSleepDuration(window.minutes)) {
      setState(() => _error = '时长看起来不对，请检查入睡和起床时间');
      return;
    }
    setState(() => _saving = true);
    final dream = _dream.text.trim();
    final note = _note.text.trim();
    await ref.read(databaseProvider).saveManualRecord(
          anchorDate: anchor,
          bedTime: window.bed,
          wakeTime: window.wake,
          quality: _quality,
          dream: dream.isEmpty ? null : dream,
          note: note.isEmpty ? null : note,
        );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.record == null ? '补录睡眠' : '编辑记录'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimeRow(
                label: '入睡时间',
                time: _bed,
                onTap: () => _pickTime(isBed: true),
              ),
              _TimeRow(
                label: '起床时间',
                time: _wake,
                onTap: () => _pickTime(isBed: false),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '睡眠质量',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  StarRating(
                    value: _quality,
                    size: 24,
                    onChanged: (v) => setState(() => _quality = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dream,
                maxLines: 1,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: '记一句梦（可选）',
                  filled: true,
                  fillColor: context.appColors.bg,
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
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                maxLines: 1,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: '备注（可选）',
                  filled: true,
                  fillColor: context.appColors.bg,
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
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  String get _text =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.appColors.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
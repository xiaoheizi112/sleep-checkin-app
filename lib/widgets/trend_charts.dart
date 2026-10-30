import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/sleep_math.dart';
import '../logic/stats_math.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';

class SleepTrendCharts extends StatelessWidget {
  const SleepTrendCharts({
    super.key,
    required this.records,
    required this.now,
    required this.days,
    required this.targetMinutes,
  });

  final List<SleepRecord> records;
  final DateTime now;
  final int days;
  final int targetMinutes;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final byDate = <String, SleepRecord>{
      for (final r in records) dayKey(r.anchorDate): r,
    };
    final today = dateOnly(now);
    final dates = [
      for (var i = days - 1; i >= 0; i--)
        today.subtract(Duration(days: i)),
    ];
    final hasData = dates.any((d) => byDate.containsKey(dayKey(d)));
    if (!hasData) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Center(
          child: Text(
            '这段时间还没有记录',
            style: TextStyle(fontSize: 12, color: c.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '睡眠时长',
          style: TextStyle(fontSize: 12, color: c.textSecondary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 176,
          child: _DurationBarChart(
            dates: dates,
            byDate: byDate,
            targetMinutes: targetMinutes,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '入睡时间',
          style: TextStyle(fontSize: 12, color: c.textSecondary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: _BedtimeLineChart(dates: dates, byDate: byDate),
        ),
      ],
    );
  }
}

TextStyle _labelStyle(Color color) => TextStyle(fontSize: 10, color: color);

Widget _bottomLabel(
  int index,
  DateTime date,
  int days,
  Color color,
) {
  if (days <= 7) {
    return Text(weekdayZh(date).substring(1), style: _labelStyle(color));
  }
  if (index % 5 == 0 || index == days - 1) {
    return Text('${date.day}', style: _labelStyle(color));
  }
  return const SizedBox.shrink();
}

class _DurationBarChart extends StatelessWidget {
  const _DurationBarChart({
    required this.dates,
    required this.byDate,
    required this.targetMinutes,
  });

  final List<DateTime> dates;
  final Map<String, SleepRecord> byDate;
  final int targetMinutes;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < dates.length; i++) {
      final rec = byDate[dayKey(dates[i])];
      final minutes = rec?.status == 'complete' ? rec?.durationMin : null;
      final hours = (minutes ?? 0) / 60;
      final color = minutes == null
          ? c.inactive.withValues(alpha: 0.35)
          : (minutes >= targetMinutes ? c.success : c.warning);
      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: hours,
            color: color,
            width: dates.length > 10 ? 6 : 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 12,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: c.gridLine,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 3,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}h',
                style: _labelStyle(c.textSecondary),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dates.length) {
                  return const SizedBox.shrink();
                }
                return _bottomLabel(
                  index,
                  dates[index],
                  dates.length,
                  c.textSecondary,
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => c.surfaceHigh,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final rec = byDate[dayKey(dates[group.x])];
              return BarTooltipItem(
                formatDuration(rec?.durationMin),
                TextStyle(color: c.textPrimary, fontSize: 11),
              );
            },
          ),
        ),
        barGroups: groups,
      ),
      duration: appMotion(context, 350),
      curve: Curves.easeOutCubic,
    );
  }
}

class _BedtimeLineChart extends StatelessWidget {
  const _BedtimeLineChart({required this.dates, required this.byDate});

  final List<DateTime> dates;
  final Map<String, SleepRecord> byDate;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final spots = <FlSpot>[];
    for (var i = 0; i < dates.length; i++) {
      final rec = byDate[dayKey(dates[i])];
      final bed = rec?.bedTime;
      if (bed == null) continue;
      spots.add(FlSpot(i.toDouble(), normalizedBedMinutes(bed) / 60));
    }
    if (spots.isEmpty) {
      return Center(
        child: Text(
          '暂无入睡时间数据',
          style: TextStyle(fontSize: 12, color: c.textSecondary),
        ),
      );
    }

    final values = spots.map((s) => s.y);
    var minY = values.reduce((a, b) => a < b ? a : b).floorToDouble() - 1;
    var maxY = values.reduce((a, b) => a > b ? a : b).ceilToDouble() + 1;
    if (minY > 24) minY = 24;
    if (minY < 18) minY = 18;
    if (maxY < minY + 2) maxY = minY + 2;
    if (maxY > 36) maxY = 36;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (dates.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: c.gridLine,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2,
              getTitlesWidget: (value, meta) => Text(
                formatClockMinutes((value * 60).round()),
                style: _labelStyle(c.textSecondary),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dates.length) {
                  return const SizedBox.shrink();
                }
                return _bottomLabel(
                  index,
                  dates[index],
                  dates.length,
                  c.textSecondary,
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => c.surfaceHigh,
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  formatClockMinutes((spot.y * 60).round()),
                  TextStyle(color: c.textPrimary, fontSize: 11),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: c.moonGold,
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: c.moonGold.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
      duration: appMotion(context, 350),
      curve: Curves.easeOutCubic,
    );
  }
}
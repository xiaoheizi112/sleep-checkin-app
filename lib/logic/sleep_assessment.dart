import '../data/database.dart';
import 'sleep_math.dart';
import 'stats_math.dart';

class AssessmentComponent {
  const AssessmentComponent({
    required this.label,
    required this.score,
    required this.detail,
  });

  final String label;
  final int score;
  final String detail;
}

class AssessmentFinding {
  const AssessmentFinding({
    required this.title,
    required this.detail,
    this.positive = false,
  });

  final String title;
  final String detail;
  final bool positive;
}

class SleepAssessment {
  const SleepAssessment({
    required this.hasEnoughData,
    required this.sampleDays,
    required this.windowDays,
    required this.score,
    required this.grade,
    required this.components,
    required this.findings,
    required this.suggestions,
  });

  final bool hasEnoughData;
  final int sampleDays;
  final int windowDays;
  final int score;
  final String grade;
  final List<AssessmentComponent> components;
  final List<AssessmentFinding> findings;
  final List<String> suggestions;
}

/// 纯本地规则评估：近 [windowDays] 天的完整记录。
/// 总分 = 时长 30% + 规律性 25% + 入睡时间 20% + 主观质量 15% + 记录完整 10%。
SleepAssessment assessSleep(
  List<SleepRecord> records, {
  DateTime? now,
  int windowDays = 14,
  int targetDurationMin = 420,
  int earlyBedMinutes = 23 * 60 + 30,
}) {
  final today = dateOnly(now ?? DateTime.now());
  final start = today.subtract(Duration(days: windowDays - 1));
  final valid = records.where((r) {
    if (r.status != 'complete' ||
        r.bedTime == null ||
        r.wakeTime == null ||
        r.durationMin == null) {
      return false;
    }
    final d = dateOnly(r.anchorDate);
    return !d.isBefore(start) && !d.isAfter(today);
  }).toList();

  final sampleDays = valid.length;
  if (valid.isEmpty) {
    return SleepAssessment(
      hasEnoughData: false,
      sampleDays: 0,
      windowDays: windowDays,
      score: 0,
      grade: '数据不足',
      components: const [],
      findings: const [],
      suggestions: const [
        '连续记录 5 天以上，才能得到可靠的睡眠质量测评。',
        '每天起床后顺手打卡，记录越完整建议越准确。',
      ],
    );
  }

  final hasEnoughData = sampleDays >= 5;
  final regularity = regularityScoreOf(valid);
  final avgDuration =
      (valid.map((r) => r.durationMin!).reduce((a, b) => a + b) / sampleDays)
          .round();
  final avgBed = (valid
              .map((r) => normalizedBedMinutes(r.bedTime!))
              .reduce((a, b) => a + b) /
          sampleDays)
      .round();
  final avgQuality =
      valid.map((r) => r.quality.toDouble()).reduce((a, b) => a + b) /
          sampleDays;
  final completion = (sampleDays / windowDays).clamp(0.0, 1.0);

  double durationScore;
  if (avgDuration < targetDurationMin) {
    durationScore = 100 - (targetDurationMin - avgDuration) * 0.35;
  } else if (avgDuration > 9 * 60) {
    durationScore = 100 - (avgDuration - 9 * 60) * 0.2;
  } else {
    durationScore = 100;
  }
  final durationScoreInt = durationScore.clamp(0, 100).round();
  final regularityScoreInt = regularity ?? 50;
  final bedtimeScoreInt =
      (100 - (avgBed - earlyBedMinutes).clamp(0, 10000) * 0.25)
          .clamp(0, 100)
          .round();
  final qualityScoreInt = (avgQuality / 5 * 100).clamp(0, 100).round();
  final consistencyScoreInt = (completion * 100).clamp(0, 100).round();

  final score = (durationScoreInt * 0.30 +
          regularityScoreInt * 0.25 +
          bedtimeScoreInt * 0.20 +
          qualityScoreInt * 0.15 +
          consistencyScoreInt * 0.10)
      .round();

  final grade = !hasEnoughData
      ? '样本较少'
      : score >= 85
          ? '优秀'
          : score >= 70
              ? '良好'
              : score >= 55
                  ? '一般'
                  : '需改善';

  final components = [
    AssessmentComponent(
      label: '睡眠时长',
      score: durationScoreInt,
      detail:
          '平均 ${formatDuration(avgDuration)}，目标 ${formatDuration(targetDurationMin)}',
    ),
    AssessmentComponent(
      label: '作息规律',
      score: regularityScoreInt,
      detail: regularity == null ? '记录不足 3 天，暂用中性分' : '入睡与起床时间的波动程度',
    ),
    AssessmentComponent(
      label: '入睡时间',
      score: bedtimeScoreInt,
      detail:
          '平均 ${formatClockMinutes(avgBed)}，目标 ${formatClockMinutes(earlyBedMinutes)}',
    ),
    AssessmentComponent(
      label: '主观质量',
      score: qualityScoreInt,
      detail: '平均 ${avgQuality.toStringAsFixed(1)} / 5 星',
    ),
    AssessmentComponent(
      label: '记录完整',
      score: consistencyScoreInt,
      detail: '近 $windowDays 天记录了 $sampleDays 天',
    ),
  ];

  final findings = <AssessmentFinding>[];
  final negativeFindings = <AssessmentFinding>[];

  if (avgDuration < targetDurationMin - 15) {
    negativeFindings.add(AssessmentFinding(
      title: '睡眠时长偏短',
      detail:
          '平均 ${formatDuration(avgDuration)}，比 ${formatDuration(targetDurationMin)} 的目标少 ${formatDuration(targetDurationMin - avgDuration)}。',
    ));
  } else if (avgDuration > 9 * 60) {
    negativeFindings.add(AssessmentFinding(
      title: '睡眠时间偏长',
      detail:
          '平均 ${formatDuration(avgDuration)}，过长有时也意味着睡眠质量不高。',
    ));
  }

  if (regularity != null && regularity < 70) {
    negativeFindings.add(AssessmentFinding(
      title: '作息波动较大',
      detail: '近 $windowDays 天入睡与起床时间不够稳定，规律性评分 $regularity 分。',
    ));
  }

  final lateBy = avgBed - earlyBedMinutes;
  if (lateBy > 30) {
    negativeFindings.add(AssessmentFinding(
      title: '入睡时间偏晚',
      detail:
          '平均 ${formatClockMinutes(avgBed)} 入睡，比目标晚 $lateBy 分钟。',
    ));
  }

  final shortNights = valid.where((r) => r.durationMin! < 6 * 60).length;
  final shortRatio = shortNights / sampleDays;
  if (shortNights > 0 && shortRatio >= 0.3) {
    negativeFindings.add(AssessmentFinding(
      title: '频繁睡眠不足',
      detail: '有 $shortNights 晚睡眠不足 6 小时。',
    ));
  }

  if (avgQuality < 3.0) {
    negativeFindings.add(AssessmentFinding(
      title: '主观质量偏低',
      detail: '平均 ${avgQuality.toStringAsFixed(1)} 星，多数夜晚感觉没睡好。',
    ));
  }

  int? weekendDrift;
  final weekendBeds = valid
      .where((r) => r.anchorDate.weekday >= 6)
      .map((r) => normalizedBedMinutes(r.bedTime!))
      .toList();
  final weekdayBeds = valid
      .where((r) => r.anchorDate.weekday <= 5)
      .map((r) => normalizedBedMinutes(r.bedTime!))
      .toList();
  if (weekendBeds.isNotEmpty && weekdayBeds.isNotEmpty) {
    final weekendAvg =
        weekendBeds.reduce((a, b) => a + b) / weekendBeds.length;
    final weekdayAvg =
        weekdayBeds.reduce((a, b) => a + b) / weekdayBeds.length;
    weekendDrift = (weekendAvg - weekdayAvg).round();
  }

  final balance = sleepBalance(
    valid,
    today,
    days: 7,
    targetDurationMin: targetDurationMin,
  );
  if (balance.recordedDays >= 4 && balance.netMinutes <= -120) {
    negativeFindings.add(AssessmentFinding(
      title: '睡眠负债累积',
      detail:
          '近 7 天记录了 ${balance.recordedDays} 天，累计欠睡 ${formatDuration(-balance.netMinutes)}。',
    ));
  }

  final jetlag = socialJetlag(valid, today);
  final hasJetlag =
      jetlag.differenceMinutes != null && jetlag.differenceMinutes! >= 60;
  if (hasJetlag) {
    final driftNote =
        weekendDrift != null && weekendDrift > 30 ? '，周末平均晚 $weekendDrift 分钟入睡' : '';
    negativeFindings.add(AssessmentFinding(
      title: '社交时差明显',
      detail:
          '工作日与休息日的睡眠中点相差 ${formatDuration(jetlag.differenceMinutes!)}$driftNote。',
    ));
  } else if (weekendDrift != null && weekendDrift > 60) {
    negativeFindings.add(AssessmentFinding(
      title: '周末作息漂移',
      detail: '周末平均比工作日晚 $weekendDrift 分钟入睡，起床也更晚。',
    ));
  }

  final lateNights = valid
      .where((r) => normalizedBedMinutes(r.bedTime!) >= 24 * 60)
      .toList();
  final earlyNights = valid
      .where((r) => normalizedBedMinutes(r.bedTime!) < 24 * 60)
      .toList();
  if (lateNights.length >= 2 && earlyNights.length >= 2) {
    final lateQuality = lateNights
            .map((r) => r.quality)
            .reduce((a, b) => a + b) /
        lateNights.length;
    final earlyQuality = earlyNights
            .map((r) => r.quality)
            .reduce((a, b) => a + b) /
        earlyNights.length;
    if (lateQuality + 0.5 <= earlyQuality) {
      negativeFindings.add(AssessmentFinding(
        title: '晚睡与低质量相关',
        detail:
            '零点后入睡的夜晚平均质量 ${lateQuality.toStringAsFixed(1)} 星，零点前为 ${earlyQuality.toStringAsFixed(1)} 星。',
      ));
    }
  }

  if (completion < 0.7) {
    negativeFindings.add(AssessmentFinding(
      title: '记录不够完整',
      detail: '近 $windowDays 天只记录了 $sampleDays 天，评估可信度有限。',
    ));
  }

  if (durationScoreInt >= 85 &&
      (regularity ?? 0) >= 80 &&
      avgQuality >= 3.8) {
    findings.add(AssessmentFinding(
      title: '整体作息稳定',
      detail: '时长、规律性和主观质量都保持在不错的水平。',
      positive: true,
    ));
  }
  findings.addAll(negativeFindings);
  if (findings.isEmpty) {
    findings.add(AssessmentFinding(
      title: '暂未发现明显问题',
      detail: '记录的数据里没有触发风险规则，继续保持。',
      positive: true,
    ));
  }

  final suggestions = <String>{};
  if (avgDuration < targetDurationMin - 15) {
    suggestions.add('把就寝时间提前 20–30 分钟，分几步补足到目标时长。');
  }
  if (regularity != null && regularity < 70) {
    suggestions.add('先固定每天的起床时间，比固定入睡时间更容易见效。');
  }
  if (weekendDrift != null && weekendDrift > 60) {
    suggestions.add('周末起床时间尽量控制在工作日前后 1 小时内，避免周一重置。');
  }
  if (balance.recordedDays >= 4 && balance.netMinutes <= -120) {
    suggestions.add('今晚提前 30 分钟上床，先还一部分睡眠债。');
  }
  if (hasJetlag && (weekendDrift == null || weekendDrift <= 60)) {
    suggestions.add('周末起床时间尽量控制在工作日前后 1 小时内，避免周一重置。');
  }
  if (lateBy > 30) {
    suggestions.add('设一个"准备睡觉"闹钟，到点后放下手机、调暗灯光。');
  }
  if (shortNights > 0 && shortRatio >= 0.3) {
    suggestions.add('连续缺觉时优先把睡眠时长补回来，再谈其他优化。');
  }
  if (avgQuality < 3.0) {
    suggestions.add('记录睡前咖啡因、饮酒、运动和情绪，找出影响主观质量的因素。');
  }
  if (completion < 0.7) {
    suggestions.add('每天起床后顺手打卡，数据越完整，建议越准确。');
  }
  if (suggestions.isEmpty) {
    suggestions.add('保持现在的作息节奏，继续记录观察长期趋势。');
  }
  suggestions.add('如果失眠或白天嗜睡持续超过 3 周，建议咨询医生。');

  return SleepAssessment(
    hasEnoughData: hasEnoughData,
    sampleDays: sampleDays,
    windowDays: windowDays,
    score: score,
    grade: grade,
    components: components,
    findings: findings,
    suggestions: suggestions.toList(),
  );
}
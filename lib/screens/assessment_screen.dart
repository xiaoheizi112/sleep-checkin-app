import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/sleep_assessment.dart';
import '../providers.dart';
import '../theme/app_colors.dart';

class AssessmentScreen extends ConsumerWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final records = ref.watch(recordsProvider).value;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final target = ref.watch(targetDurationProvider);
    final earlyBed = ref.watch(earlyBedMinutesProvider);
    final result = assessSleep(
      records ?? const [],
      now: now,
      targetDurationMin: target,
      earlyBedMinutes: earlyBed,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('睡眠质量测评')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ScoreHero(result: result),
          if (result.components.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ComponentsCard(result: result),
          ],
          if (result.findings.isNotEmpty) ...[
            const SizedBox(height: 16),
            _FindingsCard(result: result),
          ],
          const SizedBox(height: 16),
          _SuggestionsCard(result: result),
          const SizedBox(height: 14),
          Text(
            '本评估基于你的打卡数据，仅供自我观察，不构成医疗建议。',
            style: TextStyle(fontSize: 11, color: c.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.result});

  final SleepAssessment result;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
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
                    Text(
                      '近 ${result.windowDays} 天睡眠质量',
                      style: TextStyle(fontSize: 13, color: c.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.grade,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '有效记录 ${result.sampleDays} 天',
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.sampleDays == 0 ? '—' : '${result.score}',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w700,
                      color: c.moonGold,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 2),
                    child: Text(
                      ' 分',
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: result.score / 100,
              minHeight: 5,
              backgroundColor: c.inactive.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(c.moonGold),
            ),
          ),
          if (!result.hasEnoughData) ...[
            const SizedBox(height: 10),
            Text(
              result.sampleDays == 0
                  ? '先连续记录 5 天，才能得到可靠的评估。'
                  : '已记录 ${result.sampleDays} 天，满 5 天后评估更准确。',
              style: TextStyle(fontSize: 11, color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComponentsCard extends StatelessWidget {
  const _ComponentsCard({required this.result});

  final SleepAssessment result;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final components = result.components;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '评分构成',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < components.length; i++) ...[
            Row(
              children: [
                Text(
                  components[i].label,
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '${components[i].score} 分',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor(c, components[i].score),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: components[i].score / 100,
                minHeight: 4,
                backgroundColor: c.inactive.withValues(alpha: 0.45),
                valueColor: AlwaysStoppedAnimation(
                  _scoreColor(c, components[i].score),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              components[i].detail,
              style: TextStyle(fontSize: 11, color: c.textSecondary),
            ),
            if (i != components.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _FindingsCard extends StatelessWidget {
  const _FindingsCard({required this.result});

  final SleepAssessment result;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '分析',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < result.findings.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    result.findings[i].positive
                        ? Icons.check_circle_rounded
                        : Icons.info_rounded,
                    size: 18,
                    color: result.findings[i].positive
                        ? c.success
                        : c.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.findings[i].title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          result.findings[i].detail,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != result.findings.length - 1)
              Divider(color: c.gridLine, height: 1),
          ],
        ],
      ),
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  const _SuggestionsCard({required this.result});

  final SleepAssessment result;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '建议',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < result.suggestions.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.moonGold.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.moonGold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      result.suggestions[i],
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            if (i != result.suggestions.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

Color _scoreColor(AppPalette c, int score) {
  if (score >= 85) return c.success;
  if (score >= 70) return c.moonGold;
  if (score >= 55) return c.warning;
  return c.danger;
}
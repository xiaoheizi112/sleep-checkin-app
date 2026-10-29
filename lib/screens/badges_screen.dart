import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../logic/badges.dart';
import '../logic/sleep_math.dart';
import '../providers.dart';
import '../theme/app_colors.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(badgesProvider).value ?? const <UnlockedBadge>[];
    final unlockedMap = {
      for (final badge in unlocked) badge.badgeKey: badge.unlockedAt,
    };
    final records =
        ref.watch(recordsProvider).value ?? const <SleepRecord>[];
    final best = bestStreak(completedDaysOf(records));

    return Scaffold(
      appBar: AppBar(title: const Text('徽章墙')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
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
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: context.appColors.moonGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '已点亮 ${unlocked.length} / ${BadgeCatalog.total}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: BadgeCatalog.total == 0
                        ? 0
                        : unlocked.length / BadgeCatalog.total,
                    minHeight: 5,
                    backgroundColor: context.appColors.inactive.withValues(alpha: 0.5),
                    valueColor:
                        AlwaysStoppedAnimation(context.appColors.moonGold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
            children: [
              for (final badge in BadgeCatalog.all)
                _BadgeTile(
                  badge: badge,
                  unlockedAt: unlockedMap[badge.key],
                  bestStreak: best,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.unlockedAt,
    required this.bestStreak,
  });

  final BadgeDef badge;
  final DateTime? unlockedAt;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    final unlocked = unlockedAt != null;
    final target = badge.streakTarget;
    final detail = unlocked
        ? '${unlockedAt!.month}月${unlockedAt!.day}日解锁'
        : (target != null ? '$bestStreak/$target 天' : badge.description);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: unlocked
            ? context.appColors.moonGold.withValues(alpha: 0.08)
            : context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: unlocked
            ? Border.all(color: context.appColors.moonGold.withValues(alpha: 0.35))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? context.appColors.moonGold.withValues(alpha: 0.16)
                  : context.appColors.inactive.withValues(alpha: 0.25),
            ),
            child: Icon(
              badge.icon,
              size: 26,
              color: unlocked ? context.appColors.moonGold : context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: unlocked ? context.appColors.textPrimary : context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              color: unlocked
                  ? context.appColors.moonGold.withValues(alpha: 0.85)
                  : context.appColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
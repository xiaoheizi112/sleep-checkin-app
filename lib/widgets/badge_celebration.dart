import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/badges.dart';
import '../providers.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';

/// 打卡/补录完成后统一检查徽章：发通知并弹庆祝框。
Future<void> checkBadgesAndCelebrate(
  BuildContext context,
  WidgetRef ref,
) async {
  final newly = await ref.read(badgeServiceProvider).checkAndUnlock();
  if (newly.isEmpty) return;
  for (final badge in newly) {
    await NotificationService.showBadgeUnlocked(badge);
  }
  if (context.mounted) {
    await celebrateBadges(context, newly);
  }
}

Future<void> celebrateBadges(
  BuildContext context,
  List<BadgeDef> badges,
) async {
  if (badges.isEmpty) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _BadgeUnlockDialog(badges: badges),
  );
}

class _BadgeUnlockDialog extends StatelessWidget {
  const _BadgeUnlockDialog({required this.badges});

  final List<BadgeDef> badges;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.7, end: 1),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.appColors.moonGold.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: context.appColors.moonGold.withValues(alpha: 0.14),
                blurRadius: 44,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.appColors.moonGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: context.appColors.moonGold,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '解锁新徽章',
                style: TextStyle(fontSize: 13, color: context.appColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final badge in badges)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Icon(
                                badge.icon,
                                color: context.appColors.moonGold,
                                size: 38,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                badge.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                badge.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    badges.length > 1 ? '收下 ${badges.length} 枚徽章' : '太棒了',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
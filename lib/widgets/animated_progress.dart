import 'package:flutter/material.dart';

import '../theme/motion.dart';

/// 会从 0 平滑长到目标值的进度条，数值变化时从当前值继续过渡。
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
    this.height = 4,
  });

  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: appMotion(context, 600),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: animated,
          minHeight: height,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}
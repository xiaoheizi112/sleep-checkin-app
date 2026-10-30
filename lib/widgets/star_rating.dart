import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/motion.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.size = 20,
    this.onChanged,
  });

  final int value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onChanged == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onChanged!(i);
                  },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: _StarGlyph(filled: i <= value, size: size),
            ),
          ),
      ],
    );
  }
}

class _StarGlyph extends StatelessWidget {
  const _StarGlyph({required this.filled, required this.size});

  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(filled),
      tween: Tween(begin: filled ? 0.72 : 1, end: 1),
      duration: appMotion(context, 180),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Icon(
        filled ? Icons.star_rounded : Icons.star_border_rounded,
        size: size,
        color: filled ? context.appColors.moonGold : context.appColors.inactive,
      ),
    );
  }
}
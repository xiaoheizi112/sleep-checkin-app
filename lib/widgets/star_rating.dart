import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
            onTap: onChanged == null ? null : () => onChanged!(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Icon(
                i <= value ? Icons.star_rounded : Icons.star_border_rounded,
                size: size,
                color: i <= value ? context.appColors.moonGold : context.appColors.inactive,
              ),
            ),
          ),
      ],
    );
  }
}
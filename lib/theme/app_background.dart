import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 全屏星空底色：渐变夜空 + 星云光斑 + 星点，全部取色自当前调色板。
///
/// 背景是静态的，用 [RepaintBoundary] 隔离，滚动页面时不会重复绘制。
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(painter: _SkyPainter(palette)),
        ),
        child,
      ],
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.palette);

  final AppPalette palette;

  bool get _dark => palette.brightness == Brightness.dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.bgTop, palette.bgMid, palette.bgBottom],
          stops: const [0, 0.52, 1],
        ).createShader(rect),
    );

    // 右上紫雾、左下青光、底部再压一层紫，模拟参考图里的星云明暗。
    _glow(
      canvas,
      Offset(size.width * 0.86, size.height * 0.10),
      size.width * 0.72,
      palette.nebulaA,
      _dark ? 0.30 : 0.20,
    );
    _glow(
      canvas,
      Offset(size.width * 0.08, size.height * 0.62),
      size.width * 0.82,
      _dark ? palette.nebulaB : palette.nebulaA,
      _dark ? 0.16 : 0.15,
    );
    _glow(
      canvas,
      Offset(size.width * 0.50, size.height * 1.05),
      size.width,
      _dark ? palette.nebulaA : palette.nebulaB,
      _dark ? 0.22 : 0.18,
    );

    // 极淡的轨道弧线，给纯渐变增加一点空间纵深。
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.star.withValues(alpha: _dark ? 0.06 : 0.35);
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.30),
      size.width * 0.62,
      arcPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.02, size.height * 0.78),
      size.width * 0.45,
      arcPaint,
    );

    _paintStars(canvas, size);
  }

  void _paintStars(Canvas canvas, Size size) {
    final random = math.Random(20261029);
    final count = _dark ? 64 : 26;
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.5 + random.nextDouble() * 1.15;
      var alpha = _dark
          ? 0.18 + random.nextDouble() * 0.55
          : 0.25 + random.nextDouble() * 0.30;
      // 左上角留给标题和返回键，星点压到字上会像污点。
      if (x < size.width * 0.55 && y < size.height * 0.20) {
        alpha *= 0.3;
      }
      paint.color = palette.star.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final sparklePaint = Paint()
      ..color = palette.star.withValues(alpha: _dark ? 0.9 : 0.55);
    _sparkle(canvas, Offset(size.width * 0.78, size.height * 0.075), 8, sparklePaint);
    _sparkle(canvas, Offset(size.width * 0.90, size.height * 0.50), 4, sparklePaint);
    if (_dark) {
      _sparkle(
        canvas,
        Offset(size.width * 0.16, size.height * 0.82),
        3.5,
        sparklePaint,
      );
    }
  }

  void _glow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _sparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * 0.16,
        center.dy - radius * 0.16,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.16,
        center.dy + radius * 0.16,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.16,
        center.dy + radius * 0.16,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.16,
        center.dy - radius * 0.16,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) => oldDelegate.palette != palette;
}
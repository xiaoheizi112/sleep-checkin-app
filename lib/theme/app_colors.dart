import 'package:flutter/material.dart';

/// 两套配色（深色/浅色）共用同一个调色板结构，界面通过 context.appColors 取色。
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.nebulaA,
    required this.nebulaB,
    required this.star,
    required this.surface,
    required this.surfaceHigh,
    required this.textPrimary,
    required this.textSecondary,
    required this.moonGold,
    required this.dawnOrange,
    required this.success,
    required this.warning,
    required this.inactive,
    required this.danger,
    required this.gridLine,
    required this.onAccent,
    required this.onColorBlock,
  });

  final Brightness brightness;

  /// 页面兜底色，用于弹窗、图表填充等无背景层的位置。
  final Color bg;

  /// 星空背景的三段渐变。
  final Color bgTop;
  final Color bgMid;
  final Color bgBottom;

  /// 星云光斑：A 偏紫、B 偏青/晨光。
  final Color nebulaA;
  final Color nebulaB;

  /// 星点与轨道线颜色。
  final Color star;

  final Color surface;
  final Color surfaceHigh;
  final Color textPrimary;
  final Color textSecondary;
  final Color moonGold;
  final Color dawnOrange;
  final Color success;
  final Color warning;
  final Color inactive;
  final Color danger;
  final Color gridLine;
  final Color onAccent;
  final Color onColorBlock;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: Color.lerp(bg, other.bg, t)!,
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bgMid: Color.lerp(bgMid, other.bgMid, t)!,
      bgBottom: Color.lerp(bgBottom, other.bgBottom, t)!,
      nebulaA: Color.lerp(nebulaA, other.nebulaA, t)!,
      nebulaB: Color.lerp(nebulaB, other.nebulaB, t)!,
      star: Color.lerp(star, other.star, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      moonGold: Color.lerp(moonGold, other.moonGold, t)!,
      dawnOrange: Color.lerp(dawnOrange, other.dawnOrange, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      onColorBlock: Color.lerp(onColorBlock, other.onColorBlock, t)!,
    );
  }
}

const darkPalette = AppPalette(
  brightness: Brightness.dark,
  bg: Color(0xFF0A0820),
  bgTop: Color(0xFF060714),
  bgMid: Color(0xFF120D2E),
  bgBottom: Color(0xFF241A4D),
  nebulaA: Color(0xFF7A5CFF),
  nebulaB: Color(0xFF2DD4BF),
  star: Color(0xFFE6E1FF),
  surface: Color(0xEE1B1538),
  surfaceHigh: Color(0xFF2A2152),
  textPrimary: Color(0xFFF4F1FF),
  textSecondary: Color(0xFFA69EC8),
  moonGold: Color(0xFFF2C879),
  dawnOrange: Color(0xFFF5A96A),
  success: Color(0xFF63D6B2),
  warning: Color(0xFFE8BE5C),
  inactive: Color(0xFF3A3162),
  danger: Color(0xFFEF818E),
  gridLine: Color(0xFF2C2552),
  onAccent: Color(0xFF1A1230),
  onColorBlock: Color(0xFF0A0820),
);

const lightPalette = AppPalette(
  brightness: Brightness.light,
  bg: Color(0xFFF7F4FC),
  bgTop: Color(0xFFFCFAFF),
  bgMid: Color(0xFFF3EEFC),
  bgBottom: Color(0xFFEAE3F7),
  nebulaA: Color(0xFFB7A4F5),
  nebulaB: Color(0xFFF2D3B3),
  star: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF),
  surfaceHigh: Color(0xFFF3EDFB),
  textPrimary: Color(0xFF262138),
  textSecondary: Color(0xFF6E6788),
  moonGold: Color(0xFFA9772F),
  dawnOrange: Color(0xFFBE7038),
  success: Color(0xFF4F7A5C),
  warning: Color(0xFF8F6420),
  inactive: Color(0xFFDCD4EC),
  danger: Color(0xFFB25555),
  gridLine: Color(0xFFE6DFF2),
  onAccent: Color(0xFF2B1E3E),
  onColorBlock: Color(0xFFFFFFFF),
);

extension AppPaletteContext on BuildContext {
  AppPalette get appColors =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? darkPalette
          : lightPalette);
}
import 'package:flutter/material.dart';

/// 两套配色（深色/浅色）共用同一个调色板结构，界面通过 context.appColors 取色。
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.bg,
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
  final Color bg;
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
  bg: Color(0xFF0E1318),
  surface: Color(0xFF1A2128),
  surfaceHigh: Color(0xFF232B33),
  textPrimary: Color(0xFFECE8E1),
  textSecondary: Color(0xFF8A929B),
  moonGold: Color(0xFFE8C07A),
  dawnOrange: Color(0xFFF2A65A),
  success: Color(0xFF7FA98C),
  warning: Color(0xFFC9A15E),
  inactive: Color(0xFF39424B),
  danger: Color(0xFFC96F6F),
  gridLine: Color(0xFF29323A),
  onAccent: Color(0xFF241B0F),
  onColorBlock: Color(0xFF0E1318),
);

const lightPalette = AppPalette(
  brightness: Brightness.light,
  bg: Color(0xFFF4EFE6),
  surface: Color(0xFFFFFCF6),
  surfaceHigh: Color(0xFFF0E9DC),
  textPrimary: Color(0xFF2A251F),
  textSecondary: Color(0xFF726A5F),
  moonGold: Color(0xFFB5813C),
  dawnOrange: Color(0xFFC1753A),
  success: Color(0xFF4F7A5C),
  warning: Color(0xFF8F6420),
  inactive: Color(0xFFDCD3C4),
  danger: Color(0xFFB25555),
  gridLine: Color(0xFFE4DCCF),
  onAccent: Color(0xFFFFFBF3),
  onColorBlock: Color(0xFFFFFFFF),
);

extension AppPaletteContext on BuildContext {
  AppPalette get appColors =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? darkPalette
          : lightPalette);
}
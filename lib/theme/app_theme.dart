import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

ThemeData buildDarkTheme() => _buildTheme(darkPalette);

ThemeData buildLightTheme() => _buildTheme(lightPalette);

ThemeData _buildTheme(AppPalette p) {
  final isDark = p.brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: p.brightness,
    primary: p.moonGold,
    onPrimary: p.onAccent,
    secondary: p.dawnOrange,
    onSecondary: p.onAccent,
    error: p.danger,
    onError: Colors.white,
    surface: p.surface,
    onSurface: p.textPrimary,
    outline: p.inactive,
  );
  final overlayStyle =
      (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: p.bg,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: scheme,
    extensions: [p],
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.textPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: overlayStyle,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: p.textPrimary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.moonGold.withValues(alpha: isDark ? 0.18 : 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? p.moonGold
              : p.textSecondary,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? p.moonGold
              : p.textSecondary,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: p.gridLine,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.surfaceHigh,
      contentTextStyle: TextStyle(color: p.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      modalBackgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.moonGold,
        foregroundColor: p.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: p.moonGold),
    ),
    timePickerTheme: TimePickerThemeData(backgroundColor: p.surface),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 1.05,
        color: p.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: p.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.4,
        color: p.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: p.textSecondary,
      ),
    ),
  );
}
import 'package:flutter/material.dart';

/// Material You（Material 3）配色
/// 以墨绿为种子生成的标准 M3 色板：靠 surface 层级分层，不用模糊和渐变
class AppTheme {
  // 保留原名字，供旧代码引用
  static const Color ink = Color(0xFF191D18);
  static const Color paper = Color(0xFFF7FAF4);
  static const Color primary = Color(0xFF2F6B4F);
  static const Color accent = Color(0xFFB4552D);
  static const Color muted = Color(0xFF717971);
  static const Color line = Color(0xFFC1C9BF);

  // ===== M3 表面层级（越靠后越深）=====
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF1F5EE);
  static const Color surface = Color(0xFFEBEFE8);
  static const Color surfaceHigh = Color(0xFFE6E9E2);
  static const Color surfaceHighest = Color(0xFFE0E4DD);
  static const Color onSurfaceVariant = Color(0xFF414942);

  static ThemeData build() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2F6B4F),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFB2F1D0),
      onPrimaryContainer: Color(0xFF002114),
      secondary: Color(0xFF4F6355),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFD2E8D7),
      onSecondaryContainer: Color(0xFF0C1F14),
      tertiary: Color(0xFF3B6470),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFBFE9F8),
      onTertiaryContainer: Color(0xFF001F27),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF7FAF4),
      onSurface: Color(0xFF191D18),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF1F5EE),
      surfaceContainer: Color(0xFFEBEFE8),
      surfaceContainerHigh: Color(0xFFE6E9E2),
      surfaceContainerHighest: Color(0xFFE0E4DD),
      onSurfaceVariant: Color(0xFF414942),
      outline: Color(0xFF717971),
      outlineVariant: Color(0xFFC1C9BF),
      inverseSurface: Color(0xFF2E312D),
      onInverseSurface: Color(0xFFEFF1EB),
      inversePrimary: Color(0xFF96D5B6),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: sel ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
  }
}

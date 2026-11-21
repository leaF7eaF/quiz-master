import 'package:flutter/material.dart';

/// 全局深色主题
/// 常量直接对应深色界面，旧页面引用这些常量会自动适配
class AppTheme {
  static const Color ink = Color(0xFFFFFFFF);          // 主文字（白）
  static const Color paper = Color(0xFF0E1A14);        // 页面底色
  static const Color primary = Color(0xFF5FD08A);      // 亮绿强调
  static const Color accent = Color(0xFFE8A44A);       // 橙
  static const Color muted = Color(0x8AFFFFFF);        // 次要文字（白54%）
  static const Color line = Color(0x1FFFFFFF);         // 分隔线（白12%）

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: primary,
      scaffoldBackgroundColor: paper,
    );

    final scheme = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: const Color(0xFF04210F),
      primaryContainer: const Color(0xFF1E4A31),
      onPrimaryContainer: const Color(0xFFB8F0CD),
      secondary: const Color(0xFF9CD3AE),
      surface: paper,
      onSurface: ink,
      surfaceContainerLowest: const Color(0xFF14211A),
      surfaceContainerLow: const Color(0xFF182721),
      surfaceContainer: const Color(0xFF1C2B24),
      surfaceContainerHigh: const Color(0xFF21322A),
      surfaceContainerHighest: const Color(0xFF263830),
      onSurfaceVariant: muted,
      outline: const Color(0x33FFFFFF),
      outlineVariant: const Color(0x1FFFFFFF),
      error: const Color(0xFFE86A6A),
    );

    return base.copyWith(
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: muted),
        titleTextStyle: const TextStyle(
          color: ink,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0x2E1B241E),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        textColor: ink,
        iconColor: muted,
        subtitleTextStyle: const TextStyle(color: muted, fontSize: 11.5),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.white.withOpacity(0.20),
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? ink : Colors.white.withOpacity(0.55),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: sel ? ink : Colors.white.withOpacity(0.55),
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E2C24),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF2A3A31),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
    );
  }
}

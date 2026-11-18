import 'package:flutter/material.dart';

/// 克制的配色：暖白底 + 墨绿主色，不用渐变、不堆装饰
class AppTheme {
  static const Color ink = Color(0xFF1F2421);
  static const Color paper = Color(0xFFFAF8F3);
  static const Color primary = Color(0xFF2F6B4F);
  static const Color accent = Color(0xFFB4552D);
  static const Color muted = Color(0xFF8A8578);
  static const Color line = Color(0xFFE4DFD3);

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: primary,
      scaffoldBackgroundColor: paper,
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w600),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
    );
  }
}

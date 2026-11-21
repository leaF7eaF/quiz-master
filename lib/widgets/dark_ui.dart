import 'package:flutter/material.dart';
import 'scenic_background.dart';

/// 深色界面统一配色
class DarkC {
  static const bg = Color(0xFF0E1A14);
  static const bgTop = Color(0xFF16241C);
  static const ink = Colors.white;
  static const sub = Color(0x8AFFFFFF); // 白 54%
  static const faint = Color(0x5CFFFFFF); // 白 36%
  static const card = Color(0x2E1B241E); // 深色玻璃
  static const border = Color(0x21FFFFFF); // 白 13%
  static const green = Color(0xFF5FD08A);
  static const orange = Color(0xFFE8A44A);
  static const red = Color(0xFFE86A6A);
  static const track = Color(0x1FFFFFFF); // 进度条底
}

/// 深色页面外壳：风景背景 + 透明 AppBar + 白字主题
class DarkScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? bottomNav;

  const DarkScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBack = false,
    this.bottomNav,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkC.bg,
      extendBody: true,
      body: Stack(
        children: [
          const ScenicBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(showBack ? 4 : 20, 8, 12, 8),
                  child: Row(
                    children: [
                      if (showBack)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              size: 18, color: DarkC.sub),
                          onPressed: () => Navigator.pop(context),
                        ),
                      Text(title,
                          style: const TextStyle(
                              color: DarkC.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      ...?actions,
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNav,
    );
  }
}

/// 深色玻璃面板（不用模糊，滚动流畅）
class DarkPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const DarkPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: DarkC.card,
        borderRadius: r,
        border: Border.all(color: DarkC.border, width: 1),
      ),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: r, onTap: onTap, child: body),
    );
  }
}

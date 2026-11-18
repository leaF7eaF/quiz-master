import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'heatmap_screen.dart';
import 'wrong_screen.dart';
import '../widgets/glass.dart';
import '../theme/app_theme.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _i = 0;

  static const _pages = [
    HomeScreen(),
    StatsScreen(),
    HeatmapScreen(),
    WrongScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景铺一层柔和光晕，玻璃效果才看得出来
      body: Stack(
        children: [
          const _AmbientBackground(),
          // 切换页面时淡入（保留各页状态用 IndexedStack 的思路改为延迟保活）
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.012),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey<int>(_i),
              child: _pages[_i],
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: GlassBar(
        child: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (v) => setState(() => _i = v),
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          // 选中项加个更明显的指示胶囊
          indicatorColor: AppTheme.primary.withOpacity(0.18),
          indicatorShape: const StadiumBorder(),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: '统计'),
          NavigationDestination(icon: Icon(Icons.grid_on_outlined), selectedIcon: Icon(Icons.grid_on), label: '热力图'),
            NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: '错题'),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}

/// 柔和光晕背景（不抢内容，只为让玻璃有东西可"透"）
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.paper),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _blob(220, const Color(0xFF2F6B4F), 0.10),
          ),
          Positioned(
            top: 220,
            left: -70,
            child: _blob(260, const Color(0xFFB4552D), 0.07),
          ),
          Positioned(
            bottom: 40,
            right: -50,
            child: _blob(240, const Color(0xFF2F6B4F), 0.08),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ),
      ),
    );
  }
}

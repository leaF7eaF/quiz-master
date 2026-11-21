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
      body: Stack(
        children: [
          const AmbientBackground(),
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
      extendBody: false,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '首页'),
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: '统计'),
          NavigationDestination(
              icon: Icon(Icons.grid_on_outlined),
              selectedIcon: Icon(Icons.grid_on),
              label: '热力图'),
          NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
                label: '错题'),
          ],
        ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'heatmap_screen.dart';
import 'wrong_screen.dart';

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
      extendBody: true,
      body: IndexedStack(index: _i, children: _pages),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: Colors.black.withOpacity(0.40),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                height: 68,
                indicatorColor: Colors.white.withOpacity(0.20),
                indicatorShape: const StadiumBorder(),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final sel = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                    color:
                        sel ? Colors.white : Colors.white.withOpacity(0.55),
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final sel = states.contains(WidgetState.selected);
                  return IconThemeData(
                    size: 24,
                    color:
                        sel ? Colors.white : Colors.white.withOpacity(0.55),
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _i,
                onDestinationSelected: (v) => setState(() => _i = v),
                backgroundColor: Colors.transparent,
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
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// 风景照片背景：每次启动随机选一张
/// 上面叠渐变蒙版，保证白色文字可读
class ScenicBackground extends StatelessWidget {
  const ScenicBackground({super.key});

  static const List<String> _images = [
    'assets/images/scenic_1.jpg', // 云雾山谷
    'assets/images/scenic_2.jpg', // 云海日出
    'assets/images/scenic_3.jpg', // 晨雾森林
    'assets/images/scenic_4.jpg', // 星空雪山
  ];

  /// App 生命周期内只随机一次，避免每次重建换图
  static final int _pick = Random().nextInt(_images.length);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _images[_pick],
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          // 图片加载失败时退回深色底
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: Color(0xFF1B2838)),
        ),
        // 整体压暗，让白字和小字都清楚
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.42),
                Colors.black.withOpacity(0.28),
                Colors.black.withOpacity(0.58),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// 深色玻璃卡片：背景图上的半透明面板
class DarkGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? tint;

  const DarkGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 16,
    this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final body = ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? Colors.white.withOpacity(0.13),
            borderRadius: r,
            border: Border.all(
              color: Colors.white.withOpacity(0.16),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: r, onTap: onTap, child: body),
    );
  }
}

import 'dart:math';
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
    'assets/images/scenic_5.jpg', // 海浪航拍
    'assets/images/scenic_6.jpg', // 沙漠峡谷
    'assets/images/scenic_7.jpg', // 极光雪原
    'assets/images/scenic_8.jpg', // 雾湖金树
    'assets/images/scenic_9.jpg', // 深空星云
    'assets/images/scenic_10.jpg', // 雪山湖泊
    'assets/images/scenic_11.jpg', // 草原落日
    'assets/images/scenic_12.jpg', // 层叠远山
    'assets/images/scenic_13.jpg', // 海岸日落
    'assets/images/scenic_14.jpg', // 冰川森林
    'assets/images/scenic_15.jpg', // 雾中孤山
    'assets/images/scenic_16.jpg', // 红岩日落
    'assets/images/scenic_17.jpg', // 雪山高崖
    'assets/images/scenic_18.jpg', // 海面云霞
    'assets/images/scenic_19.jpg', // 湖山暮色
    'assets/images/scenic_20.jpg', // 碧湖小船
    'assets/images/scenic_21.jpg', // 雨林栈道
    'assets/images/scenic_22.jpg', // 银河
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
    // 不用 BackdropFilter：列表里多个卡片同时模糊会拖垮滚动帧率
    // 用半透明色 + 细边，观感接近而且滚动顺滑
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? const Color(0x2E1B241E),
        borderRadius: r,
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
          width: 1,
        ),
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

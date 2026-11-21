import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 轻玻璃卡片：半透明底 + 背景模糊 + 细边高光
/// 没有用强模糊（sigma 小），低端机也不卡
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur; // 模糊强度，8~12 比较自然
  final Color? tint; // 覆盖色，默认白色半透明
  final bool bordered;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 12,
    this.blur = 10,
    this.tint,
    this.bordered = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(radius),
            border: bordered
                ? Border.all(color: Colors.white.withOpacity(0.7), width: 1)
                : null,
            // 玻璃的内外高光，模仿边缘反光
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppTheme.ink.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

/// 玻璃底栏：底部导航用，内容从底下透出来
class GlassBar extends StatelessWidget {
  final Widget child;
  const GlassBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            // 关键：比页面背景(纸白)更"灰"一档，才看得出是一块面板
            color: const Color(0xFFF1EEE6).withOpacity(0.97),
            border: Border(
              top: BorderSide(
                color: AppTheme.ink.withOpacity(0.10),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ink.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 柔和光晕背景（玻璃卡片需要它才有层次）
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

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

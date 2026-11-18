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
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.paper.withOpacity(0.72),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.8), width: 1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

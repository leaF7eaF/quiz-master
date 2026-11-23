import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Material You 卡片
/// 干净纯色块：无边框、无阴影、无半透明。靠色差和留白分层
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur; // 保留参数兼容
  final Color? tint;
  final bool bordered; // 保留参数兼容，M3 下不使用
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 14,
    this.blur = 0,
    this.tint,
    this.bordered = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(radius);

    final body = Container(
      decoration: BoxDecoration(
        color: tint ?? scheme.surfaceContainerLowest,
        borderRadius: r,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

/// 底部导航：M3 纯色 + 顶部细线（不用模糊）
class GlassBar extends StatelessWidget {
  final Widget child;
  const GlassBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// 胶囊标签
class GlassPill extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  const GlassPill({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}

/// M3 内容卡片（与 GlassCard 同实现，保留给内容页用）
class MdCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final bool bordered;
  final VoidCallback? onTap;

  const MdCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 14,
    this.color,
    this.bordered = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(radius);
    final body = Container(
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerLow,
        borderRadius: r,
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: r, onTap: onTap, child: body),
    );
  }
}

/// 纯色背景（M3 没有光晕）
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(color: scheme.surface);
  }
}

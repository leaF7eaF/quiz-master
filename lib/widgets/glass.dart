import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ===== 液态玻璃（用于外壳层：首页、导航、列表）=====
/// 强模糊 + 顶部斜射高光 + 亮边 + 柔和外投影
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? tint;
  final bool bordered;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.blur = 24,
    this.tint,
    this.bordered = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);

    final body = ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: tint != null
                        ? [tint!.withOpacity(0.88), tint!]
                        : [
                            Colors.white.withOpacity(0.72),
                            Colors.white.withOpacity(0.42),
                          ],
                  ),
                  borderRadius: r,
                  border: bordered
                      ? Border.all(
                          color: Colors.white.withOpacity(0.9), width: 1.2)
                      : null,
                ),
              ),
            ),
            // 顶部斜射高光
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: r,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.30),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.32],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    final withShadow = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.45),
            blurRadius: 1.5,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: AppTheme.ink.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: body,
    );

    if (onTap == null) return withShadow;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: r, onTap: onTap, child: withShadow),
    );
  }
}

/// 液态玻璃底部导航外壳
class GlassBar extends StatelessWidget {
  final Widget child;
  const GlassBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.80),
                const Color(0xFFF1F5EE).withOpacity(0.94),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.95), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ink.withOpacity(0.09),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: child,
        ),
      ),
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
    final c = color ?? AppTheme.primary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: c.withOpacity(0.16), width: 1),
      ),
      child: child,
    );
  }
}

/// 柔和光晕背景（让玻璃有色彩可透）
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.paper),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: _blob(300, const Color(0xFF2F6B4F), 0.15),
          ),
          Positioned(
            top: 180,
            left: -110,
            child: _blob(320, const Color(0xFFB4552D), 0.10),
          ),
          Positioned(
            top: 460,
            right: -80,
            child: _blob(280, const Color(0xFF3F7F9F), 0.09),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _blob(300, const Color(0xFF2F6B4F), 0.12),
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

/// ===== Material You 卡片（用于内容层：答题、释义、解析）=====
/// 纯色表面 + 细边，保证长时间阅读不累
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
    this.radius = 16,
    this.color,
    this.bordered = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(radius);
    final body = Container(
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerLowest,
        borderRadius: r,
        border: bordered
            ? Border.all(color: scheme.outlineVariant.withOpacity(0.6), width: 1)
            : null,
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

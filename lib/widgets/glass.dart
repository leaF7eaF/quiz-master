import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 液态玻璃卡片
/// 特征：强模糊 + 顶部斜射高光 + 亮边 + 柔和外投影
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
    this.blur = 26,
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
            // 玻璃本体（渐变让上下厚度不同，像真的玻璃片）
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: tint != null
                        ? [tint!.withOpacity(0.85), tint!]
                        : [
                            Colors.white.withOpacity(0.72),
                            Colors.white.withOpacity(0.40),
                          ],
                  ),
                  borderRadius: r,
                  border: bordered
                      ? Border.all(color: Colors.white.withOpacity(0.92), width: 1.2)
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
                        Colors.white.withOpacity(0.32),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.32],
                    ),
                  ),
                ),
              ),
            ),
            // 内容
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    // 外投影单独放，避免被 ClipRRect 裁掉
    final withShadow = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 1.5,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: AppTheme.ink.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: body,
    );

    if (onTap == null) return withShadow;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: withShadow,
      ),
    );
  }
}

/// 液态玻璃底栏（导航用）
class GlassBar extends StatelessWidget {
  final Widget child;
  const GlassBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.82),
                const Color(0xFFF4F1E9).withOpacity(0.94),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.95), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ink.withOpacity(0.10),
                blurRadius: 22,
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

/// 胶囊：用于标签、chip
class GlassPill extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  const GlassPill({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: (color ?? AppTheme.primary).withOpacity(0.18),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

/// 柔和光晕背景（液态玻璃需要色彩流动才显得通透）
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
            child: _blob(300, const Color(0xFF2F6B4F), 0.16),
          ),
          Positioned(
            top: 180,
            left: -110,
            child: _blob(320, const Color(0xFFB4552D), 0.11),
          ),
          Positioned(
            top: 460,
            right: -80,
            child: _blob(280, const Color(0xFF3F7F9F), 0.10),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _blob(300, const Color(0xFF2F6B4F), 0.13),
          ),
          Positioned(
            top: 60,
            left: 40,
            child: _blob(180, const Color(0xFFD4A24C), 0.07),
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
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

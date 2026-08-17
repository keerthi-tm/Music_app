import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:landingpage/src/utils/colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool isDarkMode;
  final double blur;
  final Border? borderOverride;

  const GlassContainer({
    super.key,
    required this.child,
    required this.isDarkMode,
    this.radius = 20,
    this.padding = const EdgeInsets.all(20),
    this.blur = 18,
    this.borderOverride,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;

    final Color fill = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);

    final Color borderColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border:
                borderOverride ?? Border.all(color: borderColor, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

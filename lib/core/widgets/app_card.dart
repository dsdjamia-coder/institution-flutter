import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool isElevated;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.isElevated = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? AppRadius.md;
    final bg = gradient == null ? (color ?? Colors.white) : null;
    final border = borderColor ?? AppColors.lightBorder;

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        gradient: gradient,
        borderRadius: r,
        border: Border.all(color: border),
        boxShadow: isElevated ? AppColors.cardShadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: r,
          child: InkWell(
            onTap: onTap,
            borderRadius: r,
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(padding: margin, child: cardContent);
  }
}

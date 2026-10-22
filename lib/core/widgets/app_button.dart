import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outlined, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = AppButtonVariant.primary,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.slate100;
        fg = AppColors.slate800;
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = AppColors.slate700;
        border = const BorderSide(color: AppColors.slate300);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.primary;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
    }

    final disabled = onPressed == null || isLoading;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(color: fg),
          ),
        ],
      );
    }

    final btnWidget = Material(
      color: disabled ? bg.withOpacity(0.6) : bg,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: AppRadius.sm,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: AppRadius.sm,
            border: border != null ? Border.fromBorderSide(border) : null,
          ),
          alignment: Alignment.center,
          child: childContent,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: btnWidget);
    }
    return btnWidget;
  }
}

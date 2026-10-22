import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
  });

  factory AppBadge.status(String status) {
    Color bg;
    Color fg;
    Color border;

    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'success':
      case 'approved':
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        border = AppColors.successBorder;
        break;
      case 'discontinued':
      case 'failed':
      case 'inactive':
      case 'rejected':
        bg = AppColors.errorLight;
        fg = AppColors.errorDark;
        border = AppColors.errorBorder;
        break;
      case 'alumni':
        bg = const Color(0xFFFAF5FF);
        fg = const Color(0xFF6B21A8);
        border = const Color(0xFFE9D5FF);
        break;
      case 'pending':
      case 'super admin':
      case 'admin':
      case 'warning':
        bg = AppColors.warningLight;
        fg = AppColors.warningDark;
        border = AppColors.warningBorder;
        break;
      default:
        bg = AppColors.slate100;
        fg = AppColors.slate700;
        border = AppColors.slate200;
    }

    return AppBadge(
      label: status,
      backgroundColor: bg,
      textColor: fg,
      borderColor: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.slate100,
        borderRadius: AppRadius.xs,
        border: Border.all(color: borderColor ?? Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? AppColors.slate700),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor ?? AppColors.slate700,
            ),
          ),
        ],
      ),
    );
  }
}

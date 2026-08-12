import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';

/// Botón pill negro (o rojo si [isDestructive]) del design system.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isDestructive = false,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDestructive;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDestructive ? AppColors.error : AppColors.primary;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
        elevation: 0,
        padding: effectivePadding,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.onPrimary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.onPrimary),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: AppTypography.subtitleBold.copyWith(color: AppColors.onPrimary),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';

enum StatusChipVariant { success, pending, error, neutral, info }

/// Tag de estado en mayúsculas bold — ej. ENTREGADO/PENDIENTE.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.variant});

  final String label;
  final StatusChipVariant variant;

  Color get _color {
    switch (variant) {
      case StatusChipVariant.success:
        return AppColors.accentGreen;
      case StatusChipVariant.pending:
        return AppColors.accentAmber;
      case StatusChipVariant.error:
        return AppColors.error;
      case StatusChipVariant.info:
        return AppColors.accentBlue;
      case StatusChipVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final textColor = AppColors.pastelText(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pastelOf(color),
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelBold.copyWith(color: textColor, fontSize: 11),
      ),
    );
  }
}

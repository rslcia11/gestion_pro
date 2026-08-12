import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Pill con número — ej. cantidad de pendientes.
class CounterBadge extends StatelessWidget {
  const CounterBadge({super.key, required this.count, this.color});

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color ?? AppColors.accentPink, borderRadius: BorderRadius.circular(999)),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

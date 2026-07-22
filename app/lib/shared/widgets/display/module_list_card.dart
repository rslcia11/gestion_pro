import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import 'counter_badge.dart';

/// Ícono con badge de color + título + subtítulo + chevron.
/// Patrón "Módulos" visto en el Panel de Administración del Figma.
class ModuleListCard extends StatelessWidget {
  const ModuleListCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    this.badgeCount = 0,
    this.onTap,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final int badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.pastelOf(iconBackgroundColor),
                    borderRadius: BorderRadius.circular(AppRadii.badge),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconBackgroundColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.subtitleBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CounterBadge(count: badgeCount),
                const SizedBox(width: 4),
                const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

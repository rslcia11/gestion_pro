import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import 'user_avatar.dart';

/// Avatar + nombre + descripción + timestamp + StatusChip opcional.
/// Patrón visto en Premios/Actividad del Figma.
class ActivityListCard extends StatelessWidget {
  const ActivityListCard({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    this.avatarUrl,
    this.avatarInitials,
    this.trailing,
    this.actions,
  });

  final String title;
  final String description;
  final String timestamp;
  final String? avatarUrl;
  final String? avatarInitials;
  final Widget? trailing;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(imageUrl: avatarUrl, initials: avatarInitials, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.subtitleBold.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(description, style: AppTypography.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(timestamp, style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actions != null) ...[
            const SizedBox(height: 12),
            actions!,
          ],
        ],
      ),
    );
  }
}

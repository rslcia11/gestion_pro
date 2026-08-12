import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Avatar circular con fallback a iniciales si no hay foto.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 52,
    this.backgroundColor,
  });

  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final resolvedBackground = backgroundColor ?? AppColors.accentPurple;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.pastelOf(resolvedBackground),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              (initials ?? '?').toUpperCase(),
              style: AppTypography.subtitleBold.copyWith(
                color: resolvedBackground,
                fontSize: size * 0.35,
              ),
            ),
    );
  }
}

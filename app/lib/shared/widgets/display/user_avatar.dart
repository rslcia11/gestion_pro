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
    this.backgroundColor = AppColors.accentPurple,
  });

  final String? imageUrl;
  final String? initials;
  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.pastelOf(backgroundColor),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              (initials ?? '?').toUpperCase(),
              style: AppTypography.subtitleBold.copyWith(
                color: backgroundColor,
                fontSize: size * 0.35,
              ),
            ),
    );
  }
}

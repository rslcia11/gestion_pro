import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Botón circular solo-ícono — ej. flecha "volver", "editar".
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? AppColors.background,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: size * 0.5, color: iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}

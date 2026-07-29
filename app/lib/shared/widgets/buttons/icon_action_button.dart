import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Botón circular solo-ícono — ej. flecha "volver", "editar".
///
/// [tooltip] es obligatorio: es el único label que un lector de pantalla
/// tiene para un botón que no lleva texto. [size] por defecto cumple el
/// mínimo táctil (48dp Android / ≥44pt iOS).
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.backgroundColor = AppColors.background,
    this.iconColor = AppColors.textPrimary,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: ExcludeSemantics(
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: size,
            height: size,
            child: Material(
              color: backgroundColor,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: Icon(icon, size: size * 0.5, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

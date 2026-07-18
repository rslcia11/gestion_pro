import 'package:flutter/material.dart';

/// Sombras del design system "Gestión Pro" (extraídas del Figma de referencia).
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];
}

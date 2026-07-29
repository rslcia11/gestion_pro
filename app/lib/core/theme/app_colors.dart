import 'package:flutter/material.dart';

/// Paleta de colores del design system "Gestión Pro" (extraída de Figma).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF5F5F5);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFF3F4F6);

  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF171A1F);
  static const Color textSecondary = Color(0xFF565D6D);

  static const Color error = Color(0xFFE11D48);

  // Acentos usados en badges de módulo/categoría.
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF9333EA);
  static const Color accentPink = Color(0xFFDB2777);
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color accentRose = Color(0xFFE11D48);
  static const Color accentBlue = Color(0xFF2563EB);

  /// Versión pastel (fondo del badge circular) de cada acento.
  static Color pastelOf(Color accent) => accent.withValues(alpha: 0.12);

  /// Versión oscurecida de cada acento con contraste AA (≥4.5:1) para texto
  /// o íconos sobre su propio fondo [pastelOf] — el acento "puro" solo
  /// pasa 1.8–4.5:1 según el color, por debajo del mínimo de WCAG AA.
  static Color pastelText(Color accent) {
    if (accent == accentAmber) return const Color(0xFF9A6307);
    if (accent == accentPurple) return const Color(0xFF9132E7);
    if (accent == accentPink) return const Color(0xFFC5236B);
    if (accent == accentGreen) return const Color(0xFF117D39);
    if (accent == accentOrange) return const Color(0xFFB9460A);
    if (accent == accentBlue) return const Color(0xFF2460E4);
    if (accent == error) return const Color(0xFFCB1A41);
    return accent;
  }
}

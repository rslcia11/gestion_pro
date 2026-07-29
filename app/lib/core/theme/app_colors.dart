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

  // Colores para Modo Oscuro (Dark Theme)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceCardDark = Color(0xFF1E1E1E);
  static const Color borderDark = Color(0xFF2C2C2C);
  static const Color primaryDark = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

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
}

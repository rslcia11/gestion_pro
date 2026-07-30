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

  // --- Variantes "on-light" (texto/ícono seguro sobre blanco) ---
  //
  // El acento a color completo NO siempre cumple el piso de contraste AA
  // (4.5:1) cuando se usa como texto/ícono directamente sobre paper-white o
  // paper-bg: ámbar (~2.1:1) y verde (~3.3:1) fallan; púrpura (~5.4:1) y
  // rosa (~4.6:1) pasan pero rosa queda con un margen muy ajustado. Estas
  // variantes oscurecidas SIEMPRE cumplen 4.5:1+ con margen real — usalas
  // cuando el acento es texto o un ícono chico sobre una superficie blanca,
  // NO para rellenos de badges/tintes (eso sigue siendo `pastelOf`) ni para
  // el acento base sobre su propio tinte al 12%.
  static const Color accentPurpleOnLight = Color(0xFF7E22CE); // ~6.98:1
  static const Color accentPinkOnLight = Color(0xFFBE185D); // ~6.04:1
  static const Color accentAmberOnLight = Color(0xFF8A6D00); // ~4.92:1
  static const Color accentGreenOnLight = Color(0xFF15803D); // ~5.02:1

  /// Devuelve la variante "on-light" documentada de un acento conocido
  /// (útil cuando se tiene una `Color` en una variable, ej. un acento
  /// rotativo, en vez de la constante en sí). Si el acento no tiene
  /// variante documentada, lo devuelve sin cambios — antes de usar un
  /// acento nuevo como texto sobre blanco, agregale su variante acá.
  static Color onLightOf(Color accent) {
    if (accent == accentPurple) return accentPurpleOnLight;
    if (accent == accentPink) return accentPinkOnLight;
    if (accent == accentAmber) return accentAmberOnLight;
    if (accent == accentGreen) return accentGreenOnLight;
    return accent;
  }
}

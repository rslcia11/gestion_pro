import 'package:flutter/material.dart';

import 'app_brightness.dart';

/// Paleta de colores del design system "Gestión Pro" (extraída de Figma).
///
/// Cada token tiene una variante `xxxLight`/`xxxDark` explícita (usada por
/// `AppTheme` para construir sus dos `ThemeData`) y un getter público del
/// mismo nombre que tenía el token original, que resuelve dinámicamente
/// contra [AppBrightness.current]. Los ~700 call-sites existentes
/// (`AppColors.textPrimary`, etc.) siguen compilando sin cambios.
class AppColors {
  AppColors._();

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static Color get background => _pick(backgroundLight, backgroundDark);

  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color surfaceCardDark = Color(0xFF1E1E1E);
  static Color get surfaceCard => _pick(surfaceCardLight, surfaceCardDark);

  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFF2C2C30);
  static Color get border => _pick(borderLight, borderDark);

  // "Tinta sólida decisiva" del design system: negra sobre blanco en light,
  // invertida a blanco-hueso sobre negro en dark (negro-sobre-negro sería
  // invisible).
  static const Color primaryLight = Color(0xFF000000);
  static const Color primaryDark = Color(0xFFF5F5F5);
  static Color get primary => _pick(primaryLight, primaryDark);

  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF121212);
  static Color get onPrimary => _pick(onPrimaryLight, onPrimaryDark);

  static const Color textPrimaryLight = Color(0xFF171A1F);
  static const Color textPrimaryDark = Color(0xFFECEDEE);
  static Color get textPrimary => _pick(textPrimaryLight, textPrimaryDark);

  static const Color textSecondaryLight = Color(0xFF565D6D);
  static const Color textSecondaryDark = Color(0xFFA1A7B3);
  static Color get textSecondary => _pick(textSecondaryLight, textSecondaryDark);

  static const Color errorLight = Color(0xFFE11D48);
  static const Color errorDark = Color(0xFFF43F5E);
  static Color get error => _pick(errorLight, errorDark);

  // Acentos usados en badges de módulo/categoría. La variante dark es un
  // paso más claro en su escala (los tonos saturados de light leen "sucios"
  // sobre fondo casi negro).
  static const Color accentAmberLight = Color(0xFFF59E0B);
  static const Color accentAmberDark = Color(0xFFFBBF24);
  static Color get accentAmber => _pick(accentAmberLight, accentAmberDark);

  static const Color accentPurpleLight = Color(0xFF9333EA);
  static const Color accentPurpleDark = Color(0xFFA855F7);
  static Color get accentPurple => _pick(accentPurpleLight, accentPurpleDark);

  static const Color accentPinkLight = Color(0xFFDB2777);
  static const Color accentPinkDark = Color(0xFFEC4899);
  static Color get accentPink => _pick(accentPinkLight, accentPinkDark);

  static const Color accentGreenLight = Color(0xFF16A34A);
  static const Color accentGreenDark = Color(0xFF22C55E);
  static Color get accentGreen => _pick(accentGreenLight, accentGreenDark);

  static const Color accentOrangeLight = Color(0xFFEA580C);
  static const Color accentOrangeDark = Color(0xFFFB923C);
  static Color get accentOrange => _pick(accentOrangeLight, accentOrangeDark);

  static const Color accentRoseLight = Color(0xFFE11D48);
  static const Color accentRoseDark = Color(0xFFF43F5E);
  static Color get accentRose => _pick(accentRoseLight, accentRoseDark);

  static const Color accentBlueLight = Color(0xFF2563EB);
  static const Color accentBlueDark = Color(0xFF3B82F6);
  static Color get accentBlue => _pick(accentBlueLight, accentBlueDark);

  static Color _pick(Color light, Color dark) =>
      AppBrightness.current == Brightness.dark ? dark : light;

  /// Versión pastel (fondo del badge circular) de cada acento. En dark el
  /// alpha sube de 12% a 20% porque un tinte al 12% se pierde ópticamente
  /// contra una superficie casi negra.
  static Color pastelOf(Color accent) => accent.withValues(
        alpha: AppBrightness.current == Brightness.dark ? 0.20 : 0.12,
      );

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
  ///
  /// En dark mode el acento base ya es su variante clara (ver getters de
  /// arriba) y contrasta bien sobre superficie oscura sin oscurecerlo, así
  /// que se devuelve tal cual.
  static Color onLightOf(Color accent) {
    if (AppBrightness.current == Brightness.dark) return accent;
    if (accent == accentPurpleLight) return accentPurpleOnLight;
    if (accent == accentPinkLight) return accentPinkOnLight;
    if (accent == accentAmberLight) return accentAmberOnLight;
    if (accent == accentGreenLight) return accentGreenOnLight;
    return accent;
  }
}

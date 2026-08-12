import 'package:flutter/material.dart';

import 'app_brightness.dart';

/// Sombras del design system "Gestión Pro" (extraídas del Figma de referencia).
///
/// En dark mode una sombra negra semitransparente es casi invisible sobre
/// una superficie ya oscura, así que se reemplaza por un "glow" blanco de
/// bajo alpha (convención M3 para superficies elevadas en dark).
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  static bool get _isDark => AppBrightness.current == Brightness.dark;
}

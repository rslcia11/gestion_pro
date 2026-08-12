import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_colors.dart';

/// Luminancia relativa WCAG 2.x (sRGB) de un canal ya normalizado a 0..1.
double _linearizeChannel(double c) {
  if (c <= 0.03928) return c / 12.92;
  return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double _relativeLuminance(Color color) {
  final r = _linearizeChannel(color.r);
  final g = _linearizeChannel(color.g);
  final b = _linearizeChannel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Ratio de contraste WCAG 2.x entre dos colores (siempre ≥ 1).
double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a) + 0.05;
  final lb = _relativeLuminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}

void main() {
  group('AppColors.onLightOf', () {
    test('returns the documented OnLight variant for each known accent', () {
      expect(AppColors.onLightOf(AppColors.accentPurple), AppColors.accentPurpleOnLight);
      expect(AppColors.onLightOf(AppColors.accentPink), AppColors.accentPinkOnLight);
      expect(AppColors.onLightOf(AppColors.accentAmber), AppColors.accentAmberOnLight);
      expect(AppColors.onLightOf(AppColors.accentGreen), AppColors.accentGreenOnLight);
    });

    test('falls back to the input color when there is no documented variant', () {
      const unmapped = Color(0xFF123456);
      expect(AppColors.onLightOf(unmapped), unmapped);
      expect(AppColors.onLightOf(AppColors.accentBlue), AppColors.accentBlue);
    });

    test('every OnLight variant meets the 4.5:1 WCAG AA contrast floor on white', () {
      const white = Color(0xFFFFFFFF);
      const variants = [
        AppColors.accentPurpleOnLight,
        AppColors.accentPinkOnLight,
        AppColors.accentAmberOnLight,
        AppColors.accentGreenOnLight,
      ];

      for (final variant in variants) {
        final ratio = _contrastRatio(variant, white);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: 'Color $variant contrast against white was only ${ratio.toStringAsFixed(2)}:1',
        );
      }
    });
  });
}

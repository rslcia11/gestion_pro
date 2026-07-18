import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Escala tipográfica del design system "Gestión Pro".
///
/// Poppins para headlines/CTA, Inter para body/labels — así aparece en el
/// Figma de referencia (2 casos sueltos de "Plus Jakarta Sans" en el archivo
/// original son error del diseñador, se ignoran).
class AppTypography {
  AppTypography._();

  static TextStyle get displayBold => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get titleBold => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get subtitleBold => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get bodyRegular => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  /// Para tags de estado en mayúsculas (ENTREGADO/PENDIENTE).
  static TextStyle get labelBold => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
}

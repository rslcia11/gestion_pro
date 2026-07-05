import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_typography.dart';

class AppTheme {
  // Animaciones centralizadas (DRY / NO_HARDCODING)
  static const Duration animDurationStandard = Duration(milliseconds: 600);
  static const Duration animDurationQuick = Duration(milliseconds: 400);
  static const Duration animDurationSlow = Duration(milliseconds: 800);
  static const Curve animCurveStandard = Curves.easeOutQuart;
  static const Curve animCurveElastic = Curves.easeOutBack;
  static const double animSlideYBegin = 0.1;

  static IconData getCategoryIcon(String? categoryName) {
    final name = (categoryName ?? '').toLowerCase();
    
    if (name.contains('cafe') || name.contains('panaderia') || name.contains('pasteleria')) return Icons.local_cafe;
    if (name.contains('restaurante') || name.contains('bar')) return Icons.restaurant;
    if (name.contains('disco') || name.contains('club')) return Icons.nightlife;
    if (name.contains('peluqueria') || name.contains('barberia') || name.contains('estetica')) return Icons.content_cut;
    if (name.contains('gym') || name.contains('deportivo')) return Icons.fitness_center;
    if (name.contains('spa')) return Icons.spa;
    if (name.contains('moda') || name.contains('accesorios') || name.contains('calzado')) return Icons.shopping_bag;
    if (name.contains('ferreteria')) return Icons.home_repair_service;
    if (name.contains('lavanderia') || name.contains('tintoreria')) return Icons.local_laundry_service;
    if (name.contains('taller') || name.contains('mecanico') || name.contains('lubricadora')) return Icons.build;
    if (name.contains('farmacia')) return Icons.medication;
    if (name.contains('veterinaria') || name.contains('pet')) return Icons.pets;
    if (name.contains('tecnologia')) return Icons.devices;
    
    return Icons.store;
  }

  // Soporte y Contacto
  static const String supportWhatsApp = '+593995371895';
  static const String supportEmail = 'fidelitysistemadefidelizacion@gmail.com';

  static Duration animDelayStaggered(int index) => Duration(milliseconds: index * 50);

  /// Theme canonical del design system "Gestión Pro" — consume los tokens de
  /// app_colors/app_typography/app_radii.
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.accentPurple,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.textPrimary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleBold,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.textSecondary,
      ),

      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        headlineLarge: AppTypography.displayBold,
        headlineMedium: AppTypography.titleBold,
        titleLarge: AppTypography.titleBold,
        titleMedium: AppTypography.subtitleBold,
        bodyLarge: AppTypography.bodyRegular,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.labelBold,
      ),
    );
  }

}


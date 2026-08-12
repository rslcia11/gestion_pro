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
  static const String supportEmail = 'soporte@dondesiempre.app';

  static Duration animDelayStaggered(int index) => Duration(milliseconds: index * 50);

  /// Theme canonical del design system "Gestión Pro" (light) — consume los
  /// tokens de app_colors/app_typography/app_radii.
  static ThemeData get theme => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.backgroundLight,
        surfaceCard: AppColors.surfaceCardLight,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        secondary: AppColors.accentPurpleLight,
        error: AppColors.errorLight,
      );

  /// Variante dark del theme canonical — mismo shape que [theme], solo
  /// cambian los colores.
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.backgroundDark,
        surfaceCard: AppColors.surfaceCardDark,
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        secondary: AppColors.accentPurpleDark,
        error: AppColors.errorDark,
      );

  // NOTA: nunca leer los getters dinámicos de AppColors (AppColors.primary,
  // etc.) acá adentro — theme y darkTheme se construyen los dos en el mismo
  // build pass sin importar cuál esté activo, así que si ambos leyeran el
  // mismo AppBrightness.current terminarían con el mismo ColorScheme. Los
  // colores siempre entran como parámetros explícitos (xxxLight/xxxDark).
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surfaceCard,
    required Color primary,
    required Color onPrimary,
    required Color textPrimary,
    required Color textSecondary,
    required Color secondary,
    required Color error,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surfaceCard,
        onSurface: textPrimary,
      ),

      scaffoldBackgroundColor: background,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleBold.copyWith(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
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
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide(color: textPrimary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide(color: textPrimary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide(color: primary, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: textSecondary,
        errorMaxLines: 3,
      ),

      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        headlineLarge: AppTypography.displayBold.copyWith(color: textPrimary),
        headlineMedium: AppTypography.titleBold.copyWith(color: textPrimary),
        titleLarge: AppTypography.titleBold.copyWith(color: textPrimary),
        titleMedium: AppTypography.subtitleBold.copyWith(color: textPrimary),
        bodyLarge: AppTypography.bodyRegular.copyWith(color: textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: textSecondary),
        bodySmall: AppTypography.caption.copyWith(color: textSecondary),
        labelLarge: AppTypography.labelBold.copyWith(color: textPrimary),
      ),
    );
  }
}

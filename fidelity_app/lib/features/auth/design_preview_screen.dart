import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../admin/admin_dashboard_screen.dart';
import '../business/dashboard/business_dashboard_screen.dart';
import '../cards/my_cards_screen.dart';

/// TEMPORAL: reemplaza el login mientras la app está desconectada de
/// Supabase (ver [AuthWrapper]/`designPreviewMode`). Deja elegir un rol y
/// entra directo a esa home, sin auth ni backend — pensada para que alguien
/// externo revise SOLO el diseño de las pantallas.
class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadii.badge),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.zap, color: AppColors.onPrimary, size: 32),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Donde Siempre', style: AppTypography.displayBold),
                const SizedBox(height: AppSpacing.sm),
                const StatusChip(label: 'En desarrollo', variant: StatusChipVariant.pending),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Vista previa de diseño — sin conexión a backend.\nElegí un rol para ver el contenido.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                ModuleListCard(
                  icon: LucideIcons.user,
                  iconBackgroundColor: AppColors.accentAmber,
                  title: 'Cliente',
                  subtitle: 'Tarjetas, QR y premios',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyCardsScreen()),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ModuleListCard(
                  icon: LucideIcons.store,
                  iconBackgroundColor: AppColors.accentPurple,
                  title: 'Dueño de Negocio',
                  subtitle: 'Panel completo de negocio',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BusinessDashboardScreen()),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ModuleListCard(
                  icon: LucideIcons.shieldCheck,
                  iconBackgroundColor: AppColors.accentGreen,
                  title: 'Administrador',
                  subtitle: 'Panel de administración',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

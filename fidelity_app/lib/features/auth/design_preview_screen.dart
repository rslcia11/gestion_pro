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
                    MaterialPageRoute(builder: (_) => const _PreviewBackWrapper(child: MyCardsScreen())),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ModuleListCard(
                  icon: LucideIcons.store,
                  iconBackgroundColor: AppColors.accentPurple,
                  title: 'Dueño de Negocio',
                  subtitle: 'Panel completo de negocio',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _PreviewBackWrapper(child: BusinessDashboardScreen())),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ModuleListCard(
                  icon: LucideIcons.shieldCheck,
                  iconBackgroundColor: AppColors.accentGreen,
                  title: 'Administrador',
                  subtitle: 'Panel de administración',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _PreviewBackWrapper(child: AdminDashboardScreen())),
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

/// Envuelve la home de un rol con un botón flotante para volver al selector
/// de [DesignPreviewScreen]. No se toca el `leading` de cada home (lo usan
/// para el avatar/logo propio), así que la flecha de volver automática de
/// Flutter nunca aparece — este overlay soluciona eso SOLO en modo preview,
/// sin tocar las pantallas reales de cada rol.
class _PreviewBackWrapper extends StatelessWidget {
  const _PreviewBackWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: AppSpacing.md,
          bottom: AppSpacing.md,
          child: SafeArea(
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                onTap: () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.onPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'Volver a vista previa',
                        style: AppTypography.labelBold.copyWith(color: AppColors.onPrimary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

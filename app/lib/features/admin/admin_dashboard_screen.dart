import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'admin_businesses_screen.dart';
import 'admin_users_screen.dart';
import 'admin_activity_screen.dart';
import 'admin_rewards_screen.dart';
import 'admin_qr_stats_screen.dart';
import 'admin_categories_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoading = true;

  // Metrics
  int _totalBusinesses = 0;
  int _totalUsers = 0;
  int _totalScans = 0;
  int _totalRewards = 0;
  int _pendingBusinessesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    setState(() {
      _totalBusinesses = 0;
      _pendingBusinessesCount = 0;
      _totalUsers = 0;
      _totalScans = 0;
      _totalRewards = 0;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconActionButton(icon: LucideIcons.refreshCcw, onPressed: _loadMetrics),
          const SizedBox(width: 4),
          IconActionButton(icon: LucideIcons.logOut, onPressed: _logout),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadMetrics,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen General', style: AppTypography.titleBold),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminBusinessesScreen()),
                                ),
                                child: StatCard(
                                  icon: LucideIcons.store,
                                  label: 'Negocios',
                                  value: _totalBusinesses.toString(),
                                  accentColor: AppColors.accentPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                                ),
                                child: StatCard(
                                  icon: LucideIcons.users,
                                  label: 'Clientes',
                                  value: _totalUsers.toString(),
                                  accentColor: AppColors.accentAmber,
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminActivityScreen()),
                                ),
                                child: StatCard(
                                  icon: LucideIcons.scanLine,
                                  label: 'Escaneos',
                                  value: _totalScans.toString(),
                                  accentColor: AppColors.accentPink,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminRewardsScreen()),
                                ),
                                child: StatCard(
                                  icon: LucideIcons.gift,
                                  label: 'Premios',
                                  value: _totalRewards.toString(),
                                  accentColor: AppColors.accentGreen,
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Módulos', style: AppTypography.titleBold),
                    const SizedBox(height: AppSpacing.md),
                    ModuleListCard(
                          title: 'Gestión de Negocios',
                          subtitle: 'Ver lista, rendimiento y detalles',
                          icon: LucideIcons.store,
                          iconBackgroundColor: AppColors.accentPurple,
                          badgeCount: _pendingBusinessesCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminBusinessesScreen(),
                              ),
                            );
                          },
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                    const SizedBox(height: AppSpacing.sm),
                    ModuleListCard(
                          title: 'Gestión de Categorías',
                          subtitle: 'Agregar o eliminar categorías de negocios',
                          icon: LucideIcons.layers,
                          iconBackgroundColor: AppColors.accentPurple,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminCategoriesScreen(),
                              ),
                            );
                          },
                        )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                    const SizedBox(height: AppSpacing.sm),
                    ModuleListCard(
                          title: 'Gestión de Usuarios',
                          subtitle: 'Ver todos los perfiles y roles',
                          icon: LucideIcons.users,
                          iconBackgroundColor: AppColors.accentAmber,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminUsersScreen(),
                              ),
                            );
                          },
                        )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                    const SizedBox(height: AppSpacing.sm),
                    ModuleListCard(
                          title: 'Estadísticas QR',
                          subtitle: 'Ver ranking de negocios por escaneos',
                          icon: LucideIcons.chartNoAxesColumn,
                          iconBackgroundColor: AppColors.accentGreen,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminQrStatsScreen(),
                              ),
                            );
                          },
                        )
                        .animate(delay: 450.ms)
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                    const SizedBox(height: AppSpacing.sm),
                    ModuleListCard(
                          title: 'Gestión de Actividad',
                          subtitle: 'Ver historial de escaneos y validaciones',
                          icon: LucideIcons.history,
                          iconBackgroundColor: AppColors.textSecondary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminActivityScreen(),
                              ),
                            );
                          },
                        )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                    const SizedBox(height: AppSpacing.sm),
                    ModuleListCard(
                          title: 'Gestión de Premios',
                          subtitle: 'Ver historial de premios canjeados',
                          icon: LucideIcons.gift,
                          iconBackgroundColor: AppColors.accentPink,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminRewardsScreen(),
                              ),
                            );
                          },
                        )
                        .animate(delay: 600.ms)
                        .fadeIn(duration: AppTheme.animDurationStandard)
                        .slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}


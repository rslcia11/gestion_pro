import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
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

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;

  // Metrics
  int _totalBusinesses = 0;
  int _totalUsers = 0;
  int _totalScans = 0;
  int _totalRewards = 0;
  int _pendingBusinessesCount = 0;

  RealtimeChannel? _adminChannel;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _setupRealtimeNotifications();
  }

  void _setupRealtimeNotifications() {
    _adminChannel = supabase.channel('public:admin_notifications')
      ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'businesses',
          callback: (payload) {
            if (mounted) {
              final newBusiness = payload.newRecord;
              if (newBusiness['is_demo'] == false && newBusiness['is_active'] == false) {
                _showNotification(
                  'NUEVO NEGOCIO POR APROBAR',
                  'El negocio "${newBusiness['name']}" se acaba de registrar y requiere activación.',
                  logoUrl: newBusiness['logo_url'],
                );
                _loadMetrics();
              }
            }
          })
      ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'profiles',
          callback: (payload) {
            if (mounted) {
              final newProfile = payload.newRecord;
              if (newProfile['is_demo'] == false) {
                _showNotification('NUEVO USUARIO REGISTRADO', 'El usuario "${newProfile['full_name'] ?? 'Sin nombre'}" se ha unido.');
                _loadMetrics();
              }
            }
          })
      ..subscribe();
  }

  void _showNotification(String title, String message, {String? logoUrl}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 5),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.accentPurple,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (logoUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(logoUrl),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(LucideIcons.bell, color: Colors.white),
                    ),
                  Expanded(
                    child: Text(title, style: AppTypography.labelBold.copyWith(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(message, style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _adminChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      // Load businesses count
      final businessesResponse = await supabase
          .from('businesses')
          .select('id')
          .eq('is_demo', false)
          .count();

      final pendingBusinessesResponse = await supabase
          .from('businesses')
          .select('id')
          .eq('is_demo', false)
          .eq('is_active', false)
          .count();

      // Load users count (Only clients)
      final usersResponse = await supabase
          .from('profiles')
          .select('id')
          .eq('role', 'client')
          .eq('is_demo', false)
          .count();

      // Load scans count
      final scansResponse = await supabase
          .from('scans')
          .select('id')
          .eq('is_demo', false)
          .count();
      
      // Load rewards counts
      final rewardsResponse = await supabase
          .from('rewards')
          .select('id')
          .eq('is_demo', false)
          .count();
      
      if (mounted) {
        setState(() {
          _totalBusinesses = businessesResponse.count;
          _pendingBusinessesCount = pendingBusinessesResponse.count;
          _totalUsers = usersResponse.count;
          _totalScans = scansResponse.count;
          _totalRewards = rewardsResponse.count;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If status column doesn't exist, we fall back to just total
      debugPrint('Error loading metrics (status might not exist): $e');
      try {
         final rewardsResponse = await supabase.from('rewards').select('id').count();
         if (mounted) {
           setState(() {
             _totalRewards = rewardsResponse.count;
             _isLoading = false;
           });
         }
      } catch (innerE) {
         if (mounted) setState(() => _isLoading = false);
      }
    }
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


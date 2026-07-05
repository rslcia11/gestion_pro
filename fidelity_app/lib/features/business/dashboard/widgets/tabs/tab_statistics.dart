import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/shared_widgets.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../../core/providers/supabase_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../dashboard_stat_card.dart';

class TabStatistics extends ConsumerStatefulWidget {
  const TabStatistics({super.key});

  @override
  ConsumerState<TabStatistics> createState() => _TabStatisticsState();
}

class _TabStatisticsState extends ConsumerState<TabStatistics> {
  void _showCustomersModal(List<Map<String, dynamic>> customers) {
    _showListModal(
      title: 'Lista de Clientes',
      icon: LucideIcons.users,
      color: AppColors.accentPurple,
      items: customers,
      subtitleBuilder: (card) => '${card['total_points_lifetime'] ?? 0} escaneos en total',
      trailingBuilder: (card) => Text(
        '${card['current_points'] ?? 0} pts',
        style: AppTypography.subtitleBold.copyWith(color: AppColors.accentPurple, fontSize: 15),
      ),
    );
  }

  void _showTopScansModal(List<Map<String, dynamic>> customers) {
    final sortedByScans = List<Map<String, dynamic>>.from(customers)
      ..sort((a, b) => ((b['total_points_lifetime'] ?? 0) as int).compareTo((a['total_points_lifetime'] ?? 0) as int));

    final activeUsers = sortedByScans.where((c) => (c['total_points_lifetime'] ?? 0) > 0).toList();

    _showListModal(
      title: 'Ranking de Escaneos',
      icon: LucideIcons.scanLine,
      color: AppColors.accentAmber,
      items: activeUsers,
      subtitleBuilder: (card) => 'Total de escaneos históricos',
      trailingBuilder: (card) => Text(
        '${card['total_points_lifetime'] ?? 0}',
        style: AppTypography.displayBold.copyWith(fontSize: 18),
      ),
    );
  }

  void _showRewardsModal(List<Map<String, dynamic>> customers) {
    final sortedByRewards = List<Map<String, dynamic>>.from(customers)
      ..sort((a, b) => ((b['rewards_claimed'] ?? 0) as int).compareTo((a['rewards_claimed'] ?? 0) as int));

    final rewardUsers = sortedByRewards.where((c) => (c['rewards_claimed'] ?? 0) > 0).toList();

    _showListModal(
      title: 'Ranking de Premios',
      icon: LucideIcons.gift,
      color: AppColors.accentGreen,
      items: rewardUsers,
      subtitleBuilder: (card) {
        final claimed = card['rewards_claimed'] ?? 0;
        final transferred = card['rewards_transferred'] ?? 0;
        return '$claimed premios reclamados y $transferred premios transferidos';
      },
      trailingBuilder: (card) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.pastelOf(AppColors.accentGreen),
          borderRadius: BorderRadius.circular(AppRadii.badge),
        ),
        child: Text(
          '${card['rewards_claimed'] ?? 0} 🎁',
          style: AppTypography.labelBold.copyWith(color: AppColors.accentGreen),
        ),
      ),
    );
  }

  void _showListModal({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) subtitleBuilder,
    required Widget Function(Map<String, dynamic>) trailingBuilder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(title, style: AppTypography.titleBold.copyWith(fontSize: 16)),
                    subtitle: Text('${items.length} registros', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                    trailing: IconActionButton(icon: LucideIcons.x, onPressed: () => Navigator.pop(context)),
                  ),
                  const Divider(color: AppColors.border),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.inbox, size: 44, color: AppColors.border),
                                const SizedBox(height: 16),
                                Text('No hay registros', style: AppTypography.subtitleBold.copyWith(color: AppColors.textSecondary, fontSize: 14)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final profile = item['profiles'];
                              final name = (profile?['full_name'] ?? 'Usuario').toString();

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(AppRadii.card),
                                ),
                                child: ListTile(
                                  leading: UserAvatar(initials: name.isNotEmpty ? name[0] : '?', backgroundColor: color, size: 44),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(name, style: AppTypography.subtitleBold.copyWith(fontSize: 13)),
                                      ),
                                      if (profile?['is_demo'] == true) ...[
                                        const SizedBox(width: 8),
                                        StatusChip(label: 'Demo', variant: StatusChipVariant.pending),
                                      ],
                                    ],
                                  ),
                                  subtitle: Text(subtitleBuilder(item), style: AppTypography.caption),
                                  trailing: trailingBuilder(item),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditRewardDialog(Map<String, dynamic> business) {
    final rewardController = TextEditingController(text: business['reward_description'] ?? '');
    final longDescController = TextEditingController(text: business['reward_long_description'] ?? '');
    final pointsController = TextEditingController(text: '${business['points_required']}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
          title: Text('Editar producto', textAlign: TextAlign.center, style: AppTypography.titleBold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: rewardController, label: '¿Qué vas a premiar?', hint: 'Ej: Un vaso de helado'),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: longDescController,
                label: 'Descripción del premio',
                hint: 'Ej: Vaso de helado de cualquier sabor, tamaño mediano',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(controller: pointsController, keyboardType: TextInputType.number, label: 'Puntos necesarios', hint: 'Ej: 3'),
            ],
          ),
          actions: [
            Center(
              child: PrimaryButton(
                label: 'Guardar cambios',
                isFullWidth: false,
                onPressed: () async {
                  final newDesc = rewardController.text.trim().toUpperCase();
                  final newLongDesc = longDescController.text.trim();
                  final newPoints = int.tryParse(pointsController.text.trim()) ?? 10;

                  if (newDesc.isEmpty || newPoints < 1) return;

                  try {
                    await ref.read(supabaseClientProvider)
                        .from('businesses')
                        .update({
                          'reward_description': newDesc,
                          'reward_long_description': newLongDesc,
                          'points_required': newPoints,
                        })
                        .eq('id', business['id']);

                    if (mounted) {
                      Navigator.pop(context);
                      ref.read(dashboardProvider.notifier).loadData(silent: true);
                    }
                  } catch (e) {
                    debugPrint('Error updating reward: $e');
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final customers = state.customers;
    final business = state.business;

    if (business == null) return const SizedBox();

    final totalScans = customers.where((c) => c['profiles']?['is_demo'] != true).fold<int>(
      0,
      (sum, card) => sum + ((card['total_points_lifetime'] ?? 0) as int),
    );
    final totalRewards = customers.where((c) => c['profiles']?['is_demo'] != true).fold<int>(
      0,
      (sum, card) => sum + ((card['rewards_claimed'] ?? 0) as int),
    );

    final createdAtString = business['created_at'] ?? '';
    final createdAt = EcuadorDateUtils.toEcuadorTime(createdAtString);
    final daysLive = EcuadorDateUtils.nowEcuador().difference(createdAt).inDays;
    final formattedDate = "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Información de campaña', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Inicio', style: AppTypography.caption.copyWith(color: Colors.white54, fontWeight: FontWeight.w700)),
                    Text(formattedDate, style: AppTypography.subtitleBold.copyWith(color: Colors.white, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Días activo', style: AppTypography.caption.copyWith(color: Colors.white54, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.accentGreen, borderRadius: BorderRadius.circular(AppRadii.badge)),
                      child: Text('$daysLive días', style: AppTypography.labelBold.copyWith(color: Colors.black, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DashboardStatCard(
            title: 'Clientes',
            value: '${customers.length}',
            icon: LucideIcons.users,
            color: AppColors.accentPurple,
            onTap: () => _showCustomersModal(customers),
            subtitle: 'Personas únicas visitaron',
          ).animate().fadeIn(duration: AppTheme.animDurationStandard).slideY(begin: AppTheme.animSlideYBegin, curve: AppTheme.animCurveStandard),
          const SizedBox(height: AppSpacing.md),
          DashboardStatCard(
            title: 'Escaneos',
            value: '$totalScans',
            icon: LucideIcons.scanLine,
            color: AppColors.accentAmber,
            onTap: () => _showTopScansModal(customers),
            subtitle: 'Visitas totales registradas',
          ).animate(delay: 100.ms).fadeIn(duration: AppTheme.animDurationStandard).slideY(begin: AppTheme.animSlideYBegin, curve: AppTheme.animCurveStandard),
          const SizedBox(height: AppSpacing.md),
          DashboardStatCard(
            title: 'Premios',
            value: '$totalRewards',
            icon: LucideIcons.gift,
            color: AppColors.accentPink,
            onTap: () => _showRewardsModal(customers),
            subtitle: 'Recompensas canjeadas',
          ).animate(delay: 200.ms).fadeIn(duration: AppTheme.animDurationStandard).slideY(begin: AppTheme.animSlideYBegin, curve: AppTheme.animCurveStandard),
          const SizedBox(height: AppSpacing.md),
          DashboardStatCard(
            title: 'Requisito',
            value: '${business['points_required']}',
            icon: LucideIcons.star,
            color: AppColors.accentGreen,
            onTap: () => _showEditRewardDialog(business),
            subtitle: 'Puntos para un premio',
          ).animate(delay: 300.ms).fadeIn(duration: AppTheme.animDurationStandard).slideY(begin: AppTheme.animSlideYBegin, curve: AppTheme.animCurveStandard),
        ],
      ),
    );
  }
}

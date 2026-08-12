import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/shared_widgets.dart';
import '../../providers/dashboard_provider.dart';
class TabCustomers extends ConsumerStatefulWidget {
  const TabCustomers({super.key});

  @override
  ConsumerState<TabCustomers> createState() => _TabCustomersState();
}

class _TabCustomersState extends ConsumerState<TabCustomers> {
  String _searchQuery = '';

  void _showAddPointsDialog(Map<String, dynamic> card) {
    final pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Sumar puntos', textAlign: TextAlign.center, style: AppTypography.titleBold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              card['profiles']['full_name'].toString(),
              style: AppTypography.subtitleBold.copyWith(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              hint: 'Puntos a sumar',
            ),
          ],
        ),
        actions: [
          Center(
            child: PrimaryButton(
              label: 'Agregar',
              isFullWidth: false,
              onPressed: () {
                final points = int.tryParse(pointsController.text);
                if (points != null && points > 0) {
                  Navigator.pop(context);
                  ref.read(dashboardProvider.notifier).addManualPoints(card['user_id'], points);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _redeemReward(String userId, String cardId) async {
    final business = ref.read(dashboardProvider).business;
    if (business == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Canjear premio', style: AppTypography.titleBold),
        content: Text(
          '¿Canjear premio por ${business['points_required']} puntos?',
          style: AppTypography.bodyRegular,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Cancelar',
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: 'Canjear',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(dashboardProvider.notifier).redeemReward(userId, cardId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final customers = state.customers;
    final pendingRewards = state.pendingRewards;
    final business = state.business;

    if (business == null) return const SizedBox();

    final filteredCustomers = _searchQuery.isEmpty
        ? customers
        : customers.where((card) {
            final profile = card['profiles'];
            final name = profile?['full_name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: AppTextField(
            hint: 'Buscar cliente...',
            prefixIcon: LucideIcons.search,
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: filteredCustomers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.users, size: 56, color: AppColors.border),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? 'No hay clientes aún' : 'Sin resultados',
                        style: AppTypography.subtitleBold.copyWith(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final card = filteredCustomers[index];
                    final profile = card['profiles'];
                    final accentColor = [
                      AppColors.accentPurple,
                      AppColors.accentPink,
                      AppColors.accentAmber,
                      AppColors.accentGreen,
                    ][index % 4];

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        boxShadow: AppShadows.card,
                      ),
                      child: Row(
                        children: [
                          UserAvatar(
                            imageUrl: profile?['avatar_url'],
                            initials: profile?['full_name']?[0],
                            size: 52,
                            backgroundColor: accentColor,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (profile?['full_name'] ?? 'Usuario').toString(),
                                  style: AppTypography.subtitleBold.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      '${card['current_points'] ?? 0}/${business['points_required'] ?? '?'} actuales',
                                      style: AppTypography.caption.copyWith(color: AppColors.accentPurple, fontWeight: FontWeight.w700),
                                    ),
                                    Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle)),
                                    Text('${card['total_points_lifetime'] ?? 0} totales', style: AppTypography.caption),
                                    Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.border, shape: BoxShape.circle)),
                                    Text('${card['rewards_claimed'] ?? 0} premios', style: AppTypography.caption),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(LucideIcons.moreHorizontal, color: AppColors.textSecondary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
                            onSelected: (value) {
                              if (value == 'add_points') {
                                _showAddPointsDialog(card);
                              } else if (value == 'redeem') {
                                _redeemReward(card['user_id'], card['id']);
                              }
                            },
                            itemBuilder: (context) {
                              final hasPendingReward = pendingRewards.any(
                                (r) =>
                                    r['user_id'] == card['user_id'] &&
                                    r['business_id'] == business['id'] &&
                                    r['status'] == 'pending',
                              );
                              return [
                                PopupMenuItem(
                                  value: hasPendingReward ? null : 'add_points',
                                  enabled: !hasPendingReward,
                                  child: Row(
                                    children: [
                                      Icon(
                                        hasPendingReward ? LucideIcons.lock : LucideIcons.circlePlus,
                                        size: 20,
                                        color: hasPendingReward ? AppColors.textSecondary : accentColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        hasPendingReward ? 'Premio pendiente' : 'Puntos',
                                        style: AppTypography.labelBold.copyWith(
                                          color: hasPendingReward ? AppColors.textSecondary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if ((card['current_points'] ?? 0) >= business['points_required'])
                                  PopupMenuItem(
                                    value: 'redeem',
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.gift, size: 20, color: AppColors.accentGreen),
                                        const SizedBox(width: 12),
                                        Text('Canjear', style: AppTypography.labelBold),
                                      ],
                                    ),
                                  ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ).animate(delay: AppTheme.animDelayStaggered(index)).fadeIn(duration: AppTheme.animDurationStandard).slideY(
                          begin: AppTheme.animSlideYBegin,
                          curve: AppTheme.animCurveStandard,
                        );
                  },
                ),
        ),
      ],
    );
  }
}

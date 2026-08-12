// lib/features/business/rewards/rewards_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/services/realtime_sync_service.dart';
import 'dart:async';
import 'providers/rewards_management_provider.dart';

class RewardsManagementScreen extends ConsumerStatefulWidget {
  final String businessId;
  const RewardsManagementScreen({super.key, required this.businessId});

  @override
  ConsumerState<RewardsManagementScreen> createState() =>
      _RewardsManagementScreenState();
}

class _RewardsManagementScreenState extends ConsumerState<RewardsManagementScreen> {
  StreamSubscription<void>? _rewardsSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rewardsManagementProvider.notifier).init(widget.businessId);
    });

    _rewardsSub = RealtimeSyncService().onRewardsChanged.listen((_) {
      if (mounted) {
        ref.read(rewardsManagementProvider.notifier).init(widget.businessId);
      }
    });
  }

  @override
  void dispose() {
    _rewardsSub?.cancel();
    super.dispose();
  }

  Future<void> _approveReward(String rewardId) async {
    final success = await ref.read(rewardsManagementProvider.notifier).approveReward(rewardId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Entrega de premio aprobada'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      } else {
        final error = ref.read(rewardsManagementProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    }
  }

  Future<void> _rejectReward(String rewardId) async {
    final success = await ref.read(rewardsManagementProvider.notifier).rejectReward(rewardId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Premio rechazado'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      } else {
        final error = ref.read(rewardsManagementProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardsManagementProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.isLoading && state.rewards.isEmpty
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)))
          : state.error != null
          ? Center(child: Text(state.error!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error)))
          : state.rewards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.pastelOf(AppColors.accentPurple),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.gift, size: 56, color: AppColors.accentPurple),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Sin premios aún', style: AppTypography.subtitleBold),
                  Text('Aquí verás los premios por aprobar y entregados.', style: AppTypography.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              itemCount: state.rewards.length,
              itemBuilder: (context, index) {
                final reward = state.rewards[index];
                final String fullName = reward['display_name'].toString();
                final String date = EcuadorDateUtils.formatEcuadorTime(
                  reward['earned_at'],
                );
                final String status = reward['status'] ?? 'pending';

                StatusChipVariant variant = StatusChipVariant.pending;
                String statusLabel = 'Pendiente';
                if (status == 'requested') {
                  variant = StatusChipVariant.info;
                  statusLabel = 'Solicitado';
                } else if (status == 'approved') {
                  variant = StatusChipVariant.success;
                  statusLabel = 'Entregado';
                } else if (status == 'rejected') {
                  variant = StatusChipVariant.error;
                  statusLabel = 'Rechazado';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ActivityListCard(
                    avatarUrl: reward['avatar_url'],
                    avatarInitials: fullName.isNotEmpty ? fullName[0] : '?',
                    title: fullName,
                    description: reward['is_transferred'] == true
                        ? '${reward['from_name']} transfirió el premio a $fullName'
                        : '$fullName ganó premio',
                    timestamp: 'El $date',
                    trailing: StatusChip(label: statusLabel, variant: variant),
                    actions: (status == 'pending' || status == 'requested')
                        ? Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(label: 'Rechazar', onPressed: () => _rejectReward(reward['id'])),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(label: 'Entregar', onPressed: () => _approveReward(reward['id'])),
                              ),
                            ],
                          )
                        : null,
                  ),
                )
                    .animate(delay: (index * 50).ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOut);
              },
            ),
    );
  }
}


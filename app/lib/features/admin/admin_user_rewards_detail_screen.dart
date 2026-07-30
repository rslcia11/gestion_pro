import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/shared_widgets.dart';

class AdminUserRewardsDetailScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final List<Map<String, dynamic>> rewards;

  const AdminUserRewardsDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.rewards,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBarTitle('Premios de Usuario', style: AppTypography.subtitleBold.copyWith(fontSize: 16)),
            AppBarTitle(userName, style: AppTypography.caption),
          ],
        ),
      ),
      body: rewards.isEmpty
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
                    child: const Icon(LucideIcons.gift, size: 56, color: AppColors.accentPurple),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('No hay premios registrados', style: AppTypography.subtitleBold),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];

                final businessName = reward['business_name'] ?? 'Negocio Desconocido';
                final dateStr = reward['earned_at'] != null
                    ? EcuadorDateUtils.formatEcuadorTime(reward['earned_at'])
                    : 'Fecha desconocida';

                final rewardDesc = reward['reward_description'] ?? 'Premio';
                final pointsUsed = reward['points_used'] ?? 0;

                final bool isTransferred = reward['transferred'] == true;
                final transferredTo = reward['transferred_to_name'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ActivityListCard(
                    avatarInitials: businessName.toString().isNotEmpty
                        ? businessName.toString()[0].toUpperCase()
                        : '?',
                    title: rewardDesc.toString(),
                    description: businessName.toString(),
                    timestamp: dateStr,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pastelOf(AppColors.accentPurple),
                        borderRadius: BorderRadius.circular(AppRadii.badge),
                      ),
                      child: Text(
                        '$pointsUsed pts',
                        style: AppTypography.labelBold.copyWith(color: AppColors.accentPurple, fontSize: 11),
                      ),
                    ),
                    actions: isTransferred
                        ? Row(
                            children: [
                              const Icon(LucideIcons.arrowLeftRight, size: 14, color: AppColors.accentOrange),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Transferido a: ${transferredTo ?? 'Desconocido'}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                )
                    .animate(delay: Duration(milliseconds: 50 * index))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, curve: Curves.easeOutBack);
              },
            ),
    );
  }
}

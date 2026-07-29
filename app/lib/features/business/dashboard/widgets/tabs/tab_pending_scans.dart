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
import '../../../../../core/utils/date_utils.dart';
import '../../providers/dashboard_provider.dart';

class TabPendingScans extends ConsumerWidget {
  const TabPendingScans({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingScans = ref.watch(dashboardProvider.select((s) => s.pendingScans));

    if (pendingScans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.pastelOf(AppColors.accentGreen),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.circleCheck, size: 56, color: AppColors.accentGreen),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('¡Todo al día!', style: AppTypography.subtitleBold),
            Text('No hay escaneos por aprobar.', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accentPurple,
      backgroundColor: AppColors.surfaceCard,
      onRefresh: () => ref.read(dashboardProvider.notifier).loadData(silent: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: pendingScans.length,
        itemBuilder: (context, index) {
          final scan = pendingScans[index];
          final profile = scan['profiles'];
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
                UserAvatar(imageUrl: profile?['avatar_url'], initials: profile?['full_name']?[0], size: 48),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (profile?['full_name'] ?? 'Usuario').toString(),
                              style: AppTypography.subtitleBold.copyWith(fontSize: 13),
                            ),
                          ),
                          if (profile?['is_demo'] == true) ...[
                            const SizedBox(width: 8),
                            StatusChip(label: 'Demo', variant: StatusChipVariant.pending),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        EcuadorDateUtils.formatEcuadorTime(scan['scanned_at']),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconActionButton(
                      icon: LucideIcons.circleX,
                      tooltip: 'Rechazar escaneo',
                      backgroundColor: AppColors.pastelOf(AppColors.accentPink),
                      iconColor: AppColors.accentPink,
                      onPressed: () => ref.read(dashboardProvider.notifier).rejectScan(scan['id']),
                    ),
                    const SizedBox(width: 4),
                    IconActionButton(
                      icon: LucideIcons.circleCheck,
                      tooltip: 'Aprobar escaneo',
                      backgroundColor: AppColors.pastelOf(AppColors.accentGreen),
                      iconColor: AppColors.accentGreen,
                      onPressed: () => ref.read(dashboardProvider.notifier).approveScan(scan['id'], scan['loyalty_card_id']),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: AppTheme.animDelayStaggered(index)).fadeIn(duration: AppTheme.animDurationStandard).slideY(
                begin: AppTheme.animSlideYBegin,
                curve: AppTheme.animCurveStandard,
              );
        },
      ),
    );
  }
}

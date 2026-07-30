import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/card_history_provider.dart';

class CardHistoryScreen extends ConsumerStatefulWidget {
  final String loyaltyCardId;
  final String businessId;
  final String businessName;
  final int initialTabIndex;

  const CardHistoryScreen({
    super.key,
    required this.loyaltyCardId,
    required this.businessId,
    required this.businessName,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<CardHistoryScreen> createState() => _CardHistoryScreenState();
}

class _CardHistoryScreenState extends ConsumerState<CardHistoryScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(cardHistoryProvider.notifier).init(widget.loyaltyCardId, widget.businessId);
  }

  Future<void> _selectDateRange(DateTimeRange? currentRange) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange:
          currentRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      ref.read(cardHistoryProvider.notifier).updateDateRange(pickedRange);
    }
  }

  bool _canTransfer(Map<String, dynamic> reward) {
    final status = reward['status'] ?? 'pending';
    return status == 'approved';
  }

  Future<void> _shareAppLink() async {
    const message =
        '¡Descarga Donde Siempre! Tu amigo te transferió un premio.';
    // Ignorando el warning de SharePlus por seguridad de la API
    // ignore: deprecated_member_use
    await Share.share(message);
  }

  Future<void> _showTransferDialog(Map<String, dynamic> reward) async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Clear previous state before showing dialog
    ref.read(cardHistoryProvider.notifier).clearTransferState();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(cardHistoryProvider);

              // Listen for success message to close modal
              ref.listen<CardHistoryState>(cardHistoryProvider, (prev, next) {
                if (prev?.transferSuccessMessage == null && next.transferSuccessMessage != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(next.transferSuccessMessage!),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                }
              });

              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Transferir Premio', textAlign: TextAlign.center, style: AppTypography.titleBold),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa el email de tu amigo para transferirle este premio.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          hint: 'amigo@ejemplo.com',
                          label: 'Email del destinatario',
                          prefixIcon: LucideIcons.mail,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa un email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Ingresa un email válido';
                            }
                            return null;
                          },
                        ),
                        if (state.transferErrorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.pastelOf(AppColors.accentPink),
                              borderRadius: BorderRadius.circular(AppRadii.badge),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.circleAlert, color: AppColors.accentPink, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.transferErrorMessage!,
                                        style: AppTypography.labelBold.copyWith(color: AppColors.accentPink, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                if (state.showInviteButton) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  PrimaryButton(
                                    label: 'Invitar a un amigo',
                                    icon: LucideIcons.share2,
                                    isFullWidth: false,
                                    onPressed: _shareAppLink,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(context)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Transferir',
                                isLoading: state.isTransferLoading,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    final email = emailController.text.trim();
                                    ref.read(cardHistoryProvider.notifier).transferReward(reward['id'] as String, email);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardHistoryProvider);

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: 100,
          centerTitle: true,
          title: AppBarTitle(widget.businessName, style: AppTypography.titleBold.copyWith(fontSize: 16)),
          actions: [
            IconActionButton(
              icon: LucideIcons.calendarDays,
              iconColor: state.dateRange == null ? AppColors.textSecondary : AppColors.accentPurple,
              onPressed: () => _selectDateRange(state.dateRange),
            ),
            if (state.dateRange != null)
              IconActionButton(
                icon: LucideIcons.x,
                iconColor: AppColors.accentPink,
                onPressed: () {
                  ref.read(cardHistoryProvider.notifier).updateDateRange(null);
                },
              ),
          ],
          bottom: TabBar(
            labelStyle: AppTypography.labelBold,
            unselectedLabelStyle: AppTypography.bodyMedium.copyWith(fontSize: 12),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: AppColors.primary),
              insets: EdgeInsets.symmetric(horizontal: 16),
            ),
            tabs: const [
              Tab(text: 'Escaneos'),
              Tab(text: 'Premios'),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)))
            : TabBarView(
                children: [
                  _buildHistoryList(state.scans, isScan: true),
                  _buildHistoryList(state.rewards, isScan: false),
                ],
              ),
      ),
    );
  }

  Widget _buildHistoryList(
    List<Map<String, dynamic>> items, {
    required bool isScan,
  }) {
    if (items.isEmpty) {
      final accent = isScan ? AppColors.accentGreen : AppColors.accentPink;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: AppColors.pastelOf(accent), shape: BoxShape.circle),
              child: Icon(isScan ? LucideIcons.history : LucideIcons.gift, size: 56, color: accent),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(isScan ? 'Sin actividad' : 'Sin premios', style: AppTypography.subtitleBold),
            Text('Pronto verás tus movimientos aquí.', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final date = isScan ? item['scanned_at'] : item['earned_at'];
        // Un punto sin qr_code_id fue otorgado manualmente por el dueño (regalo);
        // con qr_code_id provino de un escaneo de QR.
        final bool isGifted = isScan && (item['qr_code_id'] == null);
        final String actionTitle = isScan
            ? (isGifted ? '+1 Punto de regalo' : '+1 Punto por escaneo')
            : 'Premio ganado';
        final accent = isScan ? AppColors.accentGreen : AppColors.accentPink;

        // Status logic for rewards
        final String status = !isScan
            ? (item['status'] ?? 'pending')
            : 'approved';
        Color statusColor = AppColors.accentAmber;
        String statusLabel = 'Pendiente';

        if (status == 'approved') {
          statusColor = AppColors.accentGreen;
          statusLabel = 'Entregado';
        } else if (status == 'rejected') {
          statusColor = AppColors.accentPink;
          statusLabel = 'Rechazado';
        } else if (status == 'transferred_out') {
          statusColor = AppColors.accentPurple;
          statusLabel = 'Transferido';
        }

        // Get transfer info if available
        String? transferredToName;
        if (!isScan && item['reward_transfer_history'] != null && (item['reward_transfer_history'] as List).isNotEmpty) {
          final transferInfo = (item['reward_transfer_history'] as List).first;
          transferredToName = transferInfo['profiles']?['full_name'] ?? 'Usuario';
        }

        return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadii.card),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pastelOf(isScan ? accent : statusColor),
                          borderRadius: BorderRadius.circular(AppRadii.badge),
                        ),
                        child: Icon(
                          isScan
                              ? (isGifted ? LucideIcons.gift : LucideIcons.scanLine)
                              : LucideIcons.gift,
                          color: isScan ? accent : statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isScan
                                  ? actionTitle
                                  : (item['businesses']?['reward_description']?.toString() ??
                                        item['reward_description']?.toString() ??
                                        'Premio'),
                              style: AppTypography.subtitleBold.copyWith(fontSize: 13),
                            ),
                            if (isScan)
                              Text(
                                isGifted ? 'Regalo del dueño' : 'Por escaneo de QR',
                                style: AppTypography.caption.copyWith(
                                  color: isGifted ? AppColors.accentPurple : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            if (!isScan && item['description'] != null)
                              Text(item['description'].toString(), style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text(EcuadorDateUtils.formatEcuadorTime(date), style: AppTypography.caption.copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                      if (!isScan)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusChip(
                              label: statusLabel,
                              variant: status == 'approved'
                                  ? StatusChipVariant.success
                                  : status == 'rejected'
                                      ? StatusChipVariant.error
                                      : status == 'transferred_out'
                                          ? StatusChipVariant.info
                                          : StatusChipVariant.pending,
                            ),
                            if (_canTransfer(item)) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showTransferDialog(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelOf(AppColors.accentPurple),
                                    borderRadius: BorderRadius.circular(AppRadii.pill),
                                    border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.arrowLeftRight, color: AppColors.accentPurple, size: 12),
                                      const SizedBox(width: 4),
                                      Text('Transferir', style: AppTypography.labelBold.copyWith(color: AppColors.accentPurple, fontSize: 9)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                  if (!isScan && transferredToName != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(LucideIcons.cornerDownRight, size: 14, color: AppColors.accentPurple),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Transferido a: $transferredToName',
                            style: AppTypography.caption.copyWith(color: AppColors.accentPurple, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isScan &&
                      item['businesses'] != null &&
                      item['businesses']['name'] != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(LucideIcons.store, size: 12, color: AppColors.border),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item['businesses']['name'].toString(),
                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            )
            .animate(delay: AppTheme.animDelayStaggered(index))
            .fadeIn(duration: AppTheme.animDurationStandard)
            .slideY(
              begin: AppTheme.animSlideYBegin,
              curve: AppTheme.animCurveStandard,
            );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class _AdminActivityScreenState extends State<AdminActivityScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _activities = [];
  final List<Map<String, dynamic>> _businessesList = [];
  String _selectedFilter = 'all';
  String _selectedBusinessId = 'all';
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isFetchingMore &&
          _hasMore) {
        _fetchMoreActivity();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadActivity() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _activities = [];
    });
    EcuadorDateUtils.getStartOfDayEcuadorUtc();
    setState(() {
      _activities = [];
      _hasMore = false;
      _isLoading = false;
    });
  }

  Future<void> _fetchMoreActivity() async {
    setState(() => _isFetchingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Actividad Global'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadActivity,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_activities.length} registros',
                          style: AppTypography.subtitleBold.copyWith(fontSize: 14),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            icon: const Icon(LucideIcons.listFilter, color: AppColors.textPrimary, size: 18),
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 14),
                            dropdownColor: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(AppRadii.badge),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('Todos')),
                              DropdownMenuItem(value: 'today', child: Text('Hoy')),
                              DropdownMenuItem(value: 'week', child: Text('Esta Semana')),
                              DropdownMenuItem(value: 'month', child: Text('Este Mes')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedFilter = value);
                                _loadActivity();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_businessesList.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Local:',
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBusinessId,
                              icon: const Icon(LucideIcons.store, color: AppColors.textPrimary, size: 18),
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 14),
                              dropdownColor: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(AppRadii.badge),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Todos los locales')),
                                ..._businessesList.map((b) {
                                  return DropdownMenuItem(
                                    value: b['id'] as String,
                                    child: Text(b['name'] != null ? (b['name'].toString().length > 20 ? '${b['name'].toString().substring(0, 20)}...' : b['name']) : 'Desconocido'),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedBusinessId = value);
                                  _loadActivity();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)),
                ),
              )
            else if (_activities.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text('No hay actividad en este período', style: AppTypography.bodyMedium),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _activities.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)),
                          ),
                        );
                      }
                      final activity = _activities[index];
                      final business = activity['businesses'] ?? {};
                      final businessName = business['name'] ?? 'Negocio Desconocido';
                      final dateStr = activity['date'] != null ? EcuadorDateUtils.formatEcuadorTime(activity['date']) : 'Fecha desconocida';

                      // Escaneo normal
                      final profile = activity['profiles'] ?? {};
                      final userName = (profile['full_name'] ?? profile['email'] ?? 'Usuario Desconocido').toString();
                      final status = activity['status'] ?? 'pending';

                      // Un escaneo sin qr_code_id fue un punto otorgado a mano
                      // por el dueño del local (regalo); con qr_code_id vino de un
                      // escaneo real del QR.
                      final bool isGifted = activity['qr_code_id'] == null;
                      final String actionText =
                          isGifted ? 'recibió un punto de regalo' : 'escaneó QR';
                      final Color originColor =
                          isGifted ? AppColors.accentPurple : AppColors.accentPink;
                      final IconData originIcon =
                          isGifted ? LucideIcons.gift : LucideIcons.scanLine;

                      final StatusChipVariant statusVariant = status == 'approved'
                          ? StatusChipVariant.success
                          : (status == 'rejected' ? StatusChipVariant.error : StatusChipVariant.pending);
                      final String statusLabel = status == 'approved'
                          ? 'Aprobado'
                          : (status == 'rejected' ? 'Rechazado' : 'Pendiente');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ActivityListCard(
                          avatarInitials: userName.isNotEmpty ? userName[0] : '?',
                          title: '$userName $actionText',
                          description: 'En: $businessName',
                          timestamp: dateStr,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (activity['is_demo'] == true) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelOf(AppColors.accentAmber),
                                    borderRadius: BorderRadius.circular(AppRadii.badge),
                                  ),
                                  child: Text(
                                    'DEMO',
                                    style: AppTypography.labelBold.copyWith(color: AppColors.accentAmber, fontSize: 9),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Icon(originIcon, color: originColor, size: 16),
                              const SizedBox(width: 6),
                              StatusChip(label: statusLabel, variant: statusVariant),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _activities.length + (_isFetchingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

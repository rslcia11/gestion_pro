import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/utils/date_utils.dart';
import '../../core/services/export_service.dart';
import 'widgets/export_preview_dialog.dart';

class AdminBusinessesScreen extends StatefulWidget {
  const AdminBusinessesScreen({super.key});

  @override
  State<AdminBusinessesScreen> createState() => _AdminBusinessesScreenState();
}

enum DateRangeFilter {
  all('Todas', 0),
  today('Hoy', 1),
  week('Semana', 7),
  month('Mes', 30),
  year('Año', 365),
  custom('Personalizado', -1);

  final String label;
  final int days;

  const DateRangeFilter(this.label, this.days);
}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class _AdminBusinessesScreenState extends State<AdminBusinessesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _businesses = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateRangeFilter _selectedFilter = DateRangeFilter.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isFetchingMore &&
          _hasMore) {
        _fetchMoreBusinesses();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  (DateTime start, DateTime end)? _getDateRange() {
    final startOfDay = EcuadorDateUtils.getStartOfDayEcuadorUtc();
    final nowUtc = DateTime.now().toUtc();

    switch (_selectedFilter) {
      case DateRangeFilter.all:
        return null;
      case DateRangeFilter.today:
        return (startOfDay, EcuadorDateUtils.getEndOfDayEcuadorUtc());
      case DateRangeFilter.week:
        final start = startOfDay.subtract(const Duration(days: 7));
        return (start, nowUtc);
      case DateRangeFilter.month:
        final start = startOfDay.subtract(const Duration(days: 30));
        return (start, nowUtc);
      case DateRangeFilter.year:
        final start = startOfDay.subtract(const Duration(days: 365));
        return (start, nowUtc);
      case DateRangeFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          final cStart = DateTime.utc(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day, 5, 0, 0);
          final cEnd = DateTime.utc(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 5, 0, 0).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
          return (cStart, cEnd);
        }
        return (startOfDay, EcuadorDateUtils.getEndOfDayEcuadorUtc());
    }
  }

  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _businesses = [];
    });
    _getDateRange();
    setState(() {
      _businesses = [];
      _hasMore = false;
      _isLoading = false;
    });
  }

  Future<void> _fetchMoreBusinesses() async {
    setState(() => _isFetchingMore = false);
  }

  List<Map<String, dynamic>> get _filteredBusinesses {
    if (_searchQuery.isEmpty) return _businesses;
    return _businesses.where((b) {
      final name = (b['name'] ?? '').toString().toLowerCase();
      final owner = (b['profiles']?['full_name'] ?? '').toString().toLowerCase();
      final email = (b['profiles']?['email'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || owner.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _toggleBusinessStatus(String id, bool currentStatus) async {
    setState(() {
      final index = _businesses.indexWhere((b) => b['id'] == id);
      if (index != -1) {
        _businesses[index]['is_active'] = !currentStatus;
      }
    });
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportPreviewDialog(
        data: _filteredBusinesses,
        entity: ExportEntity.businesses,
        exportService: CsvExportService(),
      ),
    );
  }

  Future<void> _showCustomDatePicker() async {
    final now = EcuadorDateUtils.nowEcuador();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now,
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedFilter = DateRangeFilter.custom;
      });
      _loadBusinesses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Negocios Registrados'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showExportDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
        icon: const Icon(LucideIcons.download),
        label: Text(
          'Exportar',
          style: AppTypography.subtitleBold.copyWith(color: AppColors.onPrimary, fontSize: 15),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBusinesses,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Barra de Búsqueda
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: AppTextField(
                      controller: _searchController,
                      hint: 'Buscar por nombre, dueño o email...',
                      prefixIcon: LucideIcons.search,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconActionButton(
                              icon: LucideIcons.x,
                              size: 32,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  // Filtros de fecha
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.background,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_filteredBusinesses.length} negocios',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: DateRangeFilter.values.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return InkWell(
                              onTap: filter == DateRangeFilter.custom
                                  ? _showCustomDatePicker
                                  : () {
                                      setState(() => _selectedFilter = filter);
                                      _loadBusinesses();
                                    },
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                                  borderRadius: BorderRadius.circular(AppRadii.pill),
                                  border: isSelected ? null : Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  filter.label,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedFilter == DateRangeFilter.custom &&
                            _customStartDate != null &&
                            _customEndDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${_formatDate(_customStartDate!)} - ${_formatDate(_customEndDate!)}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
                  ),
                ),
              )
            else if (_filteredBusinesses.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.searchX, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No hay negocios registrados'
                            : 'No se encontraron negocios',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _filteredBusinesses.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)),
                          ),
                        );
                      }
                      final business = _filteredBusinesses[index];
                      final owner = business['profiles'] ?? {};
                      final ownerName = owner['full_name'] ?? 'Desconocido';
                      final ownerEmail = owner['email'] ?? 'Sin correo';
                      final isActive = business['is_active'] ?? false;
                      final businessName = (business['name'] ?? 'Sin nombre').toString();

                      final clientsList = List<Map<String, dynamic>>.from(
                        business['loyalty_cards'] ?? [],
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  UserAvatar(
                                    imageUrl: business['logo_url'] as String?,
                                    initials: businessName.isNotEmpty ? businessName[0] : '?',
                                    size: 56,
                                    backgroundColor: AppColors.accentPurple,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                businessName,
                                                style: AppTypography.subtitleBold,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (!isActive) ...[
                                              const StatusChip(label: 'Pendiente', variant: StatusChipVariant.error),
                                              const SizedBox(width: AppSpacing.xs),
                                            ],
                                            if (business['is_demo'] == true)
                                              const StatusChip(label: 'Demo', variant: StatusChipVariant.pending),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'Categoría: ${business['business_categories']?['name'] ?? 'Otra'}',
                                          style: AppTypography.bodyMedium,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Row(
                                          children: [
                                            const Icon(LucideIcons.user, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: AppSpacing.xs),
                                            Expanded(
                                              child: Text(
                                                'Dueño: $ownerName',
                                                style: AppTypography.bodyMedium.copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: [
                                            const Icon(LucideIcons.mail, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: AppSpacing.xs),
                                            Expanded(
                                              child: Text(
                                                ownerEmail,
                                                style: AppTypography.caption,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: [
                                            const Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: AppSpacing.xs),
                                            Expanded(
                                              child: Text(
                                                owner['phone'] ?? 'Sin celular',
                                                style: AppTypography.caption,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isActive,
                                    onChanged: (val) =>
                                        _toggleBusinessStatus(business['id'], isActive),
                                    activeColor: AppColors.accentGreen,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.pastelOf(AppColors.accentPurple),
                                  borderRadius: BorderRadius.circular(AppRadii.badge),
                                  border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.megaphone, size: 18, color: AppColors.accentPurple),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          'Campaña Activa',
                                          style: AppTypography.subtitleBold.copyWith(
                                            fontSize: 14,
                                            color: AppColors.accentPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16, color: AppColors.border),
                                    _CampaignDetailRow(
                                      icon: LucideIcons.gift,
                                      label: 'Premio:',
                                      value: business['reward_description'] ?? 'No definido',
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _CampaignDetailRow(
                                      icon: LucideIcons.star,
                                      label: 'Puntos:',
                                      value: '${business['points_required'] ?? 0} pts',
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _CampaignDetailRow(
                                      icon: LucideIcons.calendarDays,
                                      label: 'Inicio:',
                                      value: business['created_at'] != null
                                        ? EcuadorDateUtils.formatEcuadorDate(business['created_at'])
                                        : 'N/A',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (clientsList.isNotEmpty)
                              Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  title: Row(
                                    children: [
                                      const Icon(LucideIcons.users, size: 16, color: AppColors.textSecondary),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        '${clientsList.length} Clientes Activos',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                                      child: Divider(height: 1, color: AppColors.border),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: AppSpacing.md,
                                        right: AppSpacing.md,
                                        bottom: AppSpacing.md,
                                        top: AppSpacing.sm,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Clientes Registrados:',
                                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Wrap(
                                              spacing: AppSpacing.sm,
                                              runSpacing: AppSpacing.sm,
                                              children: clientsList.map((clientData) {
                                                final p = clientData['profiles'] ?? {};
                                                final clientName =
                                                    p['full_name'] ??
                                                    p['email'] ??
                                                    'Desconocido';
                                                return Chip(
                                                  avatar: CircleAvatar(
                                                    backgroundColor: AppColors.pastelOf(AppColors.accentBlue),
                                                    child: Text(
                                                      clientName[0].toUpperCase(),
                                                      style: AppTypography.caption.copyWith(
                                                        fontSize: 10,
                                                        color: AppColors.accentBlue,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  label: Text(
                                                    clientName,
                                                    style: AppTypography.caption,
                                                  ),
                                                  backgroundColor: AppColors.background,
                                                  side: BorderSide.none,
                                                  padding: EdgeInsets.zero,
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.md,
                                  bottom: AppSpacing.md,
                                  top: 4,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Aún no tiene clientes',
                                    style: AppTypography.caption,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}

class _CampaignDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CampaignDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.caption,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

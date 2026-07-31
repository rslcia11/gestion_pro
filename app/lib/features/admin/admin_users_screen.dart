import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../../core/services/export_service.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'widgets/export_preview_dialog.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
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

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _selectedRoleFilter = 'all';
  DateRangeFilter _selectedFilter = DateRangeFilter.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  static const List<String> _roleFilterValues = ['all', 'business', 'client'];
  static const List<String> _roleFilterLabels = ['Todos', 'Negocios', 'Clientes'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isFetchingMore &&
          _hasMore) {
        _fetchMoreUsers();
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

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
      _users = [];
    });
    try {
      var query = supabase.from('profiles').select('''
            id,
            full_name,
            email,
            phone,
            role,
            is_demo,
            created_at,
            businesses!owner_id(name)
          ''');

      final dateRange = _getDateRange();
      if (dateRange != null) {
        query = query.gte('created_at', dateRange.$1.toIso8601String())
                     .lte('created_at', dateRange.$2.toIso8601String());
      }

      if (_selectedRoleFilter != 'all') {
        query = query.eq('role', _selectedRoleFilter);
      } else {
        query = query.neq('role', 'admin');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(0, _pageSize - 1);

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response);
          _hasMore = _users.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchMoreUsers() async {
    setState(() => _isFetchingMore = true);
    try {
      _currentPage++;
      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize - 1;

      var query = supabase.from('profiles').select('''
            id,
            full_name,
            email,
            phone,
            role,
            is_demo,
            created_at,
            businesses!owner_id(name)
          ''');

      final dateRange = _getDateRange();
      if (dateRange != null) {
        query = query.gte('created_at', dateRange.$1.toIso8601String())
                     .lte('created_at', dateRange.$2.toIso8601String());
      }

      if (_selectedRoleFilter != 'all') {
        query = query.eq('role', _selectedRoleFilter);
      } else {
        query = query.neq('role', 'admin');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(startIndex, endIndex);

      final newItems = List<Map<String, dynamic>>.from(response);

      if (mounted) {
        setState(() {
          _users.addAll(newItems);
          _hasMore = newItems.length == _pageSize;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading more users: $e');
      if (mounted) {
        setState(() => _isFetchingMore = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((u) {
      final name = (u['full_name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  String _getRoleLabel(String? role) {
    if (role == 'admin') return 'Administrador';
    if (role == 'business') return 'Negocio';
    return 'Cliente';
  }

  Color _getRoleColor(String? role) {
    if (role == 'admin') return AppColors.accentPink;
    if (role == 'business') return AppColors.accentPurple;
    return AppColors.accentAmber;
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportPreviewDialog(
        data: _filteredUsers,
        entity: ExportEntity.users,
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
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surfaceCard,
              onSurface: AppColors.textPrimary,
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
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppBarTitle('Usuarios Registrados', style: AppTypography.titleBold.copyWith(fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconActionButton(
          icon: LucideIcons.arrowLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showExportDialog,
        icon: const Icon(LucideIcons.download),
        label: Text('Exportar', style: AppTypography.subtitleBold.copyWith(color: AppColors.onPrimary, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Barra de Búsqueda
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: AppTextField(
                      controller: _searchController,
                      hint: 'Buscar por nombre o email...',
                      prefixIcon: LucideIcons.search,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textSecondary),
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
                  // Filtros
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_filteredUsers.length} usuarios',
                          style: AppTypography.subtitleBold.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SegmentedToggle(
                          options: _roleFilterLabels,
                          selectedIndex: _roleFilterValues.indexOf(_selectedRoleFilter),
                          onChanged: (index) {
                            setState(() {
                              _selectedRoleFilter = _roleFilterValues[index];
                            });
                            _loadUsers();
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
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
                                      _loadUsers();
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
                          const SizedBox(height: AppSpacing.sm),
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
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              )
            else if (_filteredUsers.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty ? LucideIcons.users : LucideIcons.search,
                        size: 48,
                        color: AppColors.border,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No hay usuarios registrados'
                            : 'No se encontraron usuarios',
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
                      if (index == _filteredUsers.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                          ),
                        );
                      }
                      final user = _filteredUsers[index];
                      final role = user['role'] as String?;
                      final roleColor = _getRoleColor(role);
                      final fullName = (user['full_name'] ?? 'Sin nombre').toString();

                      return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(AppRadii.card),
                              boxShadow: AppShadows.card,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserAvatar(
                                  initials: fullName.isNotEmpty ? fullName[0] : '?',
                                  backgroundColor: roleColor,
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
                                              fullName,
                                              style: AppTypography.subtitleBold.copyWith(fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (user['is_demo'] == true) ...[
                                            const StatusChip(label: 'Demo', variant: StatusChipVariant.pending),
                                            const SizedBox(width: AppSpacing.xs),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.pastelOf(roleColor),
                                          borderRadius: BorderRadius.circular(AppRadii.badge),
                                        ),
                                        child: Text(
                                          _getRoleLabel(role),
                                          style: AppTypography.labelBold.copyWith(fontSize: 10, color: roleColor),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.mail, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              user['email'] ?? 'Sin correo',
                                              style: AppTypography.caption,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (user['phone'] != null) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                user['phone'],
                                                style: AppTypography.caption,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (role == 'business' &&
                                          (user['businesses'] as List?)?.isNotEmpty == true) ...[
                                        const SizedBox(height: AppSpacing.sm),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.pastelOf(AppColors.accentPurple),
                                            borderRadius: BorderRadius.circular(AppRadii.badge),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.store, size: 12, color: AppColors.accentPurple),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  'Dueño de: ${user['businesses'][0]['name']}',
                                                  style: AppTypography.labelBold.copyWith(fontSize: 11, color: AppColors.accentPurple),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Registro: ${EcuadorDateUtils.formatEcuadorTime(user['created_at'] ?? '')}',
                                        style: AppTypography.caption.copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_utils.dart';
import '../../core/services/realtime_sync_service.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'admin_user_rewards_detail_screen.dart';

class AdminRewardsScreen extends StatefulWidget {
  const AdminRewardsScreen({super.key});

  @override
  State<AdminRewardsScreen> createState() => _AdminRewardsScreenState();
}

class _AdminRewardsScreenState extends State<AdminRewardsScreen> {
  // Stub: sin backend conectado — pendiente de integrar nueva DB.
  bool _isLoading = true;
  List<Map<String, dynamic>> _businessesList = [];
  List<Map<String, dynamic>> _allTransfers = [];
  String _selectedBusinessId = 'all';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  StreamSubscription<void>? _rewardsSub;
  StreamSubscription<void>? _transfersSub;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
    _loadRewards();

    _rewardsSub = RealtimeSyncService().onRewardsChanged.listen((_) {
      if (mounted) _loadRewards();
    });
    _transfersSub = RealtimeSyncService().onRewardTransfersChanged.listen((_) {
      if (mounted) _loadRewards();
    });
  }

  @override
  void dispose() {
    _rewardsSub?.cancel();
    _transfersSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    if (mounted) {
      setState(() {
        _businessesList = [];
      });
    }
  }

  List<Map<String, dynamic>> _userSummaries = [];

  Future<void> _loadRewards() async {
    setState(() => _isLoading = true);
    if (mounted) {
      setState(() {
        _allTransfers = [];
        _userSummaries = [];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _userSummaries;
    final query = _searchQuery.toLowerCase();
    return _userSummaries.where((u) {
      final userName = (u['user_name'] ?? '').toString().toLowerCase();
      final userEmail = (u['user_email'] ?? '').toString().toLowerCase();
      return userName.contains(query) || userEmail.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Premios Canjeados'),
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
              Tab(text: 'Usuarios Ganadores'),
              Tab(text: 'Historial Traspasos'),
            ],
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_filteredUsers.length} usuarios ganadores',
                            style: AppTypography.subtitleBold.copyWith(fontSize: 14),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              icon: const Icon(
                                LucideIcons.listFilter,
                                color: AppColors.textPrimary,
                                size: 18,
                              ),
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 14),
                              dropdownColor: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(AppRadii.badge),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Todos (Últimos 100)'),
                                ),
                                DropdownMenuItem(value: 'today', child: Text('Hoy')),
                                DropdownMenuItem(
                                  value: 'week',
                                  child: Text('Esta Semana'),
                                ),
                                DropdownMenuItem(
                                  value: 'month',
                                  child: Text('Este Mes'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFilter = value;
                                  });
                                  _loadRewards();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      // Business Filter
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
                                icon: const Icon(
                                  LucideIcons.store,
                                  color: AppColors.textPrimary,
                                  size: 18,
                                ),
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 14),
                                dropdownColor: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(AppRadii.badge),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'all',
                                    child: Text('Todos los locales'),
                                  ),
                                  ..._businessesList.map((b) {
                                    return DropdownMenuItem(
                                      value: b['id'] as String,
                                      child: Text(
                                        b['name'] != null
                                            ? (b['name'].toString().length > 20
                                                  ? '${b['name'].toString().substring(0, 20)}...'
                                                  : b['name'])
                                            : 'Desconocido',
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedBusinessId = value;
                                    });
                                    _loadRewards();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      // Barra de Búsqueda
                      AppTextField(
                        controller: _searchController,
                        hint: 'Buscar usuario por nombre o email...',
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
                    ],
                  ),
                ),
              ),
            ];
          },
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
                  ),
                )
              : TabBarView(
                  children: [
                    // TAB 1: Usuarios Ganadores
                    _filteredUsers.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: AppColors.pastelOf(AppColors.accentPurple),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.users, size: 56, color: AppColors.accentPurple),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'No hay usuarios que hayan ganado premios en este período'
                                        : 'No se encontraron usuarios',
                                    style: AppTypography.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRewards,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final userSummary = _filteredUsers[index];
                                final userName = (userSummary['user_name'] ?? '').toString();
                                final userEmail = (userSummary['user_email'] ?? '').toString();
                                final rewardsList = userSummary['rewards'] as List;
                                final rewardCount = rewardsList.length;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: ModuleListCard(
                                    icon: LucideIcons.user,
                                    iconBackgroundColor: AppColors.accentPurple,
                                    title: userName,
                                    subtitle: userEmail.isNotEmpty ? userEmail : 'Sin correo registrado',
                                    badgeCount: rewardCount,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminUserRewardsDetailScreen(
                                            userId: userSummary['user_id'],
                                            userName: userName,
                                            userEmail: userEmail,
                                            rewards: List<Map<String, dynamic>>.from(rewardsList),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                    .animate(delay: Duration(milliseconds: 50 * index))
                                    .fadeIn(duration: 400.ms)
                                    .slideX(begin: 0.1, curve: Curves.easeOutBack);
                              },
                            ),
                          ),

                    // TAB 2: Historial Traspasos
                    _buildTransfersList(),
                  ],
                ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredTransfers {
    if (_selectedBusinessId == 'all') return _allTransfers;
    return _allTransfers.where((t) => t['business_id'] == _selectedBusinessId).toList();
  }

  Widget _buildTransfersList() {
    final filtered = _filteredTransfers;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.pastelOf(AppColors.accentOrange),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.arrowLeftRight, size: 56, color: AppColors.accentOrange),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No hay traspasos registrados',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRewards,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final transfer = filtered[index];
          final fromName = transfer['from_user']?['full_name'] ?? 'Usuario Desconocido';
          final fromEmail = transfer['from_user']?['email'] ?? '';
          final toName = transfer['to_user']?['full_name'] ?? 'Usuario Desconocido';
          final toEmail = transfer['to_user']?['email'] ?? '';
          final businessName = transfer['businesses']?['name'] ?? 'Local Desconocido';
          final pts = transfer['rewards']?['points_used'] ?? '?';
          final dateStr = transfer['transferred_at'] != null
              ? EcuadorDateUtils.formatEcuadorTime(transfer['transferred_at'])
              : '';

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadii.card),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REMITENTE',
                            style: AppTypography.labelBold.copyWith(fontSize: 9, color: AppColors.textSecondary),
                          ),
                          Text(
                            fromName,
                            style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          if (fromEmail.isNotEmpty)
                            Text(
                              fromEmail,
                              style: AppTypography.caption,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      dateStr,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Icon(LucideIcons.cornerDownRight, size: 14, color: AppColors.accentOrange),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DESTINATARIO',
                            style: AppTypography.labelBold.copyWith(fontSize: 9, color: AppColors.textSecondary),
                          ),
                          Text(
                            toName,
                            style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          if (toEmail.isNotEmpty)
                            Text(
                              toEmail,
                              style: AppTypography.caption,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: const Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.store, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          businessName,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pastelOf(AppColors.accentPurple),
                        borderRadius: BorderRadius.circular(AppRadii.badge),
                      ),
                      child: Text(
                        '$pts pts',
                        style: AppTypography.labelBold.copyWith(color: AppColors.accentPurple, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
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

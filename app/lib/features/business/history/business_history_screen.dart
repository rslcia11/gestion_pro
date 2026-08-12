import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/shared_widgets.dart';

class BusinessHistoryScreen extends StatefulWidget {
  final String businessId;

  const BusinessHistoryScreen({super.key, required this.businessId});

  @override
  State<BusinessHistoryScreen> createState() => _BusinessHistoryScreenState();
}

class _BusinessHistoryScreenState extends State<BusinessHistoryScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _scans = [];
  List<Map<String, dynamic>> _rewards = [];
  List<Map<String, dynamic>> _transfers = [];
  bool _isLoading = true;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      var scansQuery = supabase
          .from('scans')
          .select('*, profiles!inner(full_name)')
          .eq('business_id', widget.businessId)
          .eq('status', 'approved');

      var rewardsQuery = supabase
          .from('rewards')
          .select('*, description, profiles!inner(full_name)')
          .eq('business_id', widget.businessId);

      var transfersQuery = supabase
          .from('reward_transfer_history')
          .select('*, from_user:from_user_id(full_name), to_user:to_user_id(full_name), rewards(points_used)')
          .eq('business_id', widget.businessId);

      if (_dateRange != null) {
        final start = _dateRange!.start.toUtc().toIso8601String();
        final end = _dateRange!.end.add(const Duration(days: 1)).toUtc().toIso8601String();

        final sQ = scansQuery.gte('scanned_at', start).lt('scanned_at', end);
        final rQ = rewardsQuery.gte('earned_at', start).lt('earned_at', end);
        final tQ = transfersQuery.gte('created_at', start).lt('created_at', end);

        final scansResponse = await sQ.order('scanned_at', ascending: false);
        final rewardsResponse = await rQ.order('earned_at', ascending: false);
        final transfersResponse = await tQ.order('created_at', ascending: false);

        if (mounted) {
          setState(() {
            _scans = List<Map<String, dynamic>>.from(scansResponse);
            _rewards = List<Map<String, dynamic>>.from(rewardsResponse);
            _transfers = List<Map<String, dynamic>>.from(transfersResponse);
            _isLoading = false;
          });
        }
      } else {
        final scansResponse = await scansQuery.order('scanned_at', ascending: false);
        final rewardsResponse = await rewardsQuery.order('earned_at', ascending: false);
        final transfersResponse = await transfersQuery.order('created_at', ascending: false);

        if (mounted) {
          setState(() {
            _scans = List<Map<String, dynamic>>.from(scansResponse);
            _rewards = List<Map<String, dynamic>>.from(rewardsResponse);
            _transfers = List<Map<String, dynamic>>.from(transfersResponse);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silenciar error de tabla no existente temporalmente si el admin no ha pusheado la migracion
        if (e.toString().contains('relation "public.reward_transfers" does not exist')) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aviso: La tabla de transferencias aún no está disponible.')));
        } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = _dateRange ??
        DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now());

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() => _dateRange = pickedRange);
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const AppBarTitle('Historial de Actividad'),
          leading: IconActionButton(
            icon: LucideIcons.arrowLeft,
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Escaneos'),
              Tab(text: 'Premios'),
              Tab(text: 'Traspasos'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            isScrollable: true,
          ),
          actions: [
            IconActionButton(
              icon: _dateRange == null ? LucideIcons.listFilter : LucideIcons.filter,
              iconColor: _dateRange == null ? AppColors.textSecondary : AppColors.primary,
              onPressed: _selectDateRange,
            ),
            if (_dateRange != null)
              IconActionButton(
                icon: LucideIcons.x,
                onPressed: () { setState(() => _dateRange = null); _loadHistory(); },
              ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)))
            : TabBarView(children: [_buildScansList(), _buildRewardsList(), _buildTransfersList()]),
      ),
    );
  }

  Widget _buildScansList() {
    if (_scans.isEmpty) return const Center(child: Text('No hay escaneos en este periodo'));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _scans.length,
      itemBuilder: (context, index) {
        final scan = _scans[index];
        final profileName = (scan['profiles']['full_name'] ?? 'Usuario').toString();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ActivityListCard(
            avatarInitials: profileName.isNotEmpty ? profileName[0] : '?',
            title: profileName,
            description: '+1 Punto',
            timestamp: EcuadorDateUtils.formatEcuadorTime(scan['scanned_at']),
            trailing: Icon(LucideIcons.circleCheck, color: AppColors.accentGreen, size: 20),
          ),
        );
      },
    );
  }

  Widget _buildRewardsList() {
    if (_rewards.isEmpty) return const Center(child: Text('No hay premios en este periodo'));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _rewards.length,
      itemBuilder: (context, index) {
        final reward = _rewards[index];
        final profileName = (reward['profiles']['full_name'] ?? 'Usuario').toString();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ActivityListCard(
            avatarInitials: profileName.isNotEmpty ? profileName[0] : '?',
            avatarUrl: null,
            title: profileName,
            description: (reward['description'] ?? 'Premio').toString(),
            timestamp: EcuadorDateUtils.formatEcuadorTime(reward['earned_at']),
            trailing: Icon(LucideIcons.gift, color: AppColors.accentPurple, size: 20),
          ),
        );
      },
    );
  }

  Widget _buildTransfersList() {
    if (_transfers.isEmpty) return const Center(child: Text('No hay transferencias en este periodo'));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _transfers.length,
      itemBuilder: (context, index) {
        final transfer = _transfers[index];
        final fromName = transfer['from_user']?['full_name'] ?? 'Alguien';
        final toName = transfer['to_user']?['full_name'] ?? 'Alguien';
        final pts = transfer['rewards']?['points_used'] ?? '?';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ActivityListCard(
            avatarInitials: fromName.isNotEmpty ? fromName[0] : '?',
            avatarUrl: null,
            title: '$fromName → $toName',
            description: 'Premio transferido ($pts pts)',
            timestamp: EcuadorDateUtils.formatEcuadorTime(transfer['created_at']),
            trailing: Icon(LucideIcons.arrowLeftRight, color: AppColors.accentBlue, size: 20),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/utils/date_utils.dart';

/// Enum for date range filter options
enum DateRangeFilter {
  today('Hoy', 1),
  week('Semana', 7),
  month('Mes', 30),
  year('Año', 365),
  custom('Personalizado', -1);

  final String label;
  final int days;

  const DateRangeFilter(this.label, this.days);
}

/// Business scan statistics
class BusinessScanStats {
  final String businessId;
  final String businessName;
  final int scanCount;

  const BusinessScanStats({
    required this.businessId,
    required this.businessName,
    required this.scanCount,
  });
}

/// Aggregated scan data
class ScanAggregation {
  final int totalScans;
  final List<BusinessScanStats> topBusinesses;
  final Map<String, int> dailyScans;

  const ScanAggregation({
    required this.totalScans,
    required this.topBusinesses,
    required this.dailyScans,
  });
}

class AdminQrStatsScreen extends StatefulWidget {
  const AdminQrStatsScreen({super.key});

  @override
  State<AdminQrStatsScreen> createState() => _AdminQrStatsScreenState();
}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class _AdminQrStatsScreenState extends State<AdminQrStatsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Filter state
  DateRangeFilter _selectedFilter = DateRangeFilter.week;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Data state
  ScanAggregation? _scanData;
  int _totalScans = 0;
  List<BusinessScanStats> _rankingList = [];

  @override
  void initState() {
    super.initState();
    _loadScanData();
  }

  /// Calculate date range based on selected filter
  (DateTime start, DateTime end) _getDateRange() {
    final startOfDay = EcuadorDateUtils.getStartOfDayEcuadorUtc();
    // Para simplificar y mantener la lógica de las consultas que asumen que devolvemos UTC,
    // devolveremos las fechas ya en UTC (EcuadorDateUtils.getStartOfDayEcuadorUtc es UTC).
    // Nota: 'now' no lo podemos usar directamente porque _loadScanData() llama a .toUtc().
    // Pero si devolvemos UTC, .toUtc() es inofensivo.
    final nowUtc = DateTime.now().toUtc();

    switch (_selectedFilter) {
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

  /// Stub: sin backend conectado — pendiente de integrar nueva DB.
  Future<void> _loadScanData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _getDateRange();

    setState(() {
      _scanData = const ScanAggregation(
        totalScans: 0,
        topBusinesses: [],
        dailyScans: {},
      );
      _totalScans = 0;
      _rankingList = [];
      _isLoading = false;
    });
  }

  /// Show custom date range picker
  Future<void> _showCustomDatePicker() async {
    final now = EcuadorDateUtils.nowEcuador();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
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
      _loadScanData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estadísticas QR', style: AppTypography.titleBold),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconActionButton(icon: LucideIcons.refreshCcw, onPressed: _loadScanData),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            )
          : _errorMessage != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.triangleAlert, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Reintentar',
              onPressed: _loadScanData,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadScanData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date filter buttons
            _buildDateFilterButtons(),
            const SizedBox(height: AppSpacing.lg),

            // Summary card
            _buildSummaryCard(),
            const SizedBox(height: AppSpacing.lg),

            // Bar chart section
            if (_scanData != null && _scanData!.topBusinesses.isNotEmpty) ...[
              _buildChartSection(),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Ranking list
            if (_rankingList.isNotEmpty) _buildRankingList(),
            if (_rankingList.isEmpty && !_isLoading) _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Período', style: AppTypography.subtitleBold),
        const SizedBox(height: AppSpacing.sm + 4),
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
                      _loadScanData();
                    },
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: isSelected ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  filter.label,
                  style: AppTypography.bodyMedium.copyWith(
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
    ).animate().fadeIn(duration: AppTheme.animDurationStandard);
  }

  Widget _buildSummaryCard() {
    return StatCard(
          icon: LucideIcons.qrCode,
          label: 'Escaneos en el período seleccionado',
          value: _totalScans.toString(),
          accentColor: AppColors.accentPurple,
        )
        .animate(delay: 100.ms)
        .fadeIn(duration: AppTheme.animDurationStandard)
        .slideY(begin: 0.1, curve: AppTheme.animCurveStandard);
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top 10 Negocios', style: AppTypography.titleBold),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 300,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.card,
          ),
          child: _buildBarChart(),
        ),
      ],
    ).animate(delay: 200.ms).fadeIn(duration: AppTheme.animDurationStandard);
  }

  Widget _buildBarChart() {
    final businesses = _scanData!.topBusinesses;
    if (businesses.isEmpty) {
      return Center(
        child: Text(
          'No hay datos para mostrar',
          style: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final maxY = businesses.first.scanCount.toDouble() * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 1 ? 1 : maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final business = businesses[group.x.toInt()];
              return BarTooltipItem(
                '${business.businessName}\n',
                AppTypography.labelBold.copyWith(color: AppColors.onPrimary, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${business.scanCount} escaneos',
                    style: TextStyle(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < businesses.length) {
                  final name = businesses[index].businessName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    // Texto vertical: evita que los nombres de negocios se
                    // solapen cuando hay varias barras juntas.
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        name.length > 14 ? '${name.substring(0, 14)}…' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 90,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTypography.caption.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: businesses.asMap().entries.map((entry) {
          final index = entry.key;
          final business = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: business.scanCount.toDouble(),
                gradient: const LinearGradient(
                  colors: [AppColors.accentPurple, AppColors.accentPink],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankingList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ranking de Negocios', style: AppTypography.titleBold),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.card,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rankingList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final business = _rankingList[index];
              final position = index + 1;
              final isTop3 = position <= 3;
              final positionColor = _getPositionColor(position);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: AppSpacing.sm,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isTop3 ? AppColors.pastelOf(positionColor) : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isTop3
                        ? Icon(LucideIcons.trophy, color: positionColor, size: 20)
                        : Text(
                            '#$position',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                title: Text(
                  business.businessName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 4,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isTop3 ? AppColors.pastelOf(positionColor) : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.badge),
                  ),
                  child: Text(
                    '${business.scanCount}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isTop3 ? positionColor : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate(delay: 300.ms).fadeIn(duration: AppTheme.animDurationStandard);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              LucideIcons.qrCode,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin escaneos en este período',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No hay datos de escaneos aprobados\npara el rango de fechas seleccionado.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}

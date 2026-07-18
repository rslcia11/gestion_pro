import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final String? toastMessage;
  final bool toastIsError;
  final Map<String, dynamic>? business;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> pendingScans;
  final List<Map<String, dynamic>> pendingRewards;
  final String ownerName;

  DashboardState({
    this.isLoading = true,
    this.error,
    this.toastMessage,
    this.toastIsError = false,
    this.business,
    this.customers = const [],
    this.pendingScans = const [],
    this.pendingRewards = const [],
    this.ownerName = '',
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    String? toastMessage,
    bool? toastIsError,
    Map<String, dynamic>? business,
    List<Map<String, dynamic>>? customers,
    List<Map<String, dynamic>>? pendingScans,
    List<Map<String, dynamic>>? pendingRewards,
    String? ownerName,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? false,
      business: business ?? this.business,
      customers: customers ?? this.customers,
      pendingScans: pendingScans ?? this.pendingScans,
      pendingRewards: pendingRewards ?? this.pendingRewards,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class DashboardNotifier extends Notifier<DashboardState> {
  Timer? _reloadDebounce;
  DateTime? _lastLoadedAt;

  @override
  DashboardState build() {
    Future.microtask(() => loadData());

    ref.onDispose(() {
      _reloadDebounce?.cancel();
    });

    return DashboardState();
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 350), () {
      loadData(silent: true);
    });
  }

  void reloadIfStale({Duration maxAge = const Duration(seconds: 20)}) {
    if (state.isLoading) return;
    final last = _lastLoadedAt;
    if (last == null || DateTime.now().difference(last) > maxAge) {
      _scheduleReload();
    }
  }

  Future<void> loadData({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final repo = ref.read(dashboardRepositoryProvider);
    final business = await repo.fetchBusiness('');

    state = state.copyWith(
      isLoading: false,
      business: business,
      customers: const [],
      pendingScans: const [],
      pendingRewards: const [],
    );
    _lastLoadedAt = DateTime.now();
  }

  Future<void> addManualPoints(String userId, int points) async {
    final businessId = state.business?['id'];
    if (businessId == null) return;
    await ref.read(dashboardRepositoryProvider).addManualPoints(
      userId: userId,
      businessId: businessId,
      points: points,
    );
    state = state.copyWith(toastMessage: '✅ ¡Puntos agregados!', toastIsError: false);
    _scheduleReload();
  }

  Future<void> approveScan(String scanId, String loyaltyCardId) async {
    final rewardGenerated = await ref.read(dashboardRepositoryProvider).approveScan(
      scanId: scanId,
      loyaltyCardId: loyaltyCardId,
    );
    state = state.copyWith(
      toastMessage: rewardGenerated ? 'Escaneo aprobado. ¡Premio generado!' : 'Escaneo aprobado',
      toastIsError: false,
    );
    _scheduleReload();
  }

  Future<void> rejectScan(String scanId) async {
    await ref.read(dashboardRepositoryProvider).rejectScan(scanId);
    state = state.copyWith(toastMessage: 'Escaneo rechazado', toastIsError: false);
    _scheduleReload();
  }

  Future<void> redeemReward(String userId, String cardId) async {
    final businessId = state.business?['id'];
    if (businessId == null) return;
    await ref.read(dashboardRepositoryProvider).redeemReward(
      userId: userId,
      businessId: businessId,
      cardId: cardId,
    );
    state = state.copyWith(toastMessage: 'Premio canjeado', toastIsError: false);
    _scheduleReload();
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class DashboardRepository {
  DashboardRepository();

  Future<Map<String, dynamic>?> fetchBusiness(String userId) async => null;

  Future<List<Map<String, dynamic>>> fetchCustomers(String businessId) async => [];

  Future<List<Map<String, dynamic>>> fetchPendingScans(String businessId) async => [];

  Future<List<Map<String, dynamic>>> fetchPendingRewards(String businessId) async => [];

  Future<void> addManualPoints({
    required String userId,
    required String businessId,
    required int points,
  }) async {}

  Future<bool> approveScan({
    required String scanId,
    required String loyaltyCardId,
  }) async => false;

  Future<void> rejectScan(String scanId) async {}

  Future<void> redeemReward({
    required String userId,
    required String businessId,
    required String cardId,
  }) async {}
}

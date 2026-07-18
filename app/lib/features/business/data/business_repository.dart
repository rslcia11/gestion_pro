import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/business_category.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository();
});

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class BusinessRepository {
  BusinessRepository();

  Future<List<BusinessCategory>> getCategories() async => [];

  Future<String?> uploadLogo({
    required String userId,
    required Uint8List fileBytes,
    required String fileExt,
  }) async => null;

  Future<String> createBusiness({
    required String userId,
    required String name,
    String? description,
    String? logoUrl,
    String? address,
    double? latitude,
    double? longitude,
    String? categoryId,
    required String rewardDescription,
    String? rewardLongDescription,
    required int pointsRequired,
  }) async => '';

  Future<void> generateInitialQrCode(String businessId) async {}

  Future<void> updateBusinessRoleInAuth(String businessId) async {}
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class ProfileRepository {
  ProfileRepository();

  Future<Map<String, dynamic>?> getProfile(String userId) async => null;

  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
  }) async {}
}

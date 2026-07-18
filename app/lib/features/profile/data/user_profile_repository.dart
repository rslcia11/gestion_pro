import 'package:image_picker/image_picker.dart';

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class UserProfileRepository {
  Future<Map<String, dynamic>?> getProfile(String userId) async => null;

  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
    XFile? avatarFile,
  }) async {}

  Future<void> deleteAccount(String userId) async {}

  Future<void> changePassword(String newPassword) async {}
}

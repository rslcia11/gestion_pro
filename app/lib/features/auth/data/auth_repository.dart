import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class AuthRepository {
  Object? get currentSession => null;
  Object? get currentUser => null;

  Stream<void> get authStateChanges => const Stream.empty();

  Future<void> signOut() async {}

  Future<void> refreshSession() async {}

  Future<bool> isBusinessActive(String businessId) async => false;
}

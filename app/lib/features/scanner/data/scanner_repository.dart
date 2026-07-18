import 'package:flutter_riverpod/flutter_riverpod.dart';

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepository();
});

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class ScannerRepository {
  ScannerRepository();

  Future<String> validateScan(String qrCode, String userId) async {
    throw Exception('Backend no conectado.');
  }
}

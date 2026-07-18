/// Stub: sin backend conectado — pendiente de integrar nueva DB.
class RewardTransferService {
  RewardTransferService();

  Future<Map<String, dynamic>?> findUserByEmail(String email) async => null;

  Future<void> transferReward(String rewardId, String toEmail) async {
    throw TransferException('USER_NOT_FOUND', 'Backend no conectado.');
  }
}

class TransferException implements Exception {
  final String code;
  final String message;

  TransferException(this.code, this.message);

  @override
  String toString() => message;
}

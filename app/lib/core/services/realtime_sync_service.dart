import 'dart:async';

/// Stub: sin backend conectado — pendiente de integrar nueva DB. Los streams
/// se mantienen para que las pantallas que ya se suscriben a ellos sigan
/// compilando; simplemente nunca emiten sin un backend real detrás.
class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  final _scansController = StreamController<Map<String, dynamic>?>.broadcast();
  final _rewardsController = StreamController<Map<String, dynamic>?>.broadcast();
  final _loyaltyCardsController = StreamController<Map<String, dynamic>?>.broadcast();
  final _rewardTransfersController = StreamController<Map<String, dynamic>?>.broadcast();
  final _qrCodesController = StreamController<Map<String, dynamic>?>.broadcast();

  Stream<Map<String, dynamic>?> get onScansChanged => _scansController.stream;
  Stream<Map<String, dynamic>?> get onRewardsChanged => _rewardsController.stream;
  Stream<Map<String, dynamic>?> get onLoyaltyCardsChanged => _loyaltyCardsController.stream;
  Stream<Map<String, dynamic>?> get onRewardTransfersChanged => _rewardTransfersController.stream;
  Stream<Map<String, dynamic>?> get onQrCodesChanged => _qrCodesController.stream;

  void initialize() {}

  void reset() {}

  void dispose() {
    _scansController.close();
    _rewardsController.close();
    _loyaltyCardsController.close();
    _rewardTransfersController.close();
    _qrCodesController.close();
  }
}

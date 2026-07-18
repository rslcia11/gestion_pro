// Stub: sin backend conectado — pendiente de integrar nueva DB.
class MyCardsRepository {
  MyCardsRepository();

  Future<Map<String, dynamic>?> getUserProfile() async => null;

  Future<List<Map<String, dynamic>>> getLoyaltyCards() async => [];

  void setupRealtimeSubscription({
    required void Function(Map<String, dynamic> newData, Map<String, dynamic> oldData) onCardUpdated,
  }) {}
}

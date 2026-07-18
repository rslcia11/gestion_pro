import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cardHistoryRepositoryProvider = Provider<CardHistoryRepository>((ref) {
  return CardHistoryRepository();
});

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class CardHistoryRepository {
  CardHistoryRepository();

  Future<List<List<Map<String, dynamic>>>> fetchHistory(String cardId, String businessId, DateTimeRange? range) async {
    return [[], []];
  }
}

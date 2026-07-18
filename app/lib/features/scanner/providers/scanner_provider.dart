import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scanner_repository.dart';

class ScannerState {
  final bool isProcessing;
  final String? error;
  final String? cooldownHours;
  final bool hasPendingReward;
  final String? successBusinessName;

  ScannerState({
    this.isProcessing = false,
    this.error,
    this.cooldownHours,
    this.hasPendingReward = false,
    this.successBusinessName,
  });

  ScannerState copyWith({
    bool? isProcessing,
    String? error,
    String? cooldownHours,
    bool? hasPendingReward,
    String? successBusinessName,
  }) {
    return ScannerState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      cooldownHours: cooldownHours,
      hasPendingReward: hasPendingReward ?? false,
      successBusinessName: successBusinessName,
    );
  }

  ScannerState clearMessages() {
    return ScannerState(
      isProcessing: isProcessing,
      error: null,
      cooldownHours: null,
      hasPendingReward: false,
      successBusinessName: null,
    );
  }
}

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() {
    return ScannerState();
  }

  void reset() {
    state = state.clearMessages();
  }

  Future<void> validateScan(String qrCode) async {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true).clearMessages();

    try {
      final businessName = await ref.read(scannerRepositoryProvider).validateScan(qrCode, '');

      state = state.copyWith(
        isProcessing: false,
        successBusinessName: businessName,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Backend no conectado.',
      );
    }
  }
}

final scannerProvider = NotifierProvider<ScannerNotifier, ScannerState>(() {
  return ScannerNotifier();
});

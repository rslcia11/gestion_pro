import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/dashboard/providers/dashboard_provider.dart';
import '../../business/providers/create_business_provider.dart';
import '../../business/rewards/providers/rewards_management_provider.dart';
import '../../cards/providers/card_history_provider.dart';
import '../../cards/providers/my_cards_provider.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../main.dart';

// Definición de estados posibles para la sesión
abstract class AuthStateStatus {}

class AuthInitial extends AuthStateStatus {}
class AuthUnauthenticated extends AuthStateStatus {}
class AuthAdmin extends AuthStateStatus {}
class AuthBusinessActive extends AuthStateStatus {}
class AuthBusinessInactive extends AuthStateStatus {}
class AuthBusinessPendingCreate extends AuthStateStatus {}
class AuthClient extends AuthStateStatus {}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class AuthNotifier extends Notifier<AuthStateStatus> {
  void _clearSessionScopedState() {
    ref.invalidate(cardHistoryProvider);
    ref.invalidate(createBusinessProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(myCardsProvider);
    ref.invalidate(rewardsManagementProvider);
    ref.invalidate(scannerProvider);
    ref.invalidate(userProfileProvider);
  }

  @override
  AuthStateStatus build() {
    return AuthUnauthenticated();
  }

  Future<void> checkAuth() async {
    state = AuthUnauthenticated();
  }

  Future<void> logout() async {
    _clearSessionScopedState();
    state = AuthUnauthenticated();

    final context = globalNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthStateStatus>(() {
  return AuthNotifier();
});

// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';
import 'package:app/features/auth/login_screen.dart';
import 'support/supabase_test_setup.dart';

void main() {
  setUpAll(() async {
    await initializeTestSupabase();
  });

  testWidgets('App initializes and shows the login screen when unauthenticated', (WidgetTester tester) async {
    // AppRoot espera un ProviderScope ancestro (lo provee runApp() en main(),
    // no el widget en sí) — sin esto, AuthWrapper (ConsumerStatefulWidget)
    // no puede leer providers de Riverpod.
    await tester.pumpWidget(const ProviderScope(child: AppRoot()));
    await tester.pumpAndSettle();

    // Sin sesión activa, AuthNotifier resuelve a AuthUnauthenticated y
    // AuthWrapper entra por LoginScreen (el design-preview/role-picker que
    // existía antes de reconectar el backend real ya no existe).
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}

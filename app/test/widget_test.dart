// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App initializes and shows the design preview screen', (WidgetTester tester) async {
    // AppRoot espera un ProviderScope ancestro (lo provee runApp() en main(),
    // no el widget en sí) — sin esto, AuthWrapper (ConsumerStatefulWidget)
    // no puede leer providers de Riverpod.
    await tester.pumpWidget(const ProviderScope(child: AppRoot()));
    await tester.pump();

    // AuthWrapper es puramente front (sin backend) y siempre muestra
    // DesignPreviewScreen, donde quien revisa el diseño elige a mano qué rol
    // ver (cliente/negocio/admin), sin auth real.
    expect(find.text('Donde Siempre'), findsWidgets);
    // StatusChip muestra el label en mayúsculas.
    expect(find.text('EN DESARROLLO'), findsOneWidget);
  });
}

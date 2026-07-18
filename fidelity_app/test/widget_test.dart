// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fidelity_app/main.dart';
import 'package:fidelity_app/core/config/supabase_config.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  });

  testWidgets('App initializes and shows the design preview screen', (WidgetTester tester) async {
    // FidelityApp espera un ProviderScope ancestro (lo provee runApp() en
    // main(), no el widget en sí) — sin esto, AuthWrapper (ConsumerStatefulWidget)
    // no puede leer providers de Riverpod.
    await tester.pumpWidget(const ProviderScope(child: FidelityApp()));
    await tester.pump();

    // Mientras `designPreviewMode` esté activo en AuthWrapper, la app arranca
    // directo en DesignPreviewScreen (sin login ni backend) en vez del spinner
    // de auth. Si se vuelve a conectar un backend real, este assert hay que
    // actualizarlo a lo que corresponda mostrar en ese momento.
    expect(find.text('Donde Siempre'), findsWidgets);
    // StatusChip muestra el label en mayúsculas.
    expect(find.text('EN DESARROLLO'), findsOneWidget);
  });
}

// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fidelity_app/features/business/create_business_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fidelity_app/core/config/supabase_config.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (_) {
      // Already initialized
    }
  });

  testWidgets('CreateBusinessScreen smoke test: renders the 4-step wizard', (
    WidgetTester tester,
  ) async {
    // CreateBusinessScreen es un ConsumerStatefulWidget: necesita un
    // ProviderScope ancestro para leer sus providers (createBusinessProvider,
    // businessRepositoryProvider, etc.).
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CreateBusinessScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Título de la pantalla.
    expect(find.text('Configurar Negocio'), findsOneWidget);

    // El Stepper (StepperType.vertical) solo mantiene construidos el/los
    // pasos cercanos al activo dentro del viewport de test — no asumimos que
    // los 4 títulos estén simultáneamente en el árbol sin hacer scroll.
    expect(find.text('Logo de la Tienda'), findsOneWidget);
    expect(find.text('Datos Personales'), findsOneWidget);

    // El paso 1 (Logo) está activo por defecto — su contenido debe verse.
    expect(find.text('Añade el logo de tu negocio'), findsOneWidget);

    // Botón para avanzar de paso (el Stepper puede duplicar internamente los
    // controles según el layout adaptativo — solo confirmamos que existe).
    expect(find.text('Siguiente'), findsWidgets);

    // Scrolleamos hasta el final para confirmar que el resto de los pasos
    // también están en el árbol (Stepper no es lazy, pero puede requerir
    // desplazar el Scrollable del test para quedar dentro del viewport).
    await tester.dragUntilVisible(
      find.text('Datos de Campaña'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    expect(find.text('Datos de Campaña'), findsOneWidget);
  });
}

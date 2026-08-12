import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Inicializa Supabase para tests de widgets.
///
/// La app real apunta al backend self-hosted en una EC2 con IP dinámica (ver
/// `SupabaseConfig`), inalcanzable desde este entorno de test. Acá usamos una
/// URL localhost cualquiera en su lugar: `Supabase.initialize()` no espera a
/// que la sesión se recupere del servidor -- esa llamada de red queda
/// encapsulada en un `CancelableOperation` que corre en segundo plano y no
/// bloquea el `Future` de `initialize` (ver
/// `supabase_flutter/src/supabase.dart`) -- así que el init se completa igual
/// sin conectividad real, y cualquier request posterior (p.ej. un `.select()`
/// en un test) falla rápido con "connection refused" en vez de colgarse.
///
/// Llamar una sola vez por archivo de test, dentro de `setUpAll`.
Future<void> initializeTestSupabase() async {
  SharedPreferences.setMockInitialValues({});
  await Supabase.initialize(
    url: 'http://localhost:54321',
    publishableKey: 'test-anon-key',
    debug: false,
  );
}

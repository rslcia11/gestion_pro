/// DESCONECTADO TEMPORALMENTE (pedido del usuario 2026-07-04): mientras se
/// termina el rediseño de UI, la app no debe hablar con el proyecto Supabase
/// real. Se invalida solo la URL (no las credenciales) para que el SDK
/// inicialice sin crashear pero ninguna llamada de red llegue a un backend
/// real. Restaurar la URL real de abajo cuando se reconecte un backend.
class SupabaseConfig {
  static const String supabaseUrl = 'https://disconnected-for-redesign.invalid';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndkeHF0dGlma3pubHN3Z3loeXdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5OTkwNTAsImV4cCI6MjA4NTU3NTA1MH0.AE8nWVgWmSumGWPqQntB6I5wAlZJuVLTBacDZcNWkdw';

  // static const String supabaseUrl = 'https://wdxqttifkznlswgyhywb.supabase.co';
}

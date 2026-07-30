/// Backend: Supabase self-hosted en una EC2 propia (ver ESTADO_MIGRACION.md
/// en la raíz del repo). La IP pública es dinámica — cambia cada vez que se
/// prende/apaga la instancia. Actualizar `supabaseUrl` cuando eso pase.
class SupabaseConfig {
  static const String supabaseUrl = 'http://54.227.21.104:8000';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzg0Nzc4MDc3LCJleHAiOjIxMDAxMzgwNzd9.H5kLXWZGKs3BWItyh_RRfFPThNCgoxgEitqKzoGUQ_4';
}

-- ============================================================================
-- DONDE SIEMPRE — Storage: buckets + RLS para avatars / business-logos.
--
-- Contexto: los buckets 'avatars' y 'business-logos' existen en la instancia
-- self-hosted (EC2) solo porque se copiaron a mano vía la API de Storage
-- durante la migración Cloud -> self-hosted (ver ESTADO_MIGRACION.md). No hay
-- ninguna migración SQL que documente su configuración (public/límites) ni
-- políticas RLS sobre storage.objects para ellos. Este archivo lo corrige de
-- forma reproducible e idempotente.
--
-- Los 5 flujos de subida de imágenes de la app (registro de cliente, logo de
-- negocio en onboarding/dashboard/perfil, avatar de usuario) ya llaman a
-- supabase.storage.from(bucket).uploadBinary(...) + .getPublicUrl(...) y
-- suben siempre a la ruta "$userId/$fileName". Este archivo:
--   1. Crea (o normaliza, si ya existen) los buckets como públicos, con un
--      límite de tamaño/mime-type como red de seguridad.
--   2. Agrega políticas RLS sobre storage.objects: lectura pública, y
--      insert/update/delete restringidos a la propia carpeta ($userId/...).
--
-- Todo en una transacción: si algo falla, no se aplica nada.
-- Aplicar en el SQL Editor de Supabase (self-hosted, panel Studio).
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 0. RLS de storage.objects: normalmente ya viene habilitado de fábrica en
--    Supabase, pero como no podemos verificar el estado exacto de esta
--    instancia self-hosted desde el repo, lo reafirmamos. Es un no-op seguro
--    si ya estaba habilitado.
-- ----------------------------------------------------------------------------
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- 1. Buckets: crear si no existen; si ya existen (migración manual previa),
--    normalizar su configuración a lo que la app necesita, sin tocar
--    id/name/owner/created_at.
--    - public = true: los 5 flujos usan getPublicUrl() y esperan URLs
--      servidas sin autenticación.
--    - file_size_limit = 5 MiB: red de seguridad. Todos los pickers ya
--      comprimen (imageQuality 70-80, maxWidth/maxHeight 800 o
--      flutter_image_compress quality 70), así que el resultado real es
--      muchísimo menor.
--    - allowed_mime_types: mismo set de 4 tipos que el código Dart ya asume
--      al fijar el contentType (business_repository.dart,
--      business_dashboard_screen.dart).
-- ----------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
  ('business-logos', 'business-logos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ----------------------------------------------------------------------------
-- 2. Bucket 'avatars': lectura pública + escritura restringida a la propia
--    carpeta ($userId/...). storage.foldername(name) devuelve un text[] con
--    los segmentos de carpeta del object key; el [1] es el $userId con el
--    que la app arma la ruta en los 3 puntos que tocan este bucket
--    (register_screen.dart, user_profile_repository.dart).
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public read access for avatars" ON storage.objects;
CREATE POLICY "Public read access for avatars" ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
CREATE POLICY "Users can upload their own avatar" ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Necesaria para uploadBinary(..., upsert: true) cuando el objeto YA existe
-- (user_profile_repository.dart sube siempre a la misma ruta fija
-- "$userId/avatar.$ext", así que la 2da edición en adelante pasa por UPDATE).
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
CREATE POLICY "Users can update their own avatar" ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;
CREATE POLICY "Users can delete their own avatar" ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- ----------------------------------------------------------------------------
-- 3. Bucket 'business-logos': mismo patrón. El dueño del negocio sube a
--    "$userId/$fileName" en step_logo_picker.dart / business_repository.dart
--    (onboarding), business_dashboard_screen.dart y business_profile_screen.dart.
--    business_dashboard_screen.dart además llama a .remove([objectPath]),
--    por eso el DELETE acá es obligatorio (no solo simétrico como en avatars).
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public read access for business-logos" ON storage.objects;
CREATE POLICY "Public read access for business-logos" ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'business-logos');

DROP POLICY IF EXISTS "Users can upload their own business logo" ON storage.objects;
CREATE POLICY "Users can upload their own business logo" ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'business-logos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "Users can update their own business logo" ON storage.objects;
CREATE POLICY "Users can update their own business logo" ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'business-logos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'business-logos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "Users can delete their own business logo" ON storage.objects;
CREATE POLICY "Users can delete their own business logo" ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'business-logos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

COMMIT;

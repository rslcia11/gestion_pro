# 🛠️ Guía de Configuración y Despliegue (Setup)

Seguí estos pasos para poner el proyecto en marcha desde cero.

## 1. Requisitos del Sistema

-   **Flutter SDK**: ^3.8.1
-   **Dart SDK**: ^3.x
-   **Firebase CLI** (para gestión de notificaciones push).

## 2. Configuración del Frontend (Flutter)

1.  Navegá a `/app` y ejecutá `flutter pub get`.
2.  **Firebase (Push)**: el proyecto ya viene configurado con `lib/firebase_options.dart`. Si necesitás apuntarlo a un proyecto Firebase propio:
    -   Configurá un proyecto en Firebase Console.
    -   Descargá `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) y reemplazá los existentes en `android/app/` e `ios/Runner/`.
    -   Ejecutá `flutterfire configure` para regenerar `lib/firebase_options.dart`.
3.  Ejecutá `flutter run`. La app arranca directo en `DesignPreviewScreen` (selector de rol cliente/negocio/admin), sin login ni backend conectado — toda la capa de datos está stubbeada.

## 3. Backend (referencia histórica, no conectado)

El proyecto original usaba **Supabase**, cuyo esquema y funciones siguen en `/supabase` como referencia (ver [`database.md`](./database.md) y [`business_rules.md`](./business_rules.md)), pero la app **no lo consume actualmente**. Para conectar un backend nuevo:

1.  Elegí e implementá la base de datos que corresponda.
2.  Reemplazá la lógica interna de los `repository` en `lib/features/*/data/` y `lib/core/services/` (hoy son stubs que devuelven datos vacíos) — mantené sus firmas públicas para no tener que tocar las pantallas que los consumen.
3.  Si el nuevo backend maneja auth, revisá `lib/features/auth/` (`login_screen.dart`, `register_screen.dart`, `providers/auth_provider.dart`, `data/auth_repository.dart`) y `AuthWrapper` para reactivar el flujo de login real en lugar de `DesignPreviewScreen`.

---
> [!IMPORTANT]
> El único servicio externo activo hoy es Firebase Cloud Messaging (push notifications) — no requiere ninguna configuración adicional de backend de datos.

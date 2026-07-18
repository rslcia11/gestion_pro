# 🏗️ Arquitectura del Frontend (Flutter)

El frontend de Donde Siempre está diseñado siguiendo principios de **Feature-first**, priorizando la cohesión y el desacoplamiento. Hoy es una app puramente front: no tiene backend conectado.

## 📂 Estructura de Carpetas

### `lib/core`
El corazón compartido de la aplicación. Contiene código que no pertenece a ninguna funcionalidad específica:
-   **`services/`**: Servicios globales (Notificaciones push vía Firebase, Exportación CSV, Transferencia de Premios). La mayoría son stubs sin lógica real de datos, salvo el de notificaciones (Firebase sigue activo).
-   **`theme/`**: El sistema de diseño extraído de Figma. Centraliza colores, tipografías (Poppins & Inter), radios, sombras y espaciado (`app_colors.dart`, `app_typography.dart`, `app_radii.dart`, `app_shadows.dart`, `app_spacing.dart`), orquestados por `app_theme.dart`.
-   **`utils/`**: Helpers para fechas, formateo, etc.
-   **`validators/`**: Lógica de validación de formularios reutilizable.

### `lib/shared/widgets`
Librería de componentes visuales compartidos (botones, inputs, cards, tags de estado, etc.) usados por todas las pantallas para mantener el diseño consistente.

### `lib/features`
La aplicación se divide por dominios de negocio. Cada carpeta representa una "Feature" completa:
-   **`auth/`**: Contiene `AuthWrapper`, que hoy siempre muestra `DesignPreviewScreen` — un selector de rol (cliente/negocio/admin) sin login real. `login_screen.dart`/`register_screen.dart` existen como UI ya diseñada pero no son navegables desde el flujo actual.
-   **`business/`**: Todo lo relacionado con el dashboard del dueño, gestión de locales y creación de negocios.
-   **`cards/`**: La vista de "Mis Tarjetas" para el cliente.
-   **`scanner/`**: La interfaz de cámara y lógica de procesamiento de QR.
-   **`admin/`**: Panel de control global con métricas y gestión de usuarios/negocios.

## 🎨 Sistema de Diseño y Animaciones

El diseño visual sale de un archivo de Figma de referencia: fondo claro, cards con sombra suave, botones pill, íconos del set **Lucide**, tipografía **Poppins** (títulos/CTA) e **Inter** (cuerpo).
-   **Animaciones**: Implementamos `flutter_animate` para micro-interacciones.
    -   *Regla de Oro*: Las animaciones deben ser sutiles (300-600ms) y mejorar la UX, no retrasar al usuario.

## 🔄 Flujo de Datos (estado actual: sin backend)

Todos los `repository`/`provider` de `lib/features/*/data` y `lib/features/*/providers` están **stubbeados**: mantienen la misma firma pública que tenían cuando llamaban a Supabase, pero sus métodos de lectura devuelven listas/valores vacíos de forma inmediata (sin red) y los de escritura son no-ops. Esto permite que toda la UI compile y se navegue mostrando sus estados vacíos ya diseñados, sin depender de ningún servicio externo.

Cuando se conecte una base de datos nueva, el trabajo es reemplazar la implementación interna de esos repositories — las pantallas y providers que los consumen no deberían necesitar cambios, porque ya están desacoplados detrás de esas interfaces.

---
> [!TIP]
> Si vas a crear una nueva funcionalidad, creá una carpeta dentro de `features/` y tratá de que sea lo más independiente posible del resto.

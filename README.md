# 💳 Donde Siempre - Plataforma de Fidelización Inteligente

Donde Siempre es una solución de fidelización de clientes para negocios locales. Permite a los comercios gestionar programas de recompensas de forma digital y a los usuarios acumular puntos mediante el escaneo de códigos QR, eliminando las tarjetas de cartón físicas.

## 🚀 Arquitectura del Proyecto

El repo tiene dos partes que hoy **no están conectadas entre sí**:

1.  **App (Flutter)**: Ubicada en `/app`. Es puramente front — toda la lógica de datos (repositories/providers) está stubbeada (devuelve valores vacíos, no llama a ningún backend), lista para integrarse con una base de datos nueva. Implementa **Feature-first architecture** para garantizar escalabilidad y testeabilidad.
2.  **Backend (Supabase)**: Ubicado en `/supabase`. Es el backend original del proyecto (PostgreSQL, triggers y RPCs en PL/pgSQL) — sigue existiendo en el repo como referencia de las reglas de negocio, pero la app **ya no lo consume**.

## 🛠 Tech Stack

-   **Frontend**: Flutter (v3.x) + Riverpod (State Management).
-   **Backend**: sin conectar (Supabase queda en `/supabase` solo como referencia histórica).
-   **Notificaciones**: Firebase Cloud Messaging (FCM) — es el único servicio externo que sigue activo.

## 📖 Índice de Documentación Detallada

Para entender a fondo el sistema, revisá los siguientes documentos en la carpeta `/docs`:

-   [Arquitectura y Capas del Frontend](./docs/architecture.md)
-   [Esquema de Base de Datos y Lógica de Servidor (referencia histórica)](./docs/database.md)
-   [Reglas de Negocio y Flujos Críticos (referencia histórica)](./docs/business_rules.md)
-   [Guía de Configuración y Despliegue](./docs/setup.md)

## 🏁 Inicio Rápido (Local)

### Requisitos
-   Flutter SDK (^3.x)

### Pasos
1.  Cloná el repositorio.
2.  Navegá a `app/` y ejecutá `flutter pub get`.
3.  Ejecutá `flutter run`. La app arranca directo en una pantalla de selección de rol (cliente/negocio/admin) sin login, ya que no hay backend conectado.

---
*Desarrollado con ❤️ para transformar el comercio local.*

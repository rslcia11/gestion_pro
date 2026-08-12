# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Two primary audiences, held to equal design priority (confirmed):

- **Cliente final**: acumula puntos escaneando códigos QR en comercios adheridos, canjea premios, y puede recibir/transferir premios a otros usuarios.
- **Dueño de negocio**: configura su programa de fidelización (puntos requeridos, cooldown entre escaneos, descripción del premio), aprueba/rechaza escaneos pendientes, y gestiona canjes.

Rol secundario/operativo: **Admin**, que supervisa negocios, usuarios, categorías, actividad y estadísticas de QR a nivel de plataforma (no es un usuario final del programa de fidelización, sino de la operación de la plataforma).

Rol resuelto vía `user.userMetadata['role']` (`app/lib/features/auth/providers/auth_provider.dart`); `client` es el valor por defecto cuando no hay rol explícito.

## Product Purpose

Donde Siempre es una plataforma digital de fidelización de clientes que reemplaza las tarjetas de sellos de papel/cartón por tarjetas de puntos digitales basadas en QR. Los negocios administran su programa de recompensas digitalmente; los clientes acumulan puntos escaneando QR en cada visita y canjean premios al alcanzar el umbral configurado.

## Positioning

Pensada específicamente para comercios locales e independientes (no cadenas grandes) — sin las comisiones ni la complejidad de plataformas de fidelización corporativas (confirmado por el usuario).

## Operating Context

Loop de fidelización real, de punta a punta (verificado en código):

1. Cliente escanea el QR del negocio (`scanner_repository.dart`) → se busca/crea su `loyalty_cards` para ese negocio → si no hay premio pendiente, se inserta un `scans` con estado `pending` (un trigger de DB aplica el cooldown configurado por el negocio).
2. El negocio aprueba o rechaza el escaneo pendiente desde su dashboard (`dashboard_repository.dart`).
3. Al aprobarse, el punto se acredita en `loyalty_cards`; al alcanzar `points_required` se genera un registro en `rewards` (estado `pending`).
4. El premio se puede canjear en el negocio, o **transferir a otro usuario** — mecánica social encontrada en el código (`reward_transfer_history`, `card_history_repository.dart`) con notificación en tiempo real tipo celebración ("¡TE HAN TRANSFERIDO!") vía `RealtimeSyncService` cuando el usuario es el receptor.
5. El admin opera la plataforma: aprueba/activa negocios, gestiona categorías globales, supervisa actividad y estadísticas de QR, y tiene visibilidad de premios entregados.

## Capabilities and Constraints

- Backend: Supabase self-hosted en una instancia EC2 propia (AWS), con IP pública dinámica — se reconfigura manualmente en `app/lib/core/config/supabase_config.dart` cada vez que la instancia se reinicia. Esto es una restricción operativa real, no solo de infraestructura: cualquier feature que asuma conectividad constante debe tolerar caídas/timeouts del backend.
- Notificaciones push vía Firebase Cloud Messaging; sincronización en tiempo real vía canales Postgres-changes de Supabase (`scans`, `rewards`, `loyalty_cards`, `reward_transfer_history`, `qr_codes`).
- Cooldown entre escaneos configurable por negocio (anti-abuso).
- Un usuario no puede generar un nuevo escaneo mientras tenga un premio pendiente sin resolver.
- Sin capa de tests de integración/E2E (solo `flutter test` unitario/widget — ver `openspec/config.yaml`); los flujos que cruzan roles (cliente↔negocio↔admin) no tienen cobertura automatizada más allá de unit/widget tests.

## Brand Commitments

- Nombre público: **Donde Siempre** (confirmado en `MaterialApp(title:)`, `AndroidManifest.xml`, `Info.plist`). Nota: un comentario interno legacy en `app_colors.dart` llama al sistema de diseño "Gestión Pro" — es un nombre interno obsoleto, no debe usarse de cara al usuario ni propagarse a documentación nueva.
- Colores primarios (`app/lib/core/theme/app_colors.dart`): fondo `#F5F5F5`, primario `#000000` (negro); set de acento: ámbar `#F59E0B`, púrpura `#9333EA`, rosa `#DB2777`, verde `#16A34A`, naranja `#EA580C`, rosado intenso `#E11D48`, azul `#2563EB`.
- Logo: `app/assets/images/logo_blanco.png` (usado también como ícono de la app).
- Contacto de soporte (`app/lib/core/theme/app_theme.dart`): WhatsApp `+593995371895`, email `soporte@dondesiempre.app`.

## Evidence on Hand

- `README.md` (raíz del repo) y `ESTADO_MIGRACION.md` documentan el estado de la migración de backend.
- **Inconsistencia detectada**: `README.md` describe la app como "stubbed"/sin backend conectado — esa descripción está desactualizada; el código actual (`auth_wrapper.dart`, `scanner_repository.dart`, `dashboard_repository.dart`, etc.) hace llamadas reales a Supabase contra tablas de producción. Trabajo futuro no debe asumir el estado "stub" que describe el README; convendría actualizarlo (fuera del alcance de este documento).
- Sin testimonios, casos de estudio, ni datos de uso real disponibles — no inventar métricas ni prueba social hasta contar con evidencia real.

## Product Principles

1. Reemplazo digital directo de la tarjeta de sellos de papel, pensado para comercios locales/independientes, no cadenas.
2. Dos audiencias con igual peso de diseño — cliente y dueño de negocio — sin que los patrones de una interfaz contaminen a la otra.
3. Loop de fidelización mínimo y de baja fricción: escanear → aprobación del negocio → puntos → premio.
4. La transferencia social de premios entre usuarios es un mecanismo diferenciador, no un afterthought — merece tratamiento de primera clase en el diseño, no quedar oculto en un historial.

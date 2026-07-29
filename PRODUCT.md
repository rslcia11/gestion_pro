# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

- **Clientes de comercios locales**: Personas que realizan compras frecuentemente en comercios de cercanía y buscan acumular puntos/sellos de forma rápida mediante escaneo QR sin lidiar con tarjetas físicas de papel o cartón.
- **Comerciantes / Negocios locales**: Dueños o empleados en caja que requieren validar escaneos QR, entregar sellos digitalmente y gestionar sus programas de beneficios sin demorar la fila de cobro.
- **Administradores de la plataforma**: Gestores que supervisan la red unificada de comercios, métricas y programas de la plataforma.

## Product Purpose

Donde Siempre es una plataforma de fidelización digital para comercios locales. Elimina las tarjetas de cartón tradicionales permitiendo acumular puntos/sellos mediante lectura de código QR y ofrece una gestión unificada de recompensas para potenciar el comercio de cercanía.

## Positioning

Un ecosistema unificado de fidelización para redes de comercios locales que permite al usuario gestionar sus recompensas comunitarias desde una sola aplicación móvil, combinando máxima velocidad en el punto de venta con accesibilidad total.

## Operating Context

- **Punto de Venta (Caja)**: Entornos de cobro en tiendas locales donde la acreditación de puntos mediante QR debe ser ultra rápida (en menos de 5 segundos).
- **Dispositivos Móviles (Android & iOS)**: Uso en movimiento por clientes y comerciantes con cámara para escaneo QR.
- **Navegador Web**: Panel de administración y dashboard para supervisión y gestión de promociones.

## Capabilities and Constraints

- **Capacidades**:
  - Escaneo de códigos QR para acreditación instantánea de sellos y recompensas.
  - Roles definidos: Cliente, Negocio y Administrador.
  - Notificaciones push integradas mediante Firebase Cloud Messaging (FCM).
  - Arquitectura frontend Feature-First en Flutter (`/app`) con gestión de estado Riverpod.
- **Restricciones**:
  - Frontend actualmente desacoplado del backend (los repositorios en `/app` usan stubs en memoria; `/supabase` sirve como especificación y referencia de reglas de negocio).

## Brand Commitments

- **Nombre del Producto**: Donde Siempre - Plataforma de Fidelización Inteligente
- **Identidad**: Cercana, confiable, moderna y pensada para dinamizar el comercio de barrio.

## Evidence on Hand

- Código fuente Flutter en `/app` (Feature-First + Riverpod).
- Documentación técnica y funcional en `/docs` (`architecture.md`, `business_rules.md`, `database.md`, `setup.md`).
- Esquema de base de datos Supabase en `/supabase`.

## Product Principles

1. **Cero Fricción en Caja**: Transacciones y escaneos de QR completados en cuestión de segundos.
2. **Impulso al Comercio Local**: Red unificada que fortalece el ecosistema comercial de comercial de cercanía.
3. **Simplicidad e Inclusividad**: Experiencia digital clara e intuitiva para usuarios de todas las edades.

## Accessibility & Inclusion

- Interfaces con alto contraste para legibilidad en entornos comerciales y escaneo QR sin fallos.
- Botones táctiles amplios y flujos optimizados para interacción en movilidad y una sola mano.

---
name: Donde Siempre
description: El pasaporte digital de fidelidad para el comercio de barrio
colors:
  tinta-absoluta: "#000000"
  on-primary: "#FFFFFF"
  neutral-bg: "#F5F5F5"
  neutral-surface: "#FFFFFF"
  neutral-border: "#F3F4F6"
  text-primary: "#171A1F"
  text-secondary: "#565D6D"
  error: "#E11D48"
  error-pastel: "rgba(225, 29, 72, 0.12)"
  accent-amber: "#F59E0B"
  accent-amber-pastel: "rgba(245, 158, 11, 0.12)"
  accent-purple: "#9333EA"
  accent-purple-pastel: "rgba(147, 51, 234, 0.12)"
  accent-pink: "#DB2777"
  accent-pink-pastel: "rgba(219, 39, 119, 0.12)"
  accent-green: "#16A34A"
  accent-green-pastel: "rgba(22, 163, 74, 0.12)"
  accent-orange: "#EA580C"
  accent-orange-pastel: "rgba(234, 88, 12, 0.12)"
  accent-blue: "#2563EB"
  accent-blue-pastel: "rgba(37, 99, 235, 0.12)"
typography:
  display:
    fontFamily: "Poppins, sans-serif"
    fontSize: "24px"
    fontWeight: 900
    lineHeight: 1.2
  title:
    fontFamily: "Poppins, sans-serif"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.25
  subtitle:
    fontFamily: "Poppins, sans-serif"
    fontSize: "17px"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "Inter, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.4
  body-medium:
    fontFamily: "Inter, sans-serif"
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.4
  label:
    fontFamily: "Inter, sans-serif"
    fontSize: "12px"
    fontWeight: 700
    letterSpacing: "0.4px"
  caption:
    fontFamily: "Inter, sans-serif"
    fontSize: "12px"
    fontWeight: 400
rounded:
  pill: "24px"
  card: "22px"
  badge: "10px"
  avatar: "26px"
  full: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.tinta-absoluta}"
    textColor: "{colors.on-primary}"
    typography: "{typography.subtitle}"
    rounded: "{rounded.pill}"
    padding: "18px 32px"
  button-primary-disabled:
    backgroundColor: "rgba(0, 0, 0, 0.6)"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.pill}"
  button-destructive:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-primary}"
    typography: "{typography.subtitle}"
    rounded: "{rounded.pill}"
    padding: "18px 32px"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.text-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "18px 32px"
  input-default:
    backgroundColor: "{colors.neutral-bg}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
    padding: "18px 20px"
  chip-status:
    typography: "{typography.label}"
    rounded: "{rounded.badge}"
    padding: "4px 10px"
  card-surface:
    backgroundColor: "{colors.neutral-surface}"
    rounded: "{rounded.card}"
    padding: "16px"
  nav-bar:
    backgroundColor: "{colors.neutral-surface}"
---

# Design System: Donde Siempre

## Overview

**Creative North Star: "El Pasaporte de Fidelidad"**

Cada superficie de la app es una página de un pasaporte que el cliente va llenando: sellos que se acumulan, un umbral que se alcanza, un premio que se despacha. El negocio es quien "sella" — por eso el negro absoluto (Tinta Absoluta) aparece solo en el gesto de acción (el botón, el ícono activo, el foco de un campo), nunca como decoración de fondo. El sistema es cálido y vecinal: fondos claros, cards con una sombra apenas perceptible, y un catálogo de acentos pastel (12% de opacidad) que identifican cada categoría de comercio como estampillas de colores distintas en el mismo pasaporte.

La forma dominante es la píldora — botones, inputs, el selector segmentado, el badge numérico — todo tiende al mismo radio o al círculo completo. Las cards rompen apenas ese lenguaje con un radio un poco más generoso (22px) para sentirse como el "papel" del pasaporte, no como un control interactivo.

**Decisión de plataforma: Material-everywhere.** La app usa Material Design 3 en Android e iOS por igual — sin una capa Cupertino separada (Stepper, AlertDialog, date pickers y demás son los mismos widgets Material en ambas plataformas). Es una decisión explícita, no una omisión: se prioriza un único lenguaje visual consistente con esta identidad ("Pasaporte de Fidelidad") por sobre la conformidad estricta con HIG en iOS. Las garantías de sistema que sí se respetan en ambas plataformas (safe area, gesto de volver, Reduce Motion) siguen aplicando igual.

**Key Characteristics:**
- Negro puro reservado exclusivamente para acción (CTA, ícono activo, foco), nunca para fondo o decoración.
- Acentos de categoría siempre en versión pastel (12% opacidad) sobre el color base — nunca el acento sólido como fondo de superficie.
- Elevación mínima y constante: una sombra ambiental, no un lenguaje de estados.
- Todo control interactivo resuelve a píldora o círculo completo; las cards usan un radio ligeramente mayor para diferenciarse de los controles.
- Tipografía dual: Poppins solo en titulares/CTA, Inter en todo lo demás — nunca mezclados dentro del mismo bloque de texto.

## Colors

Paleta acotada y de alto contraste: un negro funcional, una superficie clara casi blanca, y un set de acentos pastel que existen únicamente para diferenciar categorías de comercio — nunca para llamar la atención por sí mismos.

### Primary
- **Tinta Absoluta** (`#000000`): fondo del botón primario, color del ícono/label activo en navegación, borde de foco de inputs (2–2.5px). Es el único lugar del sistema donde el negro puro aparece; en estado disabled cae a 60% de opacidad, nunca a un gris pactado aparte.

### Secondary
- **Púrpura Vitalidad** (`#9333EA`): color secundario del `ColorScheme` de Material y acento por defecto de `StatCard` — el acento que se usa cuando una card de métrica no tiene una categoría de negocio específica que la tiña.

### Neutral
- **Niebla Clara** (`#F5F5F5`): fondo de scaffold de toda la app y fondo relleno (`filled`) de todo input.
- **Blanco Superficie** (`#FFFFFF`): fondo de cards, bottom nav y del botón primario (texto/ícono sobre negro).
- **Borde Fantasma** (`#F3F4F6`): único borde visible del sistema — separador del bottom nav y borde del botón secundario (1.5px). Casi no hay bordes en ningún otro lugar.
- **Texto Primario** (`#171A1F`): todo texto de alto énfasis (headings, body, botón secundario).
- **Texto Secundario** (`#565D6D`): subtítulos, `bodyMedium`, labels de input, íconos inactivos de navegación.

### Named Rules
**La Regla del Sello Único.** El negro (Tinta Absoluta) es acción, no atmósfera: aparece en el CTA, en el nav activo, en el foco — nunca como fondo de card, banner o superficie decorativa.

**La Regla del Acento Pastel.** Ningún acento de categoría (`accent-amber`, `accent-purple`, `accent-pink`, `accent-green`, `accent-orange`, `accent-blue`) toca una superficie en su versión sólida. Sobre fondo, siempre a 12% de opacidad (`pastelOf`); sólido, solo como color de ícono o texto sobre ese fondo pastel.

## Typography

**Display/Título Font:** Poppins (con fallback sans-serif del sistema)
**Body Font:** Inter (con fallback sans-serif del sistema)

**Character:** Poppins aporta el peso y la personalidad en titulares y CTA (hasta weight 900); Inter lleva todo el cuerpo de texto y las labels con una voz neutra y muy legible. Nunca se mezclan dentro del mismo bloque: un texto es Poppins (jerarquía/acción) o Inter (lectura/información), no ambos.

### Hierarchy
- **Display** (900, 24px, line-height 1.2): valores grandes de métrica (`StatCard`), headline principal de pantalla.
- **Title** (700, 20px, line-height 1.25): título de AppBar y de card destacada.
- **Subtitle** (700, 17px, line-height 1.3): título de `ModuleListCard`, texto de botón primario.
- **Body** (400, 14px, line-height 1.4): texto de lectura general, valor de input.
- **Body Medium** (500, 14px, line-height 1.4, color Texto Secundario): subtítulos de card, labels de input.
- **Label** (700, 12px, letter-spacing 0.4px): texto de botón secundario y de `StatusChip` (siempre en mayúsculas).
- **Caption** (400, 12px, color Texto Secundario): texto auxiliar y labels de navegación inferior.

### Named Rules
**La Regla de las Dos Voces.** Poppins solo en titulares, valores destacados y CTA; Inter en todo lo demás. Un tercer tipo de letra nunca entra al sistema (dos casos sueltos de Plus Jakarta Sans en el Figma original están confirmados como error de diseño y se ignoran).

## Layout

Densidad cómoda, no compacta: separación base de 4pt (`xs` 4 · `sm` 8 · `md` 16 · `lg` 24 · `xl` 32). Las cards usan `md` (16px) de padding interno; los botones y inputs, un padding vertical generoso (18–20px) que refuerza la sensación de píldora táctil. El bottom nav reparte sus ítems con `spaceAround` y no lleva grid explícita — cada pantalla de feature es de una sola columna, sin layout de múltiples columnas documentado todavía.

## Elevation & Depth

El sistema es casi plano: una única sombra ambiental (`0 2px 4px rgba(0,0,0,0.08)`) se aplica por igual a cards y botones y no varía por estado (sin lift en hover/press, sin sombra distinta para foco). Es una separación constante del fondo, no un lenguaje de jerarquía — nada en el sistema tiene "más" o "menos" elevación que otra cosa de su mismo tipo.

### Shadow Vocabulary
- **Ambient** (`box-shadow: 0 2px 4px rgba(0,0,0,0.08)`): única sombra del sistema, usada en `card` y `button` por igual.

### Named Rules
**La Regla de la Elevación Constante.** Si algo tiene sombra, es siempre esta misma sombra. No se introduce una segunda sombra "más fuerte" para indicar jerarquía; la jerarquía la da la tipografía y el color, no la profundidad.

## Shapes

La píldora es la forma por defecto: botones, inputs, el selector segmentado y el badge numérico resuelven a `border-radius: 24px` (o círculo completo, 999px, en el `CounterBadge`). Las cards se diferencian con un radio ligeramente mayor (22px) para leerse como superficie de contenido y no como control. Los badges de categoría/estado usan un radio más chico (10px) — suficientemente redondeado para sentirse suave, pero distinguible de un botón. Bordes son casi inexistentes: solo aparecen en el botón secundario (outline 1.5px) y en el separador superior del bottom nav (1px), siempre en `neutral-border`.

## Components

### Buttons
- **Shape:** píldora completa (radio 24px) en ambas variantes.
- **Primary:** fondo Tinta Absoluta, texto blanco, `subtitle` bold, padding 32px horizontal / 18px vertical, sin borde, sin elevación de Material (shadow propia del sistema si el contenedor la aplica). Variante `isDestructive` reemplaza el fondo por `error`. Disabled cae a 60% de opacidad del mismo color, nunca a un color distinto.
- **Secondary:** transparente con borde 1.5px en Borde Fantasma, texto y label en Texto Primario — se usa para acciones de menor énfasis ("RECHAZAR") junto a un primary.
- **Loading:** el primary reemplaza su contenido por un spinner blanco de 20px mientras `isLoading`, sin cambiar tamaño ni forma del botón.

### Chips
- **Style:** `StatusChip` — fondo pastel (12%) del color de variante, texto del color sólido correspondiente, siempre en mayúsculas, `label` bold a 11px, radio de badge (10px).
- **State:** 5 variantes por color, no por interacción — `success` (verde), `pending` (ámbar), `error` (rojo), `info` (azul), `neutral` (texto secundario). No son seleccionables ni interactivos, son de solo lectura.

### Cards / Containers
- **Corner Style:** radio de card (22px) en ambos patrones documentados.
- **Background:** Blanco Superficie.
- **Shadow Strategy:** sombra ambiental única (ver Elevation & Depth); no cambia con interacción.
- **Border:** ninguno.
- **Internal Padding:** 16px (`md`) en ambos.
- **StatCard:** ícono en badge circular pastel (36×36, radio de badge) + valor grande en `display` + label en `bodyMedium` — patrón de métrica de dashboard.
- **ModuleListCard:** ícono en badge cuadrado pastel (48×48) + título `subtitle` + subtítulo `bodyMedium` truncado a 2 líneas + `CounterBadge` opcional + chevron — patrón de navegación a un módulo (usado en el panel de Admin).

### Inputs / Fields
- **Style:** píldora (radio 24px), relleno en Niebla Clara, sin borde visible en reposo, ícono prefijo en Texto Secundario.
- **Focus:** borde sólido de 2–2.5px en Tinta Absoluta — es el único lugar donde aparece un borde grueso en todo el sistema.
- **Error/Disabled:** `errorText` soporta hasta 3 líneas; no hay tratamiento visual distinto documentado para disabled más allá del que da Material por defecto.

### Navigation
- **Style:** barra inferior blanca con separador superior de 1px (Borde Fantasma), 5 ítems repartidos con `spaceAround`, íconos Lucide de 22px.
- **Default/Active:** ítem inactivo en Texto Secundario con peso 400; ítem activo en Tinta Absoluta con peso 700 — el único cambio entre estados es color y peso de fuente, nunca tamaño ni fondo.

### Counter & Segmented (componente de firma)
Dos primitivas más chicas comparten la misma lógica de "todo es píldora": el `CounterBadge` (número en pill rosa, radio 999 completo, se auto-oculta si el conteo es 0) y el `SegmentedToggle` (tabs tipo pill dentro de un contenedor pill, con la opción seleccionada animada en Tinta Absoluta durante 200ms). Juntas son la evidencia más clara de la Regla de Formas: ninguna, ni la más chica, rompe a esquina recta.

## Do's and Don'ts

### Do:
- **Do** usar Tinta Absoluta únicamente en elementos de acción (CTA, ícono activo, foco) — nunca como fondo decorativo.
- **Do** aplicar el acento de categoría siempre en su versión pastel (12% opacidad) como fondo, reservando el tono sólido para ícono/texto sobre ese fondo.
- **Do** mantener todo control interactivo en forma de píldora o círculo completo (24px o 999px); reservar el radio de card (22px) exclusivamente para contenedores de contenido.
- **Do** usar la misma sombra ambiental (`0 2px 4px rgba(0,0,0,0.08)`) para cualquier superficie elevada — no inventar una segunda intensidad.
- **Do** separar Poppins (titulares/CTA) de Inter (cuerpo/labels) sin mezclarlos dentro del mismo bloque de texto.
- **Do** usar Material Design 3 en Android e iOS por igual (decisión explícita, ver Overview) — no introducir widgets Cupertino puntuales en pantallas nuevas.

### Don't:
- **Don't** introducir un tercer color de superficie de fondo — el sistema solo tiene Niebla Clara (scaffold) y Blanco Superficie (cards/nav).
- **Don't** dar sombra distinta a un elemento en hover/press para indicar jerarquía — la elevación es constante, no es un lenguaje de estado.
- **Don't** usar bordes decorativos: el único borde de 1.5–1px que existe (botón secundario, separador de nav) usa siempre Borde Fantasma, nunca otro gris.
- **Don't** mezclar el acento sólido de una categoría como fondo grande de superficie — se satura visualmente y rompe la Regla del Acento Pastel.

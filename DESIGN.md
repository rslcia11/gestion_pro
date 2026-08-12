---
name: Donde Siempre
description: El pasaporte del barrio, digitalizado — tinta negra sobre papel blanco, con acentos pastel de un solo uso.
colors:
  ink-primary: "#000000"
  paper-white: "#FFFFFF"
  paper-bg: "#F5F5F5"
  hairline: "#F3F4F6"
  text-primary: "#171A1F"
  text-secondary: "#565D6D"
  accent-rose: "#E11D48"
  accent-amber: "#F59E0B"
  accent-purple: "#9333EA"
  accent-pink: "#DB2777"
  accent-green: "#16A34A"
  accent-orange: "#EA580C"
  accent-blue: "#2563EB"
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
  badge: "10px"
  card: "22px"
  pill: "24px"
  avatar: "26px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.ink-primary}"
    textColor: "{colors.paper-white}"
    rounded: "{rounded.pill}"
    padding: "18px 32px"
  button-secondary:
    backgroundColor: "{colors.paper-white}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.pill}"
    padding: "18px 32px"
  input-field:
    backgroundColor: "{colors.paper-bg}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.pill}"
    padding: "18px 20px"
  card-surface:
    backgroundColor: "{colors.paper-white}"
    rounded: "{rounded.card}"
    padding: "16px"
  status-chip:
    rounded: "{rounded.badge}"
---

# Design System: Donde Siempre

## Overview

**Creative North Star: "El Pasaporte del Barrio"**

Donde Siempre digitaliza la tarjeta de sellos de cartón del comercio de barrio, no la reinventa como producto fintech. La base del sistema es tinta sobre papel: negro sólido (#000000) sobre superficies blancas y casi-blancas, sin gradientes ni texturas — minimalista y confiable es la promesa, no cálida-a-toda-costa. La calidez entra en dosis controladas: un set de siete acentos pastel (ámbar, púrpura, rosa, verde, naranja, rosado, azul) que nunca aparecen como bloque sólido, solo como texto/ícono sobre su propio tinte al 12% de opacidad — el mismo patrón `pastelOf()` se repite en cada badge, cada ícono de módulo, cada avatar sin foto. Las formas resuelven casi todo a píldora o círculo (radios de 22-26px sobre elementos que ya son grandes), y la profundidad es plana por diseño: una sola sombra suave y constante, no una jerarquía de elevación Material.

El resultado se siente **táctil y confiable** al tacto (confirmado con el usuario): firme, con feedback claro, sin nada anguloso ni jugueton — el mismo espíritu de solidez que un sello de goma real dejado sobre una tarjeta de cartón.

**Key Characteristics:**
- Tinta negra como único color de decisión — el resto del sistema es blanco, gris casi-blanco, o pastel de apoyo.
- Cero elevación Material; una sola sombra ambiental aplicada a mano en todas las superficies elevadas.
- Radios grandes y consistentes: cuatro pasos (badge/card/pill/avatar), ninguno agudo.
- Dos voces tipográficas: Poppins para momentos de decisión (títulos, CTAs), Inter para todo lo que se lee de corrido.
- Acentos pastel de un solo uso: nunca fondo sólido, siempre tinte al 12%.

## Colors

Paleta de alto contraste (negro/blanco/gris) con un set de acentos pastel funcionando como sistema semántico/categórico (estado, tipo de módulo), no como jerarquía tradicional primario→secundario→terciario.

### Primary
- **Tinta Negra** (#000000): botones primarios, estados activos, borde de input enfocado. Es el único color "sólido y decisivo" del sistema — aparece poco, y por eso pesa.

### Secondary (paleta de acentos — sistema semántico/categórico)
- **Ámbar Cálido** (#F59E0B): pendiente/en espera.
- **Púrpura Eléctrico** (#9333EA): avatar por defecto, acento de identidad.
- **Rosa Fucsia** (#DB2777): contadores/badges de notificación.
- **Verde Confirmado** (#16A34A): éxito/aprobado.
- **Naranja Terracota** (#EA580C): acento de módulo.
- **Rosado Alerta** (#E11D48): también es `error` — mismo hex reutilizado para estado de error y para un acento decorativo. Ver Don't.
- **Azul Confiable** (#2563EB): acento de módulo/info.

### Neutral
- **Papel Blanco** (#FFFFFF): superficie de tarjetas, diálogos, bottom sheets.
- **Papel Fondo** (#F5F5F5): fondo de scaffold, fondo de inputs sin foco.
- **Línea Fina** (#F3F4F6): divisores hairline (nav inferior, borde de botón secundario).
- **Texto Principal** (#171A1F) / **Texto Secundario** (#565D6D): jerarquía de texto sobre ambos blancos.

### Named Rules
**The Pastel-Only Rule.** Ningún acento aparece como relleno sólido de un bloque grande. Siempre es texto/ícono sobre su propio tinte al 12% de opacidad (`pastelOf()`). Un acento a color completo cubriendo una superficie grande rompe el sistema.

### Contrast-Safe "On-Light" Variants

El acento a color completo NO siempre cumple el piso de contraste AA (4.5:1) cuando se usa como **texto o ícono directamente sobre una superficie blanca/casi-blanca** (`paper-white`, `paper-bg`) — a diferencia de un ícono sobre su propio tinte al 12% (`pastelOf()`), que es un contexto distinto. Medido contra `#FFFFFF`: ámbar (~2.1:1) y verde (~3.3:1) fallan; púrpura (~5.4:1) pasa con margen; rosa (~4.6:1) pasa pero con un margen muy ajustado.

`app_colors.dart` documenta cuatro variantes oscurecidas (`Color.onLightOf(accent)` o las constantes directas) que sí cumplen 4.5:1 con margen real — usarlas cuando el acento es texto/ícono sobre blanco, nunca para rellenos de badges/tintes:

| Token | Hex | Contraste sobre blanco |
|-------|-----|------------------------|
| `accentPurpleOnLight` | `#7E22CE` | ~6.98:1 |
| `accentPinkOnLight` | `#BE185D` | ~6.04:1 |
| `accentAmberOnLight` | `#8A6D00` | ~4.92:1 |
| `accentGreenOnLight` | `#15803D` | ~5.02:1 |

`AppColors.onLightOf(Color accent)` resuelve la variante correcta para un acento que se tiene en una variable (ej. un acento rotativo por índice); si el acento no tiene variante documentada, devuelve el color sin cambios. Antes de usar un acento nuevo como texto sobre blanco, agregale su variante en `app_colors.dart` y en esta tabla.

## Typography

**Display Font:** Poppins (con fallback sans-serif del sistema)
**Body Font:** Inter (con fallback sans-serif del sistema)

**Character:** Poppins es la voz de los momentos de decisión — títulos, encabezados, CTAs. Inter es la voz de lectura — todo el cuerpo de texto, etiquetas y descripciones. La separación es deliberada, no accidental (confirmado en `app_typography.dart`).

### Hierarchy
- **Display** (Poppins, w900, 24px, line-height 1.2): título hero, valores destacados de métricas.
- **Title** (Poppins, w700, 20px, line-height 1.25): título de AppBar, encabezados de sección.
- **Subtitle** (Poppins, w700, 17px, line-height 1.3): subtítulos dentro de una pantalla.
- **Body** (Inter, w400, 14px, line-height 1.4): texto de lectura estándar.
- **Body Medium** (Inter, w500, 14px, line-height 1.4): texto secundario con más peso (descripciones, metadatos).
- **Label** (Inter, w700, 12px, letter-spacing 0.4px): etiquetas en mayúscula (tags de estado).
- **Caption** (Inter, w400, 12px): texto auxiliar de menor jerarquía.

### Named Rules
**The Two-Voice Rule.** Poppins habla solo en títulos, encabezados y CTAs primarios — cualquier cosa que se lea como un momento de decisión. Inter lleva cada oración que el usuario realmente lee.

## Layout

Escala base de 4pt: `xs=4, sm=8, md=16, lg=24, xl=32`. Padding de pantalla típico: 24px horizontal (algunas pantallas usan 32px horizontal en formularios, ej. login). Padding interno de tarjeta: 16-24px. Ritmo vertical entre bloques apilados vía `SizedBox` de `md`/`lg`/`xl`.

**Deriva detectada** (no es una regla, es un hallazgo a resolver): el padding de input a nivel de tema (`app_theme.dart`, 24×20) no coincide con el padding que `AppTextField` aplica por su cuenta (20×18) — dos fuentes de verdad para el mismo control. Ver Don't.

## Elevation & Depth

Sistema plano por diseño: la elevación Material está en cero en todos lados (`AppBarTheme`, `CardThemeData`, `ElevatedButtonThemeData`). La profundidad no viene de Material — viene de una única sombra ambiental aplicada a mano vía `BoxDecoration` (`AppShadows`), idéntica en tarjetas y botones, y **constante**: no responde a presión, hover ni estado. Es ambiental, no estructural — no comunica jerarquía entre superficies, solo las separa levemente del fondo.

### Shadow Vocabulary
- **card / button** (`BoxShadow(color: black @ 8%, offset: (0,2), blurRadius: 4)`): la única sombra del sistema, reutilizada en ambos roles.

### Named Rules
**The One Shadow Rule.** Hay exactamente una sombra en todo el sistema, aplicada igual a toda superficie elevada. La jerarquía no se comunica con profundidad — se comunica con el contraste tinta/papel y el tamaño.

## Shapes

Cuatro pasos de radio, ninguno agudo: `badge=10, card=22, pill=24, avatar=26`. Pill (24) en todo lo interactivo/de entrada (botones, inputs, toggle segmentado, FAB, barra de progreso). Card (22) en contenedores, diálogos y bottom sheets. Badge (10) en contenedores de ícono pequeños y chips de estado. Avatar (26) coincide con el radio de un avatar circular de 52px por defecto — en la práctica la mayoría de los avatares usan `CircleAvatar` directamente en vez de esta constante.

### Named Rules
**The Pill-or-Circle Rule.** Nada en este sistema tiene una esquina recta ni un radio intermedio — todo resuelve a uno de cuatro pasos de redondeo, y tres de los cuatro rondan la forma de estadio o círculo.

## Components

### Buttons
- **PrimaryButton** — píldora (radio `pill`), fondo `ink-primary` (o `accent-rose` si `isDestructive`), padding 32h/18v, ancho completo por defecto. Estado disabled = fondo al 60% de opacidad. Estado loading = reemplaza el label por un `CircularProgressIndicator` blanco.
- **SecondaryButton** — píldora outline, borde 1.5px color `hairline`, label en `text-primary`.
- **IconActionButton** — botón circular solo-ícono, `CircleBorder`, 40px por defecto, fondo `paper-bg`, ícono `text-primary`, ripple al tocar.

### Chips
- **StatusChip** — píldora pequeña (radio `badge`), 5 variantes semánticas (success/pending/error/info/neutral), texto en mayúscula 11px bold sobre su propio tinte pastel.
- **CounterBadge** — píldora completamente redonda, color por defecto `accent-pink`, texto blanco bold 12px, tope visual "99+"; se oculta por completo cuando el conteo es 0.

### Cards / Containers
- **Corner Style:** radio `card` (22px) en todos — `ActivityListCard`, `ModuleListCard`, `StatCard`, diálogos y bottom sheets.
- **Background:** `paper-white`.
- **Shadow Strategy:** siempre `AppShadows.card` aplicada a mano vía `Container`/`BoxDecoration` — nunca el `Card` widget plano de Material (que rendería sin sombra, ver Don't).
- **Internal Padding:** 16px estándar.

### Inputs / Fields
- **AppTextField** — píldora (radio `pill`), fondo `paper-bg` sin borde visible en reposo, borde `ink-primary` de 2px al enfocar, ícono prefijo en `text-secondary`, soporta `errorText`/`helperText` y una `fieldKey` para scroll-to-error.
- **SegmentedToggle** — grupo de tabs en píldora, track `paper-bg`, segmento seleccionado anima (200ms) a fondo `ink-primary` con texto blanco.

### Navigation
- **AppBarTitle** — envoltorio de `Text` que permite 2 líneas con elipsis en vez del truncado de una sola línea que impone el `AppBar` de Flutter por defecto.
- **AppBottomNavBar** — fondo `paper-white`, divisor superior de 1px en `hairline`, ítem seleccionado en `ink-primary` + label bold, no seleccionado en `text-secondary`. Sin sombra/elevación.
- AppBar en todas las pantallas: color `paper-bg`, `elevation: 0`, sin excepciones observadas.

### UserAvatar (componente distintivo)
`CircleAvatar` de 52px por defecto, fondo tintado de `accent-purple` (vía `pastelOf`), con fallback a iniciales en negrita cuando no hay `imageUrl` — mismo patrón visual que los íconos de módulo, aplicado a personas en vez de categorías.

## Do's and Don'ts

### Do:
- **Do** usar siempre `pastelOf(accent)` como fondo de badges/íconos — nunca el acento a color completo sobre un bloque grande (Pastel-Only Rule).
- **Do** mantener el AppBar en `paper-bg` con `elevation: 0` en toda pantalla nueva — es la convención sin excepciones observada hoy.
- **Do** reservar Poppins para títulos y CTAs primarios; todo lo demás va en Inter (Two-Voice Rule).
- **Do** aplicar `AppShadows.card` explícitamente a cualquier superficie elevada nueva.

### Don't:
- **Don't** usar el widget `Card` plano de Material sin decoración manual — con `CardThemeData.elevation: 0` global, va a renderizar completamente sin sombra.
- **Don't** introducir un quinto valor de radio — la escala de cuatro pasos (badge/card/pill/avatar) es exhaustiva por diseño.
- **Don't** reutilizar `error` (#E11D48) como acento decorativo puro (hoy es también `accentRose`) — el mismo hex sirviendo dos roles semánticos distintos (error vs. decoración) es un hallazgo a resolver, no un patrón a replicar en componentes nuevos.
- **Don't** copiar el padding de input hardcodeado sin revisar primero `AppTextField` — hay una deriva real entre el padding a nivel de tema (24×20) y el que usa el componente (20×18); no agregues un tercer valor.
- **Don't** asumir que "adaptive" (declarado en PRODUCT.md) ya está resuelto visualmente — hoy el sistema es Material puro sin capa Cupertino ni dark mode. Es una brecha abierta para `critique`/`audit`, no una decisión tomada.

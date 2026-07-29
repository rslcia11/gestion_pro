---
name: Donde Siempre
description: Sistema de diseño para plataforma de fidelización inteligente de comercios locales
colors:
  primary: "#000000"
  on-primary: "#FFFFFF"
  background: "#F5F5F5"
  surface: "#FFFFFF"
  border: "#F3F4F6"
  text-primary: "#171A1F"
  text-secondary: "#565D6D"
  error: "#E11D48"
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
  pill: "24px"
  card: "22px"
  badge: "10px"
  avatar: "26px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.pill}"
    padding: "18px 32px"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.card}"
  input:
    backgroundColor: "{colors.background}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.pill}"
    padding: "20px 24px"
---

# Design System — Donde Siempre

## Overview

El sistema de diseño de **Donde Siempre** está optimizado para interfaces móviles y táctiles en entornos de comercio local (puntos de venta y escaneo rápido de QR). Combina una paleta limpia y de alto contraste basada en negro monocromático, tarjetas blancas con esquinas amplias (`22px`) y elementos interactivos tipo píldora (`24px`).

## Colors

- **Superficie y Fondo**:
  - `background`: `#F5F5F5` — Fondo general claro y suave.
  - `surface`: `#FFFFFF` — Tarjetas y contenedores elevados.
  - `border`: `#F3F4F6` — Divisores y bordes sutiles.
- **Marca e Interacción**:
  - `primary`: `#000000` — Botones primarios, acciones principales y encabezados destacados.
  - `on-primary`: `#FFFFFF` — Texto sobre fondos primarios.
- **Tipografía**:
  - `text-primary`: `#171A1F` — Texto de alta legibilidad para títulos y cuerpo.
  - `text-secondary`: `#565D6D` — Subtítulos, descripciones e iconos secundarios.
- **Estado y Acentos de Categoría**:
  - `error`: `#E11D48` (Rojo rosado para alertas y errores).
  - Acentos pastel (12% opacidad): Usados en badges redondos por categoría de comercio (`amber`, `purple`, `pink`, `green`, `orange`, `blue`).

## Typography

Utiliza una jerarquía tipográfica dual: **Poppins** para jerarquía visual y títulos; **Inter** para lectura de datos, etiquetas e insumos en pantalla.

- **Display Bold**: Poppins 24px, Weight 900 (Extra Bold), Line Height 1.2.
- **Title Bold**: Poppins 20px, Weight 700 (Bold), Line Height 1.25.
- **Subtitle Bold**: Poppins 17px, Weight 700 (Bold), Line Height 1.3.
- **Body Regular**: Inter 14px, Weight 400 (Regular), Line Height 1.4.
- **Body Medium**: Inter 14px, Weight 500 (Medium), Line Height 1.4.
- **Label Bold**: Inter 12px, Weight 700 (Bold), Letter Spacing 0.4px (en mayúsculas para estados como PENDIENTE / ENTREGADO).
- **Caption**: Inter 12px, Weight 400 (Regular).

## Layout

- **Márgenes de Tarjeta**: Margen horizontal estándar de `16px` y vertical de `8px`.
- **Padding Interno de Formularios**: `24px` horizontal y `20px` vertical.
- **Distribución**: Retícula fluida con soporte para navegación por pestañas inferiores (Tab Bar) e interacciones mediante gestos táctiles.

## Elevation & Depth

- **Estilo Flat Plano con Tarjetas**: Se utiliza elevación `0` por defecto en tarjetas y botones, confiando en contraste de color (`#FFFFFF` sobre `#F5F5F5`) y radios acentuados en lugar de sombras pesadas para definir la jerarquía.

## Shapes

- **Pill (Píldora - `24px`)**: Aplicado dominantemente a botones primarios, botones secundarios e `InputDecoration` de formularios.
- **Card (Tarjeta - `22px`)**: Radio suave para tarjetas de comercios, estadísticas y contenedores de información.
- **Badge / Chip (`10px`)**: Para etiquetas flotantes, estados de transacción y categorías.
- **Avatar (`26px`)**: Para imágenes de perfil circulares (52px de diámetro total).

## Components

- **Botón Primario**: Fondo `#000000`, texto `#FFFFFF`, bordes tipo píldora (`24px`), padding `18px 32px`, tipografía Poppins 16px w600.
- **Campos de Texto (Inputs)**: Fondo `#F5F5F5`, borde redondeado pill sin borde visible (borde de enfoque primario de `2.5px` en `#000000`), padding `20px 24px`.
- **Badges de Categoría**: Fondos circulares de color pastel (`12%` opacidad del color acento) acompañados de íconos representativos (cafetería, restaurante, farmacia, etc.).
- **Animaciones**: Duración estándar `600ms` (`Curves.easeOutQuart`), rápida `400ms`, lenta `800ms`, curva elástica `Curves.easeOutBack` y escalonamiento `index * 50ms`.

## Do's and Don'ts

### Do's
- **Usar los tokens existentes**: Importar siempre `AppColors`, `AppTypography` y `AppRadii` en Flutter.
- **Mantener esquinas amplias**: Utilizar `AppRadii.pill` para botones e inputs, y `AppRadii.card` (`22px`) para contenedores.
- **Aprovechar los tonos pastel**: Usar `AppColors.pastelOf(accent)` para badges de estado y fondos de iconos.

### Don'ts
- **No usar valores Hardcoded**: Evitar colocar colores hex o tamaños de fuente fijos fuera de los archivos de tema.
- **No agregar sombras oscuras o pesadas**: El diseño prioriza la elevación limpia basada en tono sobre sombras arbitrarias.
- **No mezclar fuentes**: Mantener la regla Poppins para títulos y encabezados; Inter para cuerpo de texto e inputs.

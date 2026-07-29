---
timestamp: 2026-07-29T21-02-06Z
slug: app-lib-features-cards-my-cards-screen-dart
---
{
  "target": "app/lib/features/cards/my_cards_screen.dart",
  "score": 3.5,
  "heuristics": [
    {"name": "Visibility of system status", "score": 4, "issue": "Excelente indicador de progreso y sincronización en tiempo real."},
    {"name": "Match between system and real world", "score": 4, "issue": "Metáfora clara de tarjeta física de sellos/puntos."},
    {"name": "User control and freedom", "score": 3, "issue": "Modal de premios pendientes permite posponer ('Después')."},
    {"name": "Consistency and standards", "score": 4, "issue": "Cumplimiento estricto de AppColors, AppTypography y AppRadii."},
    {"name": "Error prevention", "score": 3, "issue": "Manejo de iniciales cuando no hay avatar y fallback de imágenes."},
    {"name": "Recognition rather than recall", "score": 4, "issue": "Visualización clara de progreso (puntos acumulados vs requeridos)."},
    {"name": "Flexibility and efficiency of use", "score": 3, "issue": "Botón flotante (FAB) para escanear QR rápidamente."},
    {"name": "Aesthetic and minimalist design", "score": 3, "issue": "Animación de shimmer/brillo constante en el avatar distrae visualmente."},
    {"name": "Help users recognize and recover from errors", "score": 3, "issue": "SnackBars para comunicar fallas de carga o sync."},
    {"name": "Documentation and help", "score": 3, "issue": "Estado vacío guía de forma efectiva al primer escaneo."}
  ],
  "strengths": [
    "Feedback visual y micro-interacciones (confetti, diálogos de celebración y animaciones suaves)",
    "Adherencia total a los tokens del design system (AppColors, AppTypography, AppRadii)",
    "Sincronización en tiempo real resiliente sin parpadeos de pantalla"
  ],
  "issues": [
    "Animación infinita de brillo (shimmer) en el icono del avatar distrae la atención principal",
    "Falta de filtro o buscador cuando el usuario acumula múltiples tarjetas",
    "Asignación de colores acento por ciclo (index % length) en vez de reflejar la categoría del comercio"
  ]
}

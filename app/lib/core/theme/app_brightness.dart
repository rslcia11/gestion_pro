import 'package:flutter/material.dart';

/// Holder global del [Brightness] efectivo de la app (resuelto a partir del
/// [ThemeMode] elegido por el usuario). `AppColors`/`AppShadows` lo leen para
/// resolver sus getters dinámicos; se actualiza en cada build de `AppRoot`.
class AppBrightness {
  AppBrightness._();

  static Brightness current = Brightness.light;
}

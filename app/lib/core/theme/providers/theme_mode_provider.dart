import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefsKey = 'theme_mode';

/// Modo de tema elegido por el usuario (claro/oscuro/sistema), persistido en
/// SharedPreferences. `build()` devuelve `ThemeMode.system` como default
/// inmediato y dispara la carga async de la preferencia guardada.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  bool _userHasChosen = false;

  @override
  ThemeMode build() {
    Future.microtask(_loadPersisted);
    return ThemeMode.system;
  }

  Future<void> _loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModePrefsKey);
    if (saved == null) return;
    // Si el usuario ya llamó a setThemeMode() mientras esto cargaba (arranque
    // lento), no lo pisamos con el valor persistido viejo.
    if (_userHasChosen) return;
    try {
      state = ThemeMode.values.byName(saved);
    } catch (_) {
      // Valor guardado no reconocido (ej. tras un rename futuro) — se queda en system.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _userHasChosen = true;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefsKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

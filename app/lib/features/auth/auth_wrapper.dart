import 'package:flutter/material.dart';
import 'design_preview_screen.dart';

/// App puramente front, sin backend conectado: arranca directo en
/// [DesignPreviewScreen], donde se elige a mano qué rol ver
/// (cliente/negocio/admin), sin auth real.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesignPreviewScreen();
  }
}

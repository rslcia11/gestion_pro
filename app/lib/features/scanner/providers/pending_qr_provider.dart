import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UUID de QR capturado desde un App Link antes de (o mientras) se resuelve
/// el estado de autenticación. Se consume (vuelve a null) una vez que
/// AuthWrapper decide qué hacer con él.
final pendingQrCodeProvider = StateProvider<String?>((ref) => null);

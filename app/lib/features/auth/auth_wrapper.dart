import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'login_screen.dart';
import '../business/dashboard/business_dashboard_screen.dart';
import '../business/create_business_screen.dart';
import '../cards/my_cards_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/services/realtime_sync_service.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/widgets/global_celebration_dialog.dart';
import '../../core/providers/supabase_provider.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../scanner/scanner_screen.dart';
import '../scanner/providers/pending_qr_provider.dart';
import 'dart:async';
import 'providers/auth_provider.dart';
import '../../main.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  StreamSubscription<void>? _transferSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Re-verificamos la autenticación por si acaso, aunque el Provider se inicializa solo
      ref.read(authStateProvider.notifier).checkAuth();
    });

    _transferSub = RealtimeSyncService().onRewardTransfersChanged.listen((payload) {
      if (!mounted || payload == null) return;
      final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (payload['to_user_id'] == currentUserId && currentUserId != null) {
        GlobalCelebrationDialog.show(
          context,
          title: '¡TE HAN TRANSFERIDO!',
          message: '¡Acabas de recibir un premio de un amigo! Revisa tus tarjetas.',
          iconType: 'transfer',
        );
      }
    });

    DeepLinkService().initialize(
      onQrCodeReceived: (code) {
        if (!mounted) return;
        ref.read(pendingQrCodeProvider.notifier).state = code;
      },
    );
  }

  // Intenta consumir un código QR pendiente (capturado desde un App Link).
  // Se llama tanto cuando cambia el estado de auth como cuando llega un
  // nuevo código, porque no hay garantía de qué evento ocurre primero.
  void _tryConsumePendingQr() {
    final code = ref.read(pendingQrCodeProvider);
    if (code == null) return;

    final authState = ref.read(authStateProvider);

    if (authState is AuthClient) {
      ref.read(pendingQrCodeProvider.notifier).state = null;
      globalNavigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => ScannerScreen(initialCode: code)),
      );
    } else if (authState is! AuthInitial && authState is! AuthUnauthenticated) {
      // Dueño de negocio / admin / negocio inactivo o pendiente de crear:
      // descartamos el código en silencio, la app abre normal.
      ref.read(pendingQrCodeProvider.notifier).state = null;
    }
    // AuthInitial / AuthUnauthenticated: dejamos el código guardado hasta
    // que el login resuelva.
  }

  @override
  void dispose() {
    _transferSub?.cancel();
    super.dispose();
  }

  void _showInactiveAccountDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        title: Text(
          'Cuenta inactiva',
          style: AppTypography.titleBold,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tu negocio se encuentra inactivo.\n\nPor favor, comunícate con nosotros para procesar el pago o la activación de tu cuenta:',
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Enviar Correo',
              icon: LucideIcons.mail,
              onPressed: () => launchUrl(Uri.parse('mailto:${AppTheme.supportEmail}')),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.03, duration: 1.2.seconds, curve: Curves.easeInOut),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Contactar por WhatsApp',
              icon: LucideIcons.phone,
              onPressed: () => launchUrl(Uri.parse('https://wa.me/${AppTheme.supportWhatsApp}')),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.03, duration: 1.2.seconds, delay: 600.ms, curve: Curves.easeInOut),
          ],
        ),
        actions: [
          PrimaryButton(
            label: 'Cerrar Sesión',
            icon: LucideIcons.logOut,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Escuchar cambios de estado para mostrar dialogos (side-effects)
    ref.listen<AuthStateStatus>(authStateProvider, (previous, next) {
      if (next is AuthBusinessInactive && previous is! AuthBusinessInactive) {
        _showInactiveAccountDialog();
      }

      // Manejar inicialización de push notification cuando hay usuario validado
      if (next is AuthAdmin || next is AuthBusinessActive || next is AuthClient) {
        PushNotificationService.initialize();
        // Recién acá (ya autenticado) suscribimos el realtime, para que el canal
        // lleve el JWT del usuario y RLS le entregue sus cambios en vivo.
        RealtimeSyncService().initialize();
      } else if (next is AuthUnauthenticated) {
        // Al cerrar sesión, soltamos el canal para que el próximo login abra uno limpio,
        // y reseteamos los flags de sesión (bienvenida / recordatorio de premio) para
        // que el próximo usuario los vea correctamente.
        RealtimeSyncService().reset();
        MyCardsScreen.resetSessionFlags();
      }

      _tryConsumePendingQr();
    });

    ref.listen<String?>(pendingQrCodeProvider, (previous, next) {
      if (next != null) _tryConsumePendingQr();
    });

    if (authState is AuthInitial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
          ),
        ),
      );
    }

    if (authState is AuthUnauthenticated) {
      return const LoginScreen();
    }

    if (authState is AuthAdmin) {
      return const AdminDashboardScreen();
    }

    if (authState is AuthBusinessPendingCreate) {
      return const CreateBusinessScreen();
    }

    if (authState is AuthBusinessActive) {
      return const BusinessDashboardScreen();
    }

    if (authState is AuthClient) {
      return const MyCardsScreen();
    }

    // Estado por defecto mientras procesa inactividad
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
        ),
      ),
    );
  }
}

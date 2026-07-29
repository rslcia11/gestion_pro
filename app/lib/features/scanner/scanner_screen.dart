import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/scanner_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();

  void _showSuccessDialog(String businessName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Pendiente', textAlign: TextAlign.center, style: AppTypography.titleBold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.accentAmber), shape: BoxShape.circle),
              child: const Icon(LucideIcons.hourglass, size: 44, color: AppColors.accentAmber),
            ),
            const SizedBox(height: 24),
            Text(businessName, style: AppTypography.subtitleBold, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Escaneo registrado. Espera a que el local lo apruebe para recibir tu punto.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            label: 'Entendido',
            onPressed: () {
              Navigator.pop(context); // cierra el diálogo
              Navigator.of(context).pop(); // cierra el scanner y vuelve a MyCardsScreen
            },
          ),
        ],
      ),
    );
  }

  void _showCooldownDialog({required String businessName, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Espera', textAlign: TextAlign.center, style: AppTypography.titleBold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.accentPurple), shape: BoxShape.circle),
              child: const Icon(LucideIcons.clock, size: 44, color: AppColors.accentPurple),
            ),
            const SizedBox(height: 24),
            Text(message, style: AppTypography.subtitleBold, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '¡Pero puedes escanear en otros locales ahora mismo!',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            label: 'Vale',
            onPressed: () {
              Navigator.pop(context);
              cameraController.start();
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Error', textAlign: TextAlign.center, style: AppTypography.titleBold),
        content: Text(message, style: AppTypography.bodyRegular, textAlign: TextAlign.center),
        actions: [
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () {
              Navigator.pop(context);
              cameraController.start();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);

    ref.listen<ScannerState>(scannerProvider, (previous, next) {
      if (previous?.isProcessing == true && next.isProcessing == false) {
        if (next.successBusinessName != null) {
          HapticFeedback.mediumImpact();
          _showSuccessDialog(next.successBusinessName!);
        } else if (next.cooldownHours != null) {
          HapticFeedback.lightImpact();
          _showCooldownDialog(
            businessName: '¡ESPERA!',
            message: 'Este local tiene una restricción de ${next.cooldownHours} horas entre escaneos.',
          );
        } else if (next.hasPendingReward) {
          HapticFeedback.heavyImpact();
          _showErrorDialog(
            '¡Tenés un premio pendiente en este local! Reclamalo primero antes de seguir acumulando puntos.',
          );
        } else if (next.error != null) {
          HapticFeedback.heavyImpact();
          _showErrorDialog(next.error!);
        }
        ref.read(scannerProvider.notifier).reset();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconActionButton(
            icon: LucideIcons.zap,
            tooltip: 'Linterna',
            backgroundColor: Colors.transparent,
            iconColor: AppColors.onPrimary,
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          final scanBoxSize = (MediaQuery.sizeOf(context).shortestSide * 0.6).clamp(200.0, 280.0);

          return Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null && !state.isProcessing) {
                      cameraController.stop();
                      ref.read(scannerProvider.notifier).validateScan(barcode.rawValue!);
                      break;
                    }
                  }
                },
                errorBuilder: (context, error, child) {
                  if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                    return _CameraPermissionDeniedView(onOpenSettings: openAppSettings);
                  }
                  return _ScannerErrorView(
                    message: error.errorDetails?.message ?? 'No se pudo iniciar la cámara.',
                    onRetry: () => cameraController.start(),
                  );
                },
              ),

              // Custom Overlay
              Center(
                child: Container(
                  width: scanBoxSize,
                  height: scanBoxSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.onPrimary, width: 4),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                ),
              ),

              if (!state.isProcessing)
                Positioned(
                  bottom: AppSpacing.lg + bottomInset,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                      ),
                      child: Column(
                        children: [
                          Text('Apunta al código QR', style: AppTypography.subtitleBold, textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Asegúrate de que el código esté dentro del recuadro.',
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ).animate().slideY(begin: 1, curve: Curves.easeOutBack, duration: 600.ms),
                ),

              if (state.isProcessing)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.onPrimary),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Validando...',
                          style: AppTypography.titleBold.copyWith(color: AppColors.onPrimary),
                        ).animate(onPlay: (controller) => controller.repeat()).fadeIn().fadeOut(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Vista de recuperación cuando el usuario negó el permiso de cámara —
/// sin esto, MobileScanner muestra un preview negro sin salida.
class _CameraPermissionDeniedView extends StatelessWidget {
  const _CameraPermissionDeniedView({required this.onOpenSettings});

  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.error), shape: BoxShape.circle),
                  child: Icon(LucideIcons.cameraOff, size: 40, color: AppColors.pastelText(AppColors.error)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Necesitamos acceso a tu cámara', style: AppTypography.titleBold, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Para escanear un código QR, activá el permiso de cámara en la configuración del sistema.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Abrir Configuración', onPressed: onOpenSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vista de recuperación para cualquier otro error de cámara (genérico).
class _ScannerErrorView extends StatelessWidget {
  const _ScannerErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.error), shape: BoxShape.circle),
                  child: Icon(LucideIcons.circleAlert, size: 40, color: AppColors.pastelText(AppColors.error)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('No pudimos abrir la cámara', style: AppTypography.titleBold, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(message, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Reintentar', onPressed: onRetry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


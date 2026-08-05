import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/qr_code_link.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/scanner_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final String? initialCode;
  const ScannerScreen({super.key, this.initialCode});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    final initialCode = widget.initialCode;
    if (initialCode != null) {
      Future.microtask(
        () => ref.read(scannerProvider.notifier).validateScan(initialCode),
      );
    }
  }

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
          _showSuccessDialog(next.successBusinessName!);
        } else if (next.cooldownHours != null) {
          _showCooldownDialog(
            businessName: '¡ESPERA!',
            message: 'Este local tiene una restricción de ${next.cooldownHours} horas entre escaneos.',
          );
        } else if (next.hasPendingReward) {
          _showErrorDialog(
            '¡Tenés un premio pendiente en este local! Reclamalo primero antes de seguir acumulando puntos.',
          );
        } else if (next.error != null) {
          _showErrorDialog(next.error!);
        }
        ref.read(scannerProvider.notifier).reset();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const AppBarTitle('Escanear QR'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconActionButton(
          icon: LucideIcons.arrowLeft,
          backgroundColor: Colors.white24,
          iconColor: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconActionButton(
            icon: LucideIcons.zap,
            backgroundColor: Colors.transparent,
            iconColor: Colors.white,
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (widget.initialCode == null)
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !state.isProcessing) {
                    final code = QrCodeLink.extractQrCode(barcode.rawValue!);
                    if (code != null) {
                      cameraController.stop();
                      ref.read(scannerProvider.notifier).validateScan(code);
                    }
                    break;
                  }
                }
              },
            ),

          // Custom Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
            ),
          ),

          if (!state.isProcessing)
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Column(
                  children: [
                    Text('Apunta al código QR', style: AppTypography.subtitleBold, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Asegúrate de que el código esté dentro del recuadro.',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 24),
                    Text(
                      'Validando...',
                      style: AppTypography.titleBold.copyWith(color: Colors.white),
                    ).animate(onPlay: (controller) => controller.repeat()).fadeIn().fadeOut(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

